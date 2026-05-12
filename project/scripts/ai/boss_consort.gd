extends "res://scripts/ai/base_enemy.gd"

## Boss — The Consort (Floor 8: Ballroom/Pride).
## Squad command mechanic. 3 phases: Retinue, Court, Alone.
## Design doc: 14_BOSS_DESIGN.md section 9.

# Phase tracking
var _phase: int = 1
var _max_torso_hp: float = 200.0

# Squad command
var _guards: Array[CharacterBody2D] = []
var _command_cooldown: float = 0.0
var _command_cooldown_max: float = 8.0
var _current_command: String = "shield_wall"
var _command_rotation: Array[String] = ["shield_wall", "surround", "shield_wall"]

# Guard spawner
var _guard_scene: PackedScene = null
var _summon_cooldown: float = 0.0
var _summon_cooldown_max_p2: float = 30.0
var _is_summoning: bool = false
var _summon_channel_timer: float = 0.0
var _summon_channel_max: float = 3.0

# Phase 2 — dagger throw
var _dagger_cooldown: float = 0.0
var _dagger_cooldown_max: float = 3.0
var _dagger_damage: float = 15.0
var _dagger_range: float = 200.0

# Phase 3 — personal combat
var _rapier_damage: float = 25.0
var _fan_damage: float = 20.0
var _scream_cooldown: float = 0.0
var _scream_cooldown_max: float = 12.0

# Visuals
var _cape_visual: ColorRect
var _crown_visual: ColorRect
var _guards_spawned: bool = false


func _ready() -> void:
	enemy_name = "The Consort"
	enemy_type = "boss"

	torso_hp = 200.0
	head_hp = 35.0
	arm_hp = 35.0
	leg_hp = 35.0
	move_speed = 110.0
	detection_range = 400.0
	attack_range = 80.0  # rapier reach
	attack_damage = 25.0
	attack_speed = 0.5
	grab_strength = 3.0
	regen_speed_mult = 1.0
	aggression = 5.0
	coordination = 10.0

	_max_torso_hp = torso_hp

	add_to_group("boss")
	super._ready()

	# Pre-load Royal Guard scene
	if ResourceLoader.exists("res://scenes/enemies/royal_guard.tscn"):
		_guard_scene = load("res://scenes/enemies/royal_guard.tscn")

	# Create visuals
	_create_visuals()


func _create_visuals() -> void:
	# Cape (blood red)
	_cape_visual = ColorRect.new()
	_cape_visual.name = "Cape"
	_cape_visual.size = Vector2(22.0, 18.0)
	_cape_visual.color = Color(0.545, 0.0, 0.0, 1.0)  # #8B0000
	_cape_visual.position = Vector2(-11.0, -6.0)
	_cape_visual.z_index = -1
	sprite.add_child(_cape_visual)

	# Crown gold accent
	_crown_visual = ColorRect.new()
	_crown_visual.name = "Crown"
	_crown_visual.size = Vector2(16.0, 4.0)
	_crown_visual.color = Color(0.855, 0.647, 0.125, 1.0)  # #DAA520 gold
	_crown_visual.position = Vector2(-8.0, -22.0)
	_crown_visual.z_index = 2
	sprite.add_child(_crown_visual)


