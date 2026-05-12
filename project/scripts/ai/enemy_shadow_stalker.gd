extends "res://scripts/ai/base_enemy.gd"

## ShadowStalker — Floor 7 (Observatory / Envy) phase walker.
## Can phase through walls to ambush the player. Shadow claw attack
## applies a shadow mark debuff. Pushes instead of claws when arms are lost,
## phases more often when legs are lost.

# Phase ability
var _phase_cooldown: float = 0.0
var _phase_cooldown_max: float = 3.0
var _is_phasing: bool = false
var _phase_timer: float = 0.0
var _phase_duration: float = 1.0

# Shadow mark cooldown
var _shadow_mark_cooldown: float = 0.0
var _shadow_mark_cooldown_max: float = 10.0

# Original collision mask (set from base enemy: 71)
var _original_collision_mask: int = 71
# Mask without environment layer (layer 7 bit = 64): 71 - 64 = 7
var _phase_collision_mask: int = 7

# Mutilation tracking
var _arms_lost: int = 0
var _legs_lost: int = 0
var _dissolving: bool = false


func _ready() -> void:
	enemy_name = "Shadow Stalker"
	enemy_type = "shadow_stalker"

	torso_hp = 60.0
	head_hp = 20.0
	arm_hp = 16.0
	leg_hp = 16.0
	move_speed = 120.0
	detection_range = 200.0
	attack_range = 50.0
	attack_damage = 20.0
	attack_speed = 0.9
	grab_strength = 6.0
	regen_speed_mult = 1.1
	aggression = 7.0
	coordination = 4.0

	add_to_group("shadow_stalkers")
	super._ready()


# ---------------------------------------------------------------------------
# Phase ability — pass through walls temporarily
# ---------------------------------------------------------------------------

func _try_phase() -> void:
	if _is_phasing or _phase_cooldown > 0.0:
		return

	# Check if there is a wall between us and the target
	if _target == null or not is_instance_valid(_target):
		return

	# Check for doors in the direction — cannot phase through closed doors
	var dir_to_target := global_position.direction_to(_target.global_position)
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		_target.global_position,
		_original_collision_mask
	)
	query.exclude = [self.get_rid()]
	var result := space_state.intersect_ray(query)

	if result.is_empty():
		return  # No wall in the way, no need to phase

	# Check if the hit collider is a door
	var collider: Object = result.get("collider", null)
	if collider and collider is Node2D and collider.is_in_group("door"):
		return  # Cannot phase through closed doors

	# Start phasing
	_is_phasing = true
	_phase_timer = _phase_duration
	collision_mask = _phase_collision_mask
	sprite.modulate = Color(0.5, 0.3, 0.7, 0.5)


func _end_phase() -> void:
	_is_phasing = false
	collision_mask = _original_collision_mask
	sprite.modulate = Color.WHITE


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	# Attempt phase through walls if path seems blocked
	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var nav_dist := global_position.distance_to(next_pos)

	# If the next nav point is far relative to the player distance,
	# path is likely winding around walls
	if dist < 200.0 and nav_dist > dist * 0.8 and _phase_cooldown <= 0.0:
		_try_phase()

	# Normal chase movement
	var dir := global_position.direction_to(next_pos)
	velocity = dir * move_speed
	_direction = dir

	if dist <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Attack logic
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	if _arms_lost >= 2:
		# Push attack: reduced damage and range
		if global_position.distance_to(_target.global_position) <= 30.0:
			if _target.has_method("receive_damage"):
				_target.receive_damage(5.0, DamageZone.Zone.TORSO, false)
		return

	# Shadow claw attack
	var damage := attack_damage
	if _target.has_method("receive_damage"):
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false)

	# Apply shadow mark — emit signal for other systems to react
	if _shadow_mark_cooldown <= 0.0:
		_shadow_mark_cooldown = _shadow_mark_cooldown_max
		EventBus.player_marked.emit(10.0)


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
		if _arms_lost >= 2:
			attack_range = 30.0

	if DamageZone.is_leg(zone):
		_legs_lost = int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_LEG])
		if _legs_lost >= 1:
			_phase_cooldown_max = 2.0

	# Full mutilate: dissolve — fade and slow regen
	if _arms_lost >= 2 and _legs_lost >= 2:
		_dissolving = true


# ---------------------------------------------------------------------------
# Physics process — manage phase, cooldowns, dissolve
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if _disabled:
		_disabled_timer -= delta
		if _disabled_timer <= 0.0:
			_disabled = false
			_enter_state("patrol")
		return

	if _stunned:
		_stun_timer -= delta
		if _stun_timer <= 0.0:
			_stunned = false
		velocity = _knockback_vel * 0.9
		_knockback_vel *= 0.9
		move_and_slide()
		_process_regen(delta)
		return

	# Phase handling
	if _is_phasing:
		_phase_timer -= delta
		# Continue moving toward target while phasing
		if _target and is_instance_valid(_target):
			var dir := global_position.direction_to(_target.global_position)
			velocity = dir * move_speed * 1.3
			_direction = dir
		_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
		velocity += _knockback_vel
		move_and_slide()
		if _phase_timer <= 0.0:
			_end_phase()
		_process_regen(delta)
		return

	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_phase_cooldown = maxf(0.0, _phase_cooldown - delta)
	_shadow_mark_cooldown = maxf(0.0, _shadow_mark_cooldown - delta)
	_state_timer -= delta

	# Dissolve effect when fully mutilated
	if _dissolving:
		sprite.modulate.a = move_toward(sprite.modulate.a, 0.3, 0.2 * delta)

	_process_state(delta)
	_process_regen(delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	velocity += _knockback_vel

	move_and_slide()
