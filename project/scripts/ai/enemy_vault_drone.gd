extends "res://scripts/ai/base_enemy.gd"

## Vault Drone enemy — Floor 4 (Vault/Greed).
## Mechanical drone with no limbs — all damage redirected to torso.
## Shock attack and overcharge dash. Explodes on death.

# Overcharge state
var _overcharge_charging: bool = false
var _overcharge_timer: float = 0.0
var _overcharge_cooldown: float = 0.0
const OVERCHARGE_CHARGE_TIME: float = 3.0
const OVERCHARGE_DAMAGE: float = 40.0
const OVERCHARGE_SELF_DAMAGE: float = 15.0
const OVERCHARGE_KNOCKBACK: float = 50.0
const OVERCHARGE_COOLDOWN: float = 8.0

# Shock
const SHOCK_STUN_DURATION: float = 0.8

# Spark visual
var _spark_rect: ColorRect = null
var _spark_timer: float = 0.0


func _ready() -> void:
	enemy_name = "Vault Drone"
	enemy_type = "vault_drone"

	torso_hp = 60.0
	head_hp = 0.0
	arm_hp = 0.0
	leg_hp = 0.0
	move_speed = 160.0
	detection_range = 300.0
	attack_range = 40.0
	attack_damage = 20.0
	attack_speed = 1.0
	grab_strength = 0.0
	regen_speed_mult = 0.5
	aggression = 8.0
	coordination = 6.0

	add_to_group("vault_drones")
	super._ready()
	_create_glowing_eye()
	_create_spark_rect()


func _init_health() -> void:
	# Only TORSO has real HP — all limbs are pre-severed with 0 HP
	limb_health = {
		DamageZone.Zone.HEAD: 0.0,
		DamageZone.Zone.LEFT_ARM: 0.0,
		DamageZone.Zone.RIGHT_ARM: 0.0,
		DamageZone.Zone.LEFT_LEG: 0.0,
		DamageZone.Zone.RIGHT_LEG: 0.0,
		DamageZone.Zone.TORSO: torso_hp,
	}
	severed_limbs = {
		DamageZone.Zone.HEAD: true,
		DamageZone.Zone.LEFT_ARM: true,
		DamageZone.Zone.RIGHT_ARM: true,
		DamageZone.Zone.LEFT_LEG: true,
		DamageZone.Zone.RIGHT_LEG: true,
	}
	# No regen timers — limbs never come back
	regen_timers = {}


func _create_glowing_eye() -> void:
	var eye := ColorRect.new()
	eye.size = Vector2(4, 4)
	eye.color = Color(1.0, 0.0, 0.0, 1)  # Red #FF0000
	eye.position = Vector2(-2, -10)
	eye.z_index = 2
	sprite.add_child(eye)


func _create_spark_rect() -> void:
	_spark_rect = ColorRect.new()
	_spark_rect.size = Vector2(6, 6)
	_spark_rect.color = Color(1.0, 1.0, 0.0, 1)  # Yellow flash
	_spark_rect.position = Vector2(-3, -3)
	_spark_rect.z_index = 3
	_spark_rect.visible = false
	sprite.add_child(_spark_rect)


# ---------------------------------------------------------------------------
# Physics update
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_process_overcharge(delta)
	_process_spark(delta)

	if _overcharge_cooldown > 0.0:
		_overcharge_cooldown -= delta

	# Call base physics (handles disabled, stunned, state machine, etc.)
	super._physics_process(delta)


func _process_overcharge(delta: float) -> void:
	if not _overcharge_charging:
		return

	_overcharge_timer -= delta
	# Telegraph: pulsing glow while charging
	if sprite:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.01)
		sprite.modulate = Color(1.0, 0.5 + pulse * 0.5, 0.2)

	if _overcharge_timer <= 0.0:
		_execute_overcharge()


func _process_spark(delta: float) -> void:
	if _spark_rect == null or not _spark_rect.visible:
		return

	_spark_timer -= delta
	if _spark_timer <= 0.0:
		_spark_rect.visible = false


func _trigger_spark() -> void:
	if _spark_rect == null:
		return
	_spark_rect.visible = true
	_spark_timer = 0.12


# ---------------------------------------------------------------------------
# Damage override — redirect ALL damage to TORSO
# ---------------------------------------------------------------------------