# ---------------------------------------------------------------------------
# Physics
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	# Auto-spawn initial guards on first frame
	if not _guards_spawned:
		_guards_spawned = true
		spawn_initial_guards()

	if _disabled:
		_disabled_timer -= delta
		if _disabled_timer <= 0.0:
			_disabled = false
			_enter_state("chase")
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

	# Tick cooldowns
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_command_cooldown = maxf(0.0, _command_cooldown - delta)
	_dagger_cooldown = maxf(0.0, _dagger_cooldown - delta)
	_scream_cooldown = maxf(0.0, _scream_cooldown - delta)
	_summon_cooldown = maxf(0.0, _summon_cooldown - delta)
	_state_timer -= delta

	# Summon channeling
	if _is_summoning:
		_summon_channel_timer -= delta
		if _summon_channel_timer <= 0.0:
			_complete_summon()
		velocity = Vector2.ZERO
		move_and_slide()
		_process_regen(delta)
		return

	# Clean dead guards
	_cleanup_guards()

	# Update phase
	_update_phase()

	# Issue commands (Phase 1-2)
	if _phase <= 2 and _command_cooldown <= 0.0 and _guards.size() > 0:
		_issue_next_command()

	# Phase 2 dagger throw
	if _phase == 2 and _dagger_cooldown <= 0.0:
		_throw_dagger()
		_dagger_cooldown = _dagger_cooldown_max

	# Phase 2 guard summon
	if _phase == 2 and _guards.size() < 3 and _summon_cooldown <= 0.0:
		_spawn_replacement_guard()
		_summon_cooldown = _summon_cooldown_max_p2

	# State processing
	_process_state(delta)
	_process_regen(delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	velocity += _knockback_vel

	move_and_slide()


# ---------------------------------------------------------------------------
# Phase management
# ---------------------------------------------------------------------------

func _update_phase() -> void:
	var guard_count := _guards.size()
	var new_phase: int

	if guard_count >= 3:
		new_phase = 1
	elif guard_count >= 1:
		new_phase = 2
	else:
		new_phase = 3

	if new_phase != _phase:
		_phase = new_phase
		_on_phase_changed()


func _on_phase_changed() -> void:
	match _phase:
		2:
			# Faster commands, less coordinated
			_command_cooldown_max = 4.0
			_dagger_cooldown = 0.0
			_summon_cooldown = 5.0  # Initial delay before first summon
			# Consort starts panicking visually
			sprite.modulate = Color(1.2, 1.0, 1.0, 1.0)
		3:
			# Alone — personal combat mode
			_command_cooldown_max = 999999.0  # No commands
			aggression = 9.0
			move_speed = 140.0
			attack_speed = 0.4  # Faster rapier
			# Visual: desperate
			sprite.modulate = Color(1.5, 1.2, 1.2, 1.0)
			if _current_state == "patrol":
				_enter_state("chase")


# ---------------------------------------------------------------------------
# Guard management
# ---------------------------------------------------------------------------

func spawn_initial_guards() -> void:
	# Called by FloorManager after Consort is placed in boss room
	for i in range(4):
		_spawn_guard_at_offset(i)


func _spawn_guard_at_offset(index: int) -> void:
	if _guard_scene == null:
		return

	var guard := _guard_scene.instantiate() as CharacterBody2D
	if guard == null:
		return

	# Position in formation around Consort
	var offsets: Array[Vector2] = [
		Vector2(-40.0, -30.0),
		Vector2(40.0, -30.0),
		Vector2(-40.0, 30.0),
		Vector2(40.0, 30.0),
	]
	var offset := offsets[index % offsets.size()]
	guard.global_position = global_position + offset

	# Add to parent (room) so it's not a child of Consort
	var parent := get_parent()
	if parent:
		parent.add_child(guard)

	_guards.append(guard)

	# Guard death is tracked via _cleanup_guards() which polls _disabled each frame.
	# tree_exited is unreliable here because _disable_enemy() does not call queue_free().


func _cleanup_guards() -> void:
	var i := _guards.size() - 1
	while i >= 0:
		var g := _guards[i]
		if not is_instance_valid(g) or g.get("_disabled") == true:
			_guards.remove_at(i)
		i -= 1


func _on_guard_tree_exited(guard: CharacterBody2D) -> void:
	_guards.erase(guard)


func _spawn_replacement_guard() -> void:
	if _guards.size() >= 3:
		return
	_spawn_guard_at_offset(_guards.size())


# ---------------------------------------------------------------------------
# Command system
# ---------------------------------------------------------------------------

func _issue_next_command() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	# Rotate through command patterns
	var cmd_index := randi() % _command_rotation.size()
	_current_command = _command_rotation[cmd_index]

	var target_pos: Vector2 = _target.global_position

	match _current_command:
		"shield_wall":
			_command_shield_wall()
		"surround":
			_command_surround(target_pos)
		"pinch":
			_command_pinch(target_pos)
		"royal_guard":
			_command_royal_guard(target_pos)

	_command_cooldown = _command_cooldown_max


func _command_shield_wall() -> void:
	# Guards form line in front of Consort
	var line_start := global_position + Vector2(0.0, -40.0)
	var spacing := 40.0
	var count := _guards.size()

	for i in range(count):
		var g := _guards[i]
		if not is_instance_valid(g):
			continue
		var offset_x := (i - (count - 1) * 0.5) * spacing
		var pos := line_start + Vector2(offset_x, 0.0)
		if g.has_method("receive_command"):
			g.receive_command("shield_wall", pos)


func _command_surround(target_pos: Vector2) -> void:
	# Guards encircle player
	var count := _guards.size()
	var radius := 80.0

	for i in range(count):
		var g := _guards[i]
		if not is_instance_valid(g):
			continue
		var angle := (TAU * i) / count
		var pos := target_pos + Vector2(cos(angle), sin(angle)) * radius
		if g.has_method("receive_command"):
			g.receive_command("surround", pos)


func _command_pinch(target_pos: Vector2) -> void:
	# Split guards: left half from left, right half from right
	var count := _guards.size()
	var half := count / 2
	var pinch_dist := 100.0

	for i in range(count):
		var g := _guards[i]
		if not is_instance_valid(g):
			continue
		var side: float = -1.0 if i < half else 1.0
		var offset := Vector2(side * pinch_dist, 0.0)
		var pos := target_pos + offset
		if g.has_method("receive_command"):
			g.receive_command("pinch", pos)


func _command_royal_guard(target_pos: Vector2) -> void:
	# One guard grabs player → Consort approaches → stab
	if _guards.is_empty():
		return
	var grabber := _guards[0]
	if not is_instance_valid(grabber):
		return
	if grabber.has_method("receive_command"):
		grabber.receive_command("royal_guard", target_pos)


# ---------------------------------------------------------------------------
# Phase 2 — Dagger throw
# ---------------------------------------------------------------------------

func _throw_dagger() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > _dagger_range:
		return

	var dir := global_position.direction_to(_target.global_position)

	# Create dagger projectile
	var dagger := Area2D.new()
	dagger.name = "OrnamentalDagger"
	dagger.add_to_group("enemy_hitbox")

	var shape := CircleShape2D.new()
	shape.radius = 5.0
	var col := CollisionShape2D.new()
	col.shape = shape
	dagger.add_child(col)

	var visual := ColorRect.new()
	visual.size = Vector2(8, 3)
	visual.position = Vector2(-4, -1.5)
	visual.color = Color(0.855, 0.647, 0.125, 1.0)  # gold
	dagger.add_child(visual)

	dagger.set_meta("direction", dir)
	dagger.set_meta("speed", 250.0)
	dagger.set_meta("damage", _dagger_damage)
	dagger.set_meta("source", self)

	var parent := get_parent()
	if parent:
		parent.add_child(dagger)
		dagger.global_position = global_position

	_move_projectile(dagger)


func _move_projectile(proj: Area2D) -> void:
	var speed: float = proj.get_meta("speed", 250.0)
	var dir: Vector2 = proj.get_meta("direction", Vector2.RIGHT)
	var damage: float = proj.get_meta("damage", _dagger_damage)

	var lifetime := 3.0
	var elapsed := 0.0

	while is_instance_valid(proj) and elapsed < lifetime:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		proj.global_position += dir * speed * get_process_delta_time()

		var bodies := proj.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player") and body.has_method("receive_damage"):
				body.receive_damage(damage, 0, false, 30.0, dir * -1.0)
				if is_instance_valid(proj):
					proj.queue_free()
				return

	if is_instance_valid(proj):
		proj.queue_free()


# ---------------------------------------------------------------------------
# Phase 3 — Personal combat
# ---------------------------------------------------------------------------

func _rapier_thrust() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range:
		return

	var dir := global_position.direction_to(_target.global_position)
	if _target.has_method("receive_damage"):
		_target.receive_damage(_rapier_damage, 0, false, 60.0, dir * -1.0)

	# Visual flash
	sprite.modulate = Color(1.0, 1.5, 1.5, 1.0)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.5, 1.2, 1.2, 1.0), 0.15)


