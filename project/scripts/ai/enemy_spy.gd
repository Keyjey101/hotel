extends "res://scripts/ai/base_enemy.gd"

## Spy — Floor 7 (Observatory / Envy) stealth assassin.
## Invisible while patrolling/chasing, decloaks before attacking, deals
## bonus backstab damage, drops smoke bombs at low HP.

# Stealth state
var _revealed: bool = false
var _reveal_timer: float = 0.0
var _reveal_duration: float = 3.0
var _decloak_tween_active: bool = false

# Smoke bomb
var _smoke_cooldown: float = 0.0
var _smoke_cooldown_max: float = 15.0
var _can_smoke: bool = true

# Backstab multiplier
var _backstab_multiplier: float = 2.5

# Mutilation flags
var _arms_lost: int = 0
var _legs_lost: int = 0

# Slow debuff tracking — reference-counted so overlapping slows don't cancel each other
var _active_slow_count: int = 0
var _slow_original_speed: float = 0.0


# Override to coordinate slow debuffs via reference counting
func apply_slow(mult: float, duration: float) -> void:
	if _slow_original_speed == 0.0:
		_slow_original_speed = move_speed
	_active_slow_count += 1
	move_speed = _slow_original_speed * mult
	var count_ref := _active_slow_count
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if not is_instance_valid(self):
			return
		if _active_slow_count != count_ref:
			return  # Another slow was applied more recently
		_active_slow_count -= 1
		if _active_slow_count <= 0:
			_active_slow_count = 0
			move_speed = _slow_original_speed
			_slow_original_speed = 0.0
	)


func _ready() -> void:
	enemy_name = "Spy"
	enemy_type = "spy"

	torso_hp = 40.0
	head_hp = 15.0
	arm_hp = 12.0
	leg_hp = 12.0
	move_speed = 160.0
	detection_range = 250.0
	attack_range = 35.0
	attack_damage = 18.0
	attack_speed = 0.8
	grab_strength = 4.0
	regen_speed_mult = 1.3
	aggression = 6.0
	coordination = 5.0

	add_to_group("spies")
	super._ready()


# ---------------------------------------------------------------------------
# Stealth helpers
# ---------------------------------------------------------------------------

func _go_invisible() -> void:
	if _revealed:
		return
	sprite.modulate.a = 0.1
	if hurtbox_manager:
		hurtbox_manager.process_mode = Node.PROCESS_MODE_DISABLED
	# Disable collision shapes while invisible (skip root physics shape)
	for child in get_children():
		if child is CollisionShape2D and child.name != "CollisionShape2D":
			child.disabled = true
	var eye := sprite.get_node_or_null("EyeGlint")
	if eye:
		eye.modulate.a = 1.0


func _go_visible() -> void:
	sprite.modulate.a = 1.0
	# Re-enable collision shapes when visible (skip root physics shape)
	for child in get_children():
		if child is CollisionShape2D and child.name != "CollisionShape2D":
			child.disabled = false
	if hurtbox_manager:
		hurtbox_manager.process_mode = Node.PROCESS_MODE_INHERIT


func _decloak() -> void:
	# Become fully visible, enable collision, play alert sound
	sprite.modulate.a = 1.0
	_revealed = true
	_reveal_timer = _reveal_duration
	# Re-enable hurtbox collision so player can hit us
	if hurtbox_manager:
		hurtbox_manager.process_mode = Node.PROCESS_MODE_INHERIT
	AudioManager.SFXPlayer.play_sfx("enemy_alert")


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _enter_state(state_name: String) -> void:
	super._enter_state(state_name)
	if state_name in ["patrol", "chase"]:
		if not _revealed:
			_go_invisible()
	elif state_name == "engage":
		# Decloak immediately when entering engage
		_decloak()


func _state_patrol(_delta: float) -> void:
	if not _revealed:
		_go_invisible()

	if _patrol_points.is_empty():
		velocity = Vector2.ZERO
		return

	var target_pos := _patrol_points[_patrol_index]
	var dir := global_position.direction_to(target_pos)
	velocity = dir * move_speed * 0.5
	_direction = dir

	if global_position.distance_to(target_pos) < 10.0:
		_patrol_index = (_patrol_index + 1) % _patrol_points.size()


