extends "res://scripts/ai/base_enemy.gd"

## Demon — Floor 9 (Satan's Sanctum) non-human entity.
## No limb model: only TORSO + HEAD zones. Dark bolt ranged attack (homing),
## claw combo melee, phase-behind-player ability, dissolve death → shadow pool.

# Attack tuning
var _claw_damage: Array[float] = [15.0, 20.0, 25.0]
var _bolt_damage: float = 25.0
var _bolt_speed: float = 200.0
var _bolt_homing_rate: float = 45.0  # degrees per second
var _bolt_lifetime: float = 5.0
var _bolt_range: float = 200.0
var _claw_range: float = 80.0

# Combo tracking
var _combo_count: int = 0

# Phase-behind-player cooldown
var _phase_cooldown: float = 0.0
var _phase_cooldown_max: float = 6.0
var _phasing: bool = false
var _phase_timer: float = 0.0
var _phase_decided: bool = false
var _original_collision_layer: int = 0

# Dark bolt projectiles
var _dark_bolts: Array[Area2D] = []


func _ready() -> void:
	enemy_name = "Demon"
	enemy_type = "demon"

	torso_hp = 120.0
	head_hp = 40.0
	arm_hp = 0.0
	leg_hp = 0.0
	move_speed = 150.0
	detection_range = 300.0
	attack_range = _claw_range
	attack_damage = 20.0
	attack_speed = 1.0
	grab_strength = 0.0
	regen_speed_mult = 1.5
	aggression = 9.0
	coordination = 5.0

	add_to_group("demons")
	super._ready()
	_original_collision_layer = collision_layer


# ---------------------------------------------------------------------------
# Health overrides — no limb model (only TORSO + HEAD)
# ---------------------------------------------------------------------------

func _init_health() -> void:
	limb_health = {
		DamageZone.Zone.TORSO: torso_hp,
		DamageZone.Zone.HEAD: head_hp,
	}
	severed_limbs = {}
	regen_timers = {}


func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	# Redirect non-TORSO/non-HEAD to TORSO
	var effective_zone := zone
	if zone != DamageZone.Zone.TORSO and zone != DamageZone.Zone.HEAD:
		effective_zone = DamageZone.Zone.TORSO
	super.receive_damage(damage, effective_zone, false, knockback_force, knockback_dir)


func _on_limb_lost(_zone: int) -> void:
	# No limbs to lose
	pass


func _evaluate_mutilated_behavior() -> void:
	# Not applicable — no limbs
	pass


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _enter_state(state_name: String) -> void:
	super._enter_state(state_name)
	if state_name == "chase":
		_phase_decided = false


func _state_chase(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	if dist < 100.0 and _phase_cooldown <= 0.0:
		if not _phase_decided:
			_phase_decided = true
			if randf() < 0.3:
				_start_phase()
				return

	# Dark bolt if target is far
	if dist > 150.0 and _attack_cooldown <= 0.0:
		_spawn_dark_bolt()
		_attack_cooldown = attack_speed * 1.5
		return

	# Normal chase
	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * move_speed
	_direction = dir

	if dist <= _claw_range:
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

	var dist := global_position.distance_to(_target.global_position)
	if dist > _claw_range * 1.5:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Attack logic
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	# Every 3rd attack is a dark bolt, rest are claw combo
	if _combo_count >= 3:
		_spawn_dark_bolt()
		_combo_count = 0
		return

	# Phase behind player check (30% chance when cooldown ready)
	if _phase_cooldown <= 0.0 and not _phase_decided:
		_phase_decided = true
		if randf() < 0.3:
			_start_phase()
			_combo_count += 1
			return

	var damage: float = _claw_damage[_combo_count] if _combo_count < _claw_damage.size() else 20.0
	if _target.has_method("receive_damage"):
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false)
	_combo_count += 1


# ---------------------------------------------------------------------------
# Phase ability — disappear and reappear behind the player
# ---------------------------------------------------------------------------

func _start_phase() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	_phasing = true
	_phase_timer = 0.3
	_phase_cooldown = _phase_cooldown_max
	sprite.modulate.a = 0.0
	collision_layer = 0
	_spawn_phase_particles()

func _spawn_phase_particles() -> void:
	for i in range(6):
		var p := ColorRect.new()
		p.size = Vector2(2, 2)
		p.color = Color(1.0, 0.0, 0.0, 0.9)
		p.z_index = 10
		get_tree().current_scene.add_child(p)
		p.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		var tween := p.create_tween()
		tween.tween_property(p, "modulate:a", 0.0, 0.5)
		tween.tween_callback(p.queue_free)


func _finish_phase() -> void:
	_phasing = false
	sprite.modulate.a = 1.0
	collision_layer = _original_collision_layer

	if _target == null or not is_instance_valid(_target):
		return

	# Teleport behind the player
	var player_facing := Vector2.ZERO
	if "velocity" in _target:
		player_facing = _target.velocity.normalized()
	if player_facing == Vector2.ZERO:
		player_facing = Vector2.DOWN

	global_position = _target.global_position - player_facing * 50.0
	navigation.target_position = _target.global_position


