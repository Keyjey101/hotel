extends "res://scripts/ai/base_enemy.gd"

## Banker enemy — Floor 4 (Vault/Greed).
## Does NOT fight directly; activates environmental traps via HazardZone.
## Evasive movement, summons Vault Drones after a channel.

# Trap types
const TRAP_TYPES: Array[String] = ["spike_wall", "crusher_ceiling", "lockdown"]

const HAZARD_SCENE := preload("res://scenes/combat/hazard_zone.tscn")
const DRONE_SCENE := preload("res://scenes/enemies/vault_drone.tscn")

# Ability cooldowns
var _trap_cooldown: float = 0.0
var _summon_cooldown: float = 0.0
var _summon_channel: float = 0.0
var _is_summoning: bool = false

# Evasion strafe state
var _strafe_dir: float = 1.0
var _strafe_timer: float = 0.0

# Mutilation state
var _arms_lost: int = 0

# Seeded RNG
var _rng: RandomNumberGenerator


func _ready() -> void:
	enemy_name = "Banker"
	enemy_type = "banker"

	torso_hp = 50.0
	head_hp = 20.0
	arm_hp = 12.0
	leg_hp = 12.0
	move_speed = 100.0
	detection_range = 250.0
	attack_range = 200.0
	attack_damage = 15.0
	attack_speed = 0.3
	grab_strength = 1.0
	regen_speed_mult = 1.0
	aggression = 3.0
	coordination = 9.0

	add_to_group("bankers")
	super._ready()
	_rng = RandomNumberGenerator.new()
	if GameManager.seed_manager:
		_rng.seed = GameManager.seed_manager.get_seed() + hash("banker")
	_create_pocket_watch()


func _create_pocket_watch() -> void:
	var watch := ColorRect.new()
	watch.size = Vector2(4, 4)
	watch.color = Color(0.855, 0.647, 0.125)  # Gold #DAA520
	watch.position = Vector2(4, -2)
	watch.z_index = 1
	sprite.add_child(watch)


# ---------------------------------------------------------------------------
# Physics update
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_tick_cooldowns(delta)
	_process_summon_channel(delta)
	_update_strafe(delta)
	super._physics_process(delta)


func _tick_cooldowns(delta: float) -> void:
	if _trap_cooldown > 0.0:
		_trap_cooldown -= delta
	if _summon_cooldown > 0.0:
		_summon_cooldown -= delta


func _update_strafe(delta: float) -> void:
	_strafe_timer -= delta
	if _strafe_timer <= 0.0:
		_strafe_dir *= -1.0
		_strafe_timer = _rng.randf_range(0.5, 1.5)


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	# Keep distance at 150-200px from player
	var dist := global_position.distance_to(_target.global_position)
	var dir_to_player := global_position.direction_to(_target.global_position)

	if dist < 150.0:
		# Too close — back away while strafing
		var away := -dir_to_player
		var strafe := Vector2(-dir_to_player.y, dir_to_player.x) * _strafe_dir
		velocity = (away + strafe * 0.6).normalized() * move_speed
	elif dist > 220.0:
		# Too far — approach with strafe
		navigation.target_position = _target.global_position
		var next_pos := navigation.get_next_path_position()
		var move_dir := global_position.direction_to(next_pos)
		var strafe := Vector2(-move_dir.y, move_dir.x) * _strafe_dir
		velocity = (move_dir + strafe * 0.4).normalized() * move_speed
	else:
		# Sweet spot — strafe sideways
		var strafe := Vector2(-dir_to_player.y, dir_to_player.x) * _strafe_dir
		velocity = strafe * move_speed

	_direction = dir_to_player

	# Switch to engage when within trap range
	if dist <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	# Never stand still — always strafe around player
	var dir_to_player := global_position.direction_to(_target.global_position)
	var strafe := Vector2(-dir_to_player.y, dir_to_player.x) * _strafe_dir
	velocity = strafe * move_speed
	_direction = dir_to_player

	# Activate traps on cooldown (requires arms)
	if _trap_cooldown <= 0.0 and _arms_lost < 2:
		_perform_attack()

	# Summon on separate cooldown
	if _summon_cooldown <= 0.0 and not _is_summoning:
		_start_summon_channel()

	# Retreat to preferred distance if too close
	var dist := global_position.distance_to(_target.global_position)
	if dist < 100.0:
		velocity = (-dir_to_player + strafe * 0.3).normalized() * move_speed

	# If target moved out of trap range, chase
	if dist > attack_range * 1.3:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Traps
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _arms_lost >= 2:
		return
	var trap_type: String = TRAP_TYPES.pick_random()
	activate_trap(trap_type)
	_trap_cooldown = 1.0 / attack_speed