func _state_chase(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	if not _revealed:
		_go_invisible()

	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * move_speed
	_direction = dir

	if global_position.distance_to(_target.global_position) <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	# Decloak before attacking
	if sprite.modulate.a < 1.0:
		if not _decloak_tween_active:
			_decloak_tween_active = true
			var tween := create_tween()
			tween.tween_property(sprite, "modulate:a", 1.0, 0.3)
			tween.tween_callback(func() -> void: _decloak_tween_active = false)
		_revealed = true
		_reveal_timer = _reveal_duration
		# Wait for decloak before attacking — mark cooldown so we don't
		# attack during the tween. Attack will happen next frame once alpha=1.
		if _attack_cooldown <= 0.0:
			_attack_cooldown = 0.35
		return

	# Attack if cooldown ready
	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	# Check if target moved out of range
	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Attack logic
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var damage := attack_damage

	# Backstab check: is spy behind the player?
	if _is_behind_player():
		damage *= _backstab_multiplier

	if _target.has_method("receive_damage"):
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false)


func _is_behind_player() -> bool:
	if _target == null or not is_instance_valid(_target):
		return false

	# Determine player's facing direction from their velocity
	var player_facing := Vector2.ZERO
	if "velocity" in _target:
		player_facing = _target.velocity.normalized()
	if player_facing == Vector2.ZERO:
		player_facing = Vector2.DOWN

	# Vector from spy to player
	var spy_to_player: Vector2 = (_target.global_position - global_position).normalized()

	# If the dot product of player_facing and spy_to_player is negative,
	# the spy is behind the player (player is facing away from the spy).
	var dot := player_facing.dot(spy_to_player)
	return dot < 0.0


# ---------------------------------------------------------------------------
# Damage override — being hit reveals the spy
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	_revealed = true
	_reveal_timer = _reveal_duration
	_go_visible()
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


# ---------------------------------------------------------------------------
# Smoke bomb ability
# ---------------------------------------------------------------------------

func _try_smoke_bomb() -> void:
	if _stunned or _disabled:
		return
	if not _can_smoke or _smoke_cooldown > 0.0:
		return
	if _arms_lost >= 2:
		return
	if limb_health[DamageZone.Zone.TORSO] >= torso_hp * 0.3:
		return
	if get_tree() == null or get_tree().current_scene == null:
		return

	_can_smoke = false
	_smoke_cooldown = _smoke_cooldown_max

	# Spawn smoke visual at current position
	var smoke := ColorRect.new()
	smoke.size = Vector2(40.0, 40.0)
	smoke.color = Color(0.5, 0.5, 0.5, 0.6)
	smoke.position = -smoke.size / 2.0
	smoke.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = global_position

	# Fade out smoke after a moment
	var smoke_tween := get_tree().current_scene.create_tween()
	smoke_tween.tween_property(smoke, "color:a", 0.0, 1.5)
	smoke_tween.tween_callback(smoke.queue_free)

	# Teleport away in a random direction
	var random_dir := Vector2.RIGHT.rotated(randf() * TAU)
	var target_pos := global_position + random_dir * 200.0
	# Validate teleport destination with physics ray check
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, target_pos, collision_mask)
	var result := space_state.intersect_ray(query)
	if result:
		target_pos = global_position + random_dir * 80.0
	global_position = target_pos
	# Reset navigation after teleport
	navigation.target_position = global_position

	# Go invisible again
	_revealed = false
	_go_invisible()


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
		if _arms_lost == 1:
			attack_speed *= 0.5
		if _arms_lost >= 2:
			_can_smoke = false

	if DamageZone.is_leg(zone):
		_legs_lost = int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_LEG])
		if _legs_lost >= 1:
			_reveal_duration = 5.0

	# Full mutilate: fully visible, helpless
	if _arms_lost >= 2 and _legs_lost >= 2:
		_revealed = true
		_reveal_timer = 9999.0
		_go_visible()


# ---------------------------------------------------------------------------
# Physics process — tick cooldowns and manage stealth
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	# Spy-specific cooldowns and timers
	_smoke_cooldown = maxf(0.0, _smoke_cooldown - delta)

	# Tick reveal timer
	if _revealed:
		_reveal_timer -= delta
		if _reveal_timer <= 0.0:
			_revealed = false
			if _current_state in ["patrol", "chase"]:
				_go_invisible()

	# Check smoke bomb conditions
	_try_smoke_bomb()

	super._physics_process(delta)