# ---------------------------------------------------------------------------
# Dark bolt projectile (homing with turn rate)
# ---------------------------------------------------------------------------

func _spawn_dark_bolt() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var bolt := Area2D.new()
	bolt.name = "DarkBolt"
	bolt.add_to_group("enemy_hitbox")

	var shape := CircleShape2D.new()
	shape.radius = 6.0
	var col := CollisionShape2D.new()
	col.shape = shape
	bolt.add_child(col)

	var visual := ColorRect.new()
	visual.size = Vector2(8, 8)
	visual.position = Vector2(-4, -4)
	visual.color = Color(0.3, 0.0, 0.5)
	bolt.add_child(visual)

	bolt.global_position = global_position
	bolt.set_meta("target", _target)
	bolt.set_meta("lifetime", _bolt_lifetime)
	bolt.set_meta("direction", global_position.direction_to(_target.global_position))
	bolt.set_meta("damage", _bolt_damage)
	bolt.set_meta("speed", _bolt_speed)
	bolt.set_meta("homing_rate", _bolt_homing_rate)
	bolt.set_meta("source", self)

	get_tree().current_scene.add_child(bolt)
	_dark_bolts.append(bolt)


func _update_bolts(delta: float) -> void:
	var to_remove: Array[Area2D] = []
	for bolt in _dark_bolts:
		if not is_instance_valid(bolt):
			to_remove.append(bolt)
			continue

		# Lifetime
		var t: float = bolt.get_meta("lifetime")
		t -= delta
		if t <= 0.0:
			bolt.queue_free()
			to_remove.append(bolt)
			continue
		bolt.set_meta("lifetime", t)

		# Homing movement
		var target: Node2D = bolt.get_meta("target")
		if not is_instance_valid(target):
			bolt.queue_free()
			to_remove.append(bolt)
			continue

		var current_dir: Vector2 = bolt.get_meta("direction")
		var desired_dir := bolt.global_position.direction_to(target.global_position)

		# Apply turn rate (degrees per second)
		var homing_rate: float = bolt.get_meta("homing_rate")
		var max_turn := deg_to_rad(homing_rate) * delta
		var angle_diff := current_dir.angle_to(desired_dir)

		if abs(angle_diff) > max_turn:
			angle_diff = sign(angle_diff) * max_turn
		var new_dir := current_dir.rotated(angle_diff).normalized()
		bolt.set_meta("direction", new_dir)

		var speed: float = bolt.get_meta("speed")
		bolt.global_position += new_dir * speed * delta

		# Hit check
		if bolt.global_position.distance_to(target.global_position) < 15.0:
			var dmg: float = bolt.get_meta("damage")
			if target.has_method("receive_damage"):
				target.receive_damage(dmg, DamageZone.Zone.TORSO, false)
			bolt.queue_free()
			to_remove.append(bolt)

	for b in to_remove:
		_dark_bolts.erase(b)


# ---------------------------------------------------------------------------
# Death override — dissolve animation → shadow pool
# ---------------------------------------------------------------------------

func _disable_enemy() -> void:
	# Free all active dark bolts
	for bolt in _dark_bolts:
		if is_instance_valid(bolt):
			bolt.queue_free()
	_dark_bolts.clear()

	velocity = Vector2.ZERO

	# Call super FIRST (handles _disabled flag, SFX, flash, EventBus)
	super._disable_enemy()

	# Override disabled timer for demon (longer regen)
	_disabled_timer = 45.0

	# Dissolve animation: sprite modulate → transparent over 1.0s (after super resets modulate)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)

	# Spawn shadow pool at death location
	var hz := preload("res://scenes/combat/hazard_zone.tscn").instantiate()
	hz.damage_per_second = 0.0
	hz.slow_factor = 0.5
	hz.duration = 45.0
	hz.zone_color = Color(0.102, 0.039, 0.165)
	hz.zone_radius = 30.0
	hz.global_position = global_position
	get_tree().current_scene.add_child(hz)


# ---------------------------------------------------------------------------
# Physics process — manage projectiles, phase, cooldowns
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if _disabled:
		_disabled_timer -= delta
		if _disabled_timer <= 0.0:
			_disabled = false
			sprite.modulate.a = 1.0
			_enter_state("patrol")
		_process_regen(delta)
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
	if _phasing:
		_phase_timer -= delta
		velocity = Vector2.ZERO
		move_and_slide()
		if _phase_timer <= 0.0:
			_finish_phase()
		return

	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_phase_cooldown = maxf(0.0, _phase_cooldown - delta)
	_state_timer -= delta

	_process_state(delta)
	_update_bolts(delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	_process_regen(delta)

	velocity += _knockback_vel

	move_and_slide()