func activate_trap(trap_type: String) -> void:
	match trap_type:
		"spike_wall":
			_spawn_hazard_at_player(30.0, 1.0, Color.GRAY, 40.0)
		"crusher_ceiling":
			_spawn_hazard_at_player(50.0, 0.5, Color.DIM_GRAY, 50.0)
		"lockdown":
			_activate_lockdown()


func _activate_lockdown() -> void:
	var room: RoomInstance = get_tree().get_first_node_in_group("active_room")
	if room == null:
		# Fallback: walk up scene tree
		var node := get_parent()
		while node != null:
			if node is RoomInstance and node.is_active:
				room = node
				break
			node = node.get_parent()
	if room == null:
		return
	# Lock all doors in the room
	for door in room.doors:
		if door is Area2D:
			door.set_meta("lockdown_sealed", true)
			door.monitoring = false
			for child in door.get_children():
				if child is ColorRect:
					child.color = Color(0.5, 0.1, 0.1, 0.9)
	AudioManager.SFXPlayer.play_sfx_2d("door_close", global_position, 200.0)
	# Unlock after 4 seconds
	get_tree().create_timer(4.0).timeout.connect(func() -> void:
		if not is_instance_valid(room):
			return
		for door in room.doors:
			if door is Area2D and door.get_meta("lockdown_sealed", false):
				door.set_meta("lockdown_sealed", false)
				door.monitoring = true
				for child in door.get_children():
					if child is ColorRect:
						child.color = Color(0.8, 0.6, 0.2, 0.6)
	)


func _spawn_hazard_at_player(dps: float, dur: float, col: Color, radius: float) -> void:
	var zone: Area2D = HAZARD_SCENE.instantiate()

	zone.damage_per_second = dps
	zone.slow_factor = 1.0
	zone.duration = dur
	zone.zone_color = col
	zone.zone_radius = radius

	# Spawn at player position if target is valid, else at self
	if _target != null and is_instance_valid(_target):
		zone.global_position = _target.global_position
	else:
		zone.global_position = global_position

	get_tree().current_scene.add_child(zone)


# ---------------------------------------------------------------------------
# Summon
# ---------------------------------------------------------------------------

func _start_summon_channel() -> void:
	_is_summoning = true
	_summon_channel = 5.0
	# Visual telegraph
	if sprite:
		sprite.modulate = Color(1.0, 0.85, 0.3)


func _process_summon_channel(delta: float) -> void:
	if not _is_summoning:
		return

	_summon_channel -= delta
	if _summon_channel <= 0.0:
		_is_summoning = false
		_summon_cooldown = 15.0
		if sprite:
			sprite.modulate = Color.WHITE
		_spawn_vault_drones()


func _spawn_vault_drones() -> void:
	var room: RoomInstance = null
	var node := get_parent()
	while node != null:
		if node is RoomInstance and node.is_active:
			room = node
			break
		node = node.get_parent()

	for i in range(2):
		var offset := Vector2(_rng.randf_range(-80, 80), _rng.randf_range(-80, 80))
		var drone: CharacterBody2D = DRONE_SCENE.instantiate()
		if drone == null:
			continue
		drone.global_position = global_position + offset
		if room != null:
			room.add_child(drone)
			room.active_enemies.append(drone)
		else:
			get_tree().current_scene.add_child(drone)


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
				int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
		# Arms lost: cannot trigger traps, but can still summon

	if DamageZone.is_leg(zone):
		# Float mechanism — override the speed reduction from base class
		move_speed = _initial_move_speed


func _evaluate_mutilated_behavior() -> void:
	# Banker keeps engaging regardless — traps become summon-only when arms lost
	if _arms_lost >= 2:
		# No trap activation but can still summon with voice
		if _current_state in ["patrol", "retreat"]:
			_enter_state("engage")
	else:
		_enter_state("engage")