func receive_damage(damage: float, _zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if _disabled:
		return

	# Redirect all damage to torso
	limb_health[DamageZone.Zone.TORSO] -= damage

	# Visual: spark flash on hit
	_trigger_spark()

	# Knockback
	if knockback_force > 0.0:
		_knockback_vel = knockback_dir * knockback_force * 5.0

	# Alert on damage
	if not _alerted:
		_alert_nearby()

	EventBus.enemy_damaged.emit(self, DamageZone.Zone.TORSO, damage)

	# Check torso death — explode instead of normal disable
	if limb_health[DamageZone.Zone.TORSO] <= 0.0:
		_death_explode()
		return

	# State transition
	if _current_state == "patrol":
		_enter_state("alert")


# ---------------------------------------------------------------------------
# Death explosion
# ---------------------------------------------------------------------------

func _death_explode() -> void:
	# AoE 15 damage to nearby bodies in radius 40px
	var explosion_radius: float = 40.0
	var bodies := get_tree().get_nodes_in_group("player")
	# Also check enemies
	var enemies := get_tree().get_nodes_in_group("enemy")
	var all_targets := bodies + enemies

	for target in all_targets:
		if not is_instance_valid(target) or target == self:
			continue
		if target.global_position.distance_to(global_position) <= explosion_radius:
			if target.has_method("receive_damage"):
				target.receive_damage(15.0, DamageZone.Zone.TORSO, false, 20.0, global_position.direction_to(target.global_position))

	# Spawn a brief hazard zone for visual effect
	var hazard_scene: PackedScene = load("res://scenes/combat/hazard_zone.tscn")
	if hazard_scene != null:
		var zone: Area2D = hazard_scene.instantiate()
		zone.damage_per_second = 0.0
		zone.slow_factor = 1.0
		zone.duration = 0.3
		zone.zone_color = Color(1.0, 0.6, 0.1)
		zone.zone_radius = explosion_radius
		zone.global_position = global_position
		get_tree().current_scene.add_child(zone)

	EventBus.enemy_disabled.emit(self)
	queue_free.call_deferred()


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	# Direct movement toward player — fast, flies straight
	var dir := global_position.direction_to(_target.global_position)
	velocity = dir * move_speed
	_direction = dir

	# Enter engage when close enough
	if global_position.distance_to(_target.global_position) <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	# Face target
	_direction = global_position.direction_to(_target.global_position)

	# Overcharge if available and enough time
	if _overcharge_cooldown <= 0.0 and not _overcharge_charging:
		if randf() < 0.3:  # 30% chance to overcharge each tick while in range
			_start_overcharge()
			return

	# Standard shock attack
	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = 1.0 / attack_speed

	# Stay close to target
	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.5:
		_enter_state("chase")
	elif dist > attack_range:
		# Drift toward player
		velocity = _direction * move_speed * 0.5
	else:
		velocity = Vector2.ZERO


# ---------------------------------------------------------------------------
# Shock attack
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.2:
		return

	# Apply shock damage
	if _target.has_method("receive_damage"):
		_target.receive_damage(attack_damage, DamageZone.Zone.TORSO, false, 10.0, _direction)

	# Apply stun to player
	if _target.has_method("apply_stun"):
		_target.apply_stun(SHOCK_STUN_DURATION)

	# Visual feedback
	_trigger_spark()


# ---------------------------------------------------------------------------
# Overcharge
# ---------------------------------------------------------------------------

func _start_overcharge() -> void:
	_overcharge_charging = true
	_overcharge_timer = OVERCHARGE_CHARGE_TIME


func _execute_overcharge() -> void:
	_overcharge_charging = false
	_overcharge_cooldown = OVERCHARGE_COOLDOWN

	if sprite:
		sprite.modulate = Color.WHITE

	if _target == null or not is_instance_valid(_target):
		return

	# Dash to player position
	var dir := global_position.direction_to(_target.global_position)
	var dash_dist := global_position.distance_to(_target.global_position)
	var dash_target := global_position + dir * dash_dist

	# Instant dash (teleport to target vicinity)
	global_position = dash_target

	# Deal damage to player
	if _target.has_method("receive_damage"):
		_target.receive_damage(OVERCHARGE_DAMAGE, DamageZone.Zone.TORSO, false, OVERCHARGE_KNOCKBACK, dir)

	# Self-damage
	limb_health[DamageZone.Zone.TORSO] -= OVERCHARGE_SELF_DAMAGE

	# Visual
	_trigger_spark()

	# Check if self-damage killed us
	if limb_health[DamageZone.Zone.TORSO] <= 0.0:
		_death_explode()


# ---------------------------------------------------------------------------
# Mutilation overrides — NOT applicable (no limbs)
# ---------------------------------------------------------------------------

func _on_limb_lost(_zone: int) -> void:
	# No limbs to lose — do nothing
	pass


func _evaluate_mutilated_behavior() -> void:
	# No limbs — no mutilation behavior changes
	pass


# ---------------------------------------------------------------------------
# Regeneration override — no limb regen for drone
# ---------------------------------------------------------------------------

func _process_regen(_delta: float) -> void:
	# No limb regeneration — drone has no limbs
	pass