func _fan_swipe() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.2:
		return

	# Cone attack — check if player is within frontal 120° arc
	var dir_to_target := global_position.direction_to(_target.global_position)
	var dot := _direction.normalized().dot(dir_to_target)
	if dot > 0.5:  # Within 120° cone
		if _target.has_method("receive_damage"):
			_target.receive_damage(_fan_damage, 0, false, 100.0, dir_to_target * -1.0)


func _desperate_scream() -> void:
	# AoE stun in radius 60px
	var scream_radius := 60.0
	var targets := get_tree().get_nodes_in_group("player")
	for body in targets:
		if not is_instance_valid(body):
			continue
		var dist := global_position.distance_to(body.global_position)
		if dist <= scream_radius:
			if body.has_method("apply_stun"):
				body.apply_stun(0.5)

	# Visual feedback
	sprite.modulate = Color(2.0, 2.0, 2.0, 1.0)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.5, 1.2, 1.2, 1.0), 0.3)

	_scream_cooldown = _scream_cooldown_max


func _start_summon_channel() -> void:
	_is_summoning = true
	_summon_channel_timer = _summon_channel_max

	# Visual: channeling glow
	sprite.modulate = Color(1.5, 1.5, 0.8, 1.0)


func _complete_summon() -> void:
	_is_summoning = false
	sprite.modulate = Color(1.5, 1.2, 1.2, 1.0)

	if not _guards.is_empty():
		return  # Only summon if all guards are dead

	_spawn_guard_at_offset(0)


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	match _phase:
		1:
			# Stay behind guards — move to safety position
			var safe_pos := _get_safe_position()
			navigation.target_position = safe_pos
			var next_pos := navigation.get_next_path_position()
			var dir := global_position.direction_to(next_pos)
			velocity = dir * move_speed
			_direction = dir
		2:
			# More aggressive positioning
			var safe_pos := _get_safe_position()
			navigation.target_position = safe_pos
			var next_pos := navigation.get_next_path_position()
			var dir := global_position.direction_to(next_pos)
			velocity = dir * move_speed * 1.2
			_direction = dir
		3:
			# Personal chase — fast
			navigation.target_position = _target.global_position
			var next_pos := navigation.get_next_path_position()
			var dir := global_position.direction_to(next_pos)
			velocity = dir * move_speed
			_direction = dir

			var dist := global_position.distance_to(_target.global_position)
			if dist <= attack_range:
				_enter_state("engage")


func _state_engage(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	match _phase:
		1:
			# Don't attack directly — issue commands only
			if global_position.distance_to(_target.global_position) > attack_range * 3.0:
				_enter_state("chase")
		2:
			# Throw daggers
			if _dagger_cooldown <= 0.0:
				_throw_dagger()
				_dagger_cooldown = _dagger_cooldown_max
			if global_position.distance_to(_target.global_position) > attack_range * 3.0:
				_enter_state("chase")
		3:
			# Personal combat
			if _attack_cooldown <= 0.0:
				if randf() < 0.6:
					_rapier_thrust()
				else:
					_fan_swipe()
				_attack_cooldown = attack_speed

			# Summon if no guards
			if _guards.is_empty() and _summon_cooldown <= 0.0 and not _is_summoning:
				_start_summon_channel()

			# Scream
			if _scream_cooldown <= 0.0:
				var dist := global_position.distance_to(_target.global_position)
				if dist <= 70.0:
					_desperate_scream()

			# Re-chase if target moves away
			if global_position.distance_to(_target.global_position) > attack_range * 1.5:
				_enter_state("chase")


func _perform_attack() -> void:
	if _phase == 3:
		if randf() < 0.6:
			_rapier_thrust()
		else:
			_fan_swipe()


# ---------------------------------------------------------------------------
# Safe position (stay behind guards)
# ---------------------------------------------------------------------------

func _get_safe_position() -> Vector2:
	if _target == null or not is_instance_valid(_target):
		return global_position

	# Position self opposite the player, behind guards
	var to_player := global_position.direction_to(_target.global_position)
	var away_from_player := to_player * -1.0
	return global_position + away_from_player * 60.0


# ---------------------------------------------------------------------------
# Damage override — cancel summon channel
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	# Cancel summon channel on hit
	if _is_summoning:
		_is_summoning = false
		sprite.modulate = Color(1.5, 1.2, 1.2, 1.0)

	# Reposition nearest guard between Consort and player
	if knockback_dir != Vector2.ZERO and _guards.size() > 0:
		var closest: CharacterBody2D = null
		var closest_dist := 999999.0
		for g in _guards:
			if not is_instance_valid(g):
				continue
			var d := global_position.distance_to(g.global_position)
			if d < closest_dist:
				closest = g
				closest_dist = d
		if closest and closest.has_method("receive_command"):
			closest.receive_command("shield_wall", global_position + knockback_dir * -30.0)

	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


# ---------------------------------------------------------------------------
# Death
# ---------------------------------------------------------------------------

func _disable_enemy() -> void:
	# Remaining guards go berserk
	for g in _guards:
		if is_instance_valid(g) and not g._disabled:
			g.aggression += 3.0
			g._in_shield_wall = false
			if g.has_method("receive_command"):
				g.receive_command("surround", g.global_position)

	EventBus.mini_boss_defeated.emit(8)
	super._disable_enemy()


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	var arms_lost := int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
		int(severed_limbs[DamageZone.Zone.RIGHT_ARM])

	if arms_lost >= 1:
		_dagger_cooldown_max = 5.0  # Slower throws with one arm

	if arms_lost >= 2:
		_dagger_damage = 0.0  # Can't throw without arms
		# Switch to scream-based combat
		_scream_cooldown_max = 8.0


func _evaluate_mutilated_behavior() -> void:
	# Consort stays aggressive — no retreat
	if _current_state in ["patrol", "retreat"]:
		_enter_state("chase")
