extends "res://scripts/ai/base_enemy.gd"

## Boss — The Accountant (Floor 4: Vault/Greed).
## Trap-activator boss. Constantly evades, triggers traps, summons Vault Drones.
## Phases: Audit (100-50%), Foreclosure (50-25%), Bankruptcy (25-0%).
## Design doc: 14_BOSS_DESIGN.md section 5.

# Trap system
var trap_zones: Array = []
var lockdown_doors: Array[Area2D] = []
var trap_cooldowns: Dictionary = {
	"spike_wall": 0.0,
	"crusher": 0.0,
	"lockdown": 0.0,
}
const TRAP_COOLDOWNS := {
	"spike_wall": 8.0,
	"crusher": 12.0,
	"lockdown": 15.0,
}

# Summon
var _summon_timer: float = 20.0
var _summon_scene: PackedScene = null

# Pistol
var _pistol_timer: float = 4.0
const PISTOL_DAMAGE: float = 10.0

# Gold bar throw
var _gold_throw_timer: float = 0.0
const GOLD_BAR_DAMAGE: float = 25.0

# Evasion
var _strafe_dir: float = 1.0
var _strafe_timer: float = 0.0

# Breakable walls (Phase 2 reveals)
var _breakable_walls: Array[StaticBody2D] = []
var _walls_revealed: bool = false

# Phase tracking
var _phase: int = 1
var _max_torso_hp: float = 200.0

# Mutilation
var _arms_lost: int = 0


func _ready() -> void:
	enemy_name = "The Accountant"
	enemy_type = "boss"

	torso_hp = 200.0
	head_hp = 40.0
	arm_hp = 40.0
	leg_hp = 40.0
	move_speed = 160.0
	detection_range = 400.0
	attack_range = 200.0
	attack_damage = 10.0
	attack_speed = 0.3
	grab_strength = 1.0
	regen_speed_mult = 1.0
	aggression = 3.0
	coordination = 9.0

	_max_torso_hp = torso_hp

	add_to_group("boss")
	super._ready()
	_create_boss_visuals()

	# Pre-load summon scene
	if ResourceLoader.exists("res://scenes/enemies/vault_drone.tscn"):
		_summon_scene = load("res://scenes/enemies/vault_drone.tscn")


func _create_boss_visuals() -> void:
	# Pocket watch at hand
	var watch := ColorRect.new()
	watch.size = Vector2(4, 4)
	watch.color = Color(1.0, 0.843, 0.0)  # #FFD700 gold
	watch.position = Vector2(4, -2)
	watch.z_index = 1
	sprite.add_child(watch)


# ---------------------------------------------------------------------------
# Physics
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_tick_trap_cooldowns(delta)
	_tick_summon_timer(delta)
	_tick_pistol_timer(delta)
	_update_strafe(delta)
	_update_phase()
	super._physics_process(delta)


func _tick_trap_cooldowns(delta: float) -> void:
	for trap_type in trap_cooldowns:
		if trap_cooldowns[trap_type] > 0.0:
			trap_cooldowns[trap_type] -= delta


func _tick_summon_timer(delta: float) -> void:
	_summon_timer -= delta


func _tick_pistol_timer(delta: float) -> void:
	_pistol_timer -= delta


func _update_strafe(delta: float) -> void:
	_strafe_timer -= delta
	if _strafe_timer <= 0.0:
		_strafe_dir *= -1.0
		_strafe_timer = randf_range(0.5, 1.5)


func _update_phase() -> void:
	var hp_pct: float = float(limb_health[DamageZone.Zone.TORSO]) / _max_torso_hp
	var new_phase: int
	if hp_pct > 0.5:
		new_phase = 1
	elif hp_pct > 0.25:
		new_phase = 2
	else:
		new_phase = 3

	if new_phase != _phase:
		_phase = new_phase
		_on_phase_changed()


func _on_phase_changed() -> void:
	match _phase:
		2:
			# Reveal breakable walls
			if not _walls_revealed:
				_reveal_breakable_walls()
		3:
			# Activate all traps simultaneously
			_activate_all_traps()


# ---------------------------------------------------------------------------
# State overrides — constant evasion
# ---------------------------------------------------------------------------

func _state_chase(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)
	var dir_to_player := global_position.direction_to(_target.global_position)

	if dist < 150.0:
		var away := -dir_to_player
		var strafe := Vector2(-dir_to_player.y, dir_to_player.x) * _strafe_dir
		velocity = (away + strafe * 0.6).normalized() * move_speed
	elif dist > 220.0:
		navigation.target_position = _target.global_position
		var next_pos := navigation.get_next_path_position()
		var move_dir := global_position.direction_to(next_pos)
		var strafe := Vector2(-move_dir.y, move_dir.x) * _strafe_dir
		velocity = (move_dir + strafe * 0.4).normalized() * move_speed
	else:
		var strafe := Vector2(-dir_to_player.y, dir_to_player.x) * _strafe_dir
		velocity = strafe * move_speed

	_direction = dir_to_player

	if dist <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dir_to_player := global_position.direction_to(_target.global_position)
	var strafe := Vector2(-dir_to_player.y, dir_to_player.x) * _strafe_dir
	velocity = strafe * move_speed
	_direction = dir_to_player

	# Activate traps (requires arms)
	if _arms_lost < 2:
		_try_activate_traps()

	# Pistol shot
	if _pistol_timer <= 0.0:
		_fire_pistol()
		_pistol_timer = randf_range(4.0, 5.0)

	# Summon Vault Drones
	if _summon_timer <= 0.0:
		_summon_drones()
		_summon_timer = 20.0 if _phase < 3 else 12.0

	# Phase 2+: Gold bar throw
	if _phase >= 2 and _gold_throw_timer <= 0.0:
		_throw_gold_bar()
		_gold_throw_timer = 6.0 if _phase == 2 else 3.0

	# Phase 3: Gold bar barrage
	if _phase >= 3:
		if _gold_throw_timer <= 0.0:
			_gold_bar_barrage()
			_gold_throw_timer = 8.0

	# Retreat if too close
	var dist := global_position.distance_to(_target.global_position)
	if dist < 100.0:
		velocity = (-dir_to_player + strafe * 0.3).normalized() * move_speed

	if dist > attack_range * 1.3:
		_enter_state("chase")


func _state_patrol(_delta: float) -> void:
	# Boss doesn't patrol — always evade toward center of arena
	velocity = Vector2.ZERO


# ---------------------------------------------------------------------------
# Traps
# ---------------------------------------------------------------------------

func _try_activate_traps() -> void:
	match _phase:
		1:
			if trap_cooldowns["spike_wall"] <= 0.0:
				activate_trap("spike_wall")
				trap_cooldowns["spike_wall"] = TRAP_COOLDOWNS["spike_wall"]
			elif trap_cooldowns["crusher"] <= 0.0:
				activate_trap("crusher")
				trap_cooldowns["crusher"] = TRAP_COOLDOWNS["crusher"]
		2:
			# Half cooldowns
			for trap_type in trap_cooldowns:
				if trap_cooldowns[trap_type] <= 0.0:
					activate_trap(trap_type)
					trap_cooldowns[trap_type] = TRAP_COOLDOWNS[trap_type] * 0.5
					break
		3:
			# All traps cycle with halved cooldowns
			for trap_type in trap_cooldowns:
				if trap_cooldowns[trap_type] <= 0.0:
					activate_trap(trap_type)
					trap_cooldowns[trap_type] = TRAP_COOLDOWNS[trap_type] * 0.5


func activate_trap(trap_type: String) -> void:
	match trap_type:
		"spike_wall":
			_spawn_hazard_at_player(30.0, 1.5, Color.GRAY, 40.0, 0.5)
		"crusher":
			_spawn_hazard_at_player(50.0, 0.8, Color.DIM_GRAY, 50.0, 1.0)
		"lockdown":
			_activate_lockdown()


func _activate_lockdown() -> void:
	var room: RoomInstance = null
	var node := get_parent()
	while node != null:
		if node is RoomInstance and node.is_active:
			room = node
			break
		node = node.get_parent()
	if room == null:
		room = get_tree().get_first_node_in_group("active_room")
	if room == null:
		return
	for door in room.doors:
		if door is Area2D:
			door.set_meta("lockdown_sealed", true)
			door.monitoring = false
			for child in door.get_children():
				if child is ColorRect:
					child.color = Color(0.5, 0.1, 0.1, 0.9)
	AudioManager.SFXPlayer.play_sfx_2d("door_close", global_position, 200.0)
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


func _activate_all_traps() -> void:
	for trap_type in trap_cooldowns:
		activate_trap(trap_type)
		trap_cooldowns[trap_type] = TRAP_COOLDOWNS[trap_type] * 0.5


func _spawn_hazard_at_player(dps: float, dur: float, col: Color, radius: float, telegraph: float = 0.0) -> void:
	var target_pos: Vector2 = global_position
	if _target != null and is_instance_valid(_target):
		target_pos = _target.global_position

	# Telegraph: spawn visual indicator first
	if telegraph > 0.0:
		var telegraph_rect := ColorRect.new()
		telegraph_rect.size = Vector2(radius * 2, radius * 2)
		telegraph_rect.position = target_pos - Vector2(radius, radius)
		telegraph_rect.color = Color(col.r, col.g, col.b, 0.3)
		telegraph_rect.z_index = 5
		get_tree().current_scene.add_child(telegraph_rect)
		# Delay before actual hazard
		await get_tree().create_timer(telegraph, true, false, true).timeout
		if is_instance_valid(telegraph_rect):
			telegraph_rect.queue_free()

	if not is_instance_valid(self) or _disabled:
		return

	var zone = load("res://scripts/combat/hazard_zone.gd").new()
	zone.damage_per_second = dps
	zone.slow_factor = 1.0
	zone.duration = dur
	zone.zone_color = col
	zone.zone_radius = radius
	zone.global_position = target_pos
	get_tree().current_scene.add_child(zone)
	trap_zones.append(zone)


# ---------------------------------------------------------------------------
# Pistol
# ---------------------------------------------------------------------------

func _fire_pistol() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	if _target.has_method("receive_damage"):
		_target.receive_damage(PISTOL_DAMAGE, DamageZone.Zone.TORSO, false, 5.0, global_position.direction_to(_target.global_position))


# ---------------------------------------------------------------------------
# Gold Bar Throw
# ---------------------------------------------------------------------------

func _throw_gold_bar() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var dir := global_position.direction_to(_target.global_position)
	_spawn_gold_projectile(dir, GOLD_BAR_DAMAGE)


func _gold_bar_barrage() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var base_dir := global_position.direction_to(_target.global_position)
	for i in range(5):
		var spread := deg_to_rad(randf_range(-30.0, 30.0))
		var dir := base_dir.rotated(spread)
		_spawn_gold_projectile(dir, 15.0)


func _spawn_gold_projectile(dir: Vector2, damage: float) -> void:
	var proj := Area2D.new()
	proj.name = "GoldBar"
	proj.position = global_position
	proj.add_to_group("projectiles")

	var shape := RectangleShape2D.new()
	shape.size = Vector2(8, 4)
	var col := CollisionShape2D.new()
	col.shape = shape
	proj.add_child(col)

	var visual := ColorRect.new()
	visual.size = Vector2(8, 4)
	visual.position = Vector2(-4, -2)
	visual.color = Color(1.0, 0.843, 0.0)  # #FFD700 gold
	proj.add_child(visual)

	proj.set_meta("damage", damage)
	proj.set_meta("direction", dir)
	proj.set_meta("speed", 200.0)
	proj.set_meta("lifetime", 3.0)

	proj.body_entered.connect(_on_gold_bar_hit.bind(proj))

	get_tree().current_scene.add_child(proj)
	# Manual movement via scene tree — simple projectile
	_move_projectile.bind(proj).call_deferred()


func _move_projectile(proj: Area2D) -> void:
	if not is_instance_valid(proj):
		return
	var dir: Vector2 = proj.get_meta("direction", Vector2.RIGHT)
	var speed: float = proj.get_meta("speed", 200.0)
	var lifetime: float = proj.get_meta("lifetime", 3.0)
	var elapsed := 0.0

	while is_instance_valid(proj) and elapsed < lifetime:
		proj.position += dir * speed * get_process_delta_time()
		elapsed += get_process_delta_time()
		await get_tree().process_frame

	if is_instance_valid(proj):
		proj.queue_free()


func _on_gold_bar_hit(body: Node2D, proj: Area2D) -> void:
	if body.is_in_group("player"):
		var damage: float = proj.get_meta("damage", 15.0)
		if body.has_method("receive_damage"):
			body.receive_damage(damage, DamageZone.Zone.TORSO, false, 20.0, global_position.direction_to(body.global_position))
	if is_instance_valid(proj):
		proj.queue_free()


# ---------------------------------------------------------------------------
# Summon
# ---------------------------------------------------------------------------

func _summon_drones() -> void:
	var count := 1 if _phase < 2 else 2
	if _summon_scene == null:
		return

	# Find active room for tracking spawned enemies
	var room: RoomInstance = null
	var node := get_parent()
	while node != null:
		if node is RoomInstance and node.is_active:
			room = node
			break
		node = node.get_parent()

	for i in range(count):
		var offset := Vector2(randf_range(-80, 80), randf_range(-80, 80))
		var drone := _summon_scene.instantiate() as CharacterBody2D
		if drone != null:
			drone.global_position = global_position + offset
			if room != null:
				room.add_child(drone)
				room.active_enemies.append(drone)
			else:
				get_tree().current_scene.add_child(drone)


# ---------------------------------------------------------------------------
# Breakable walls (Phase 2)
# ---------------------------------------------------------------------------

func _reveal_breakable_walls() -> void:
	_walls_revealed = true
	for wall in _breakable_walls:
		if is_instance_valid(wall):
			# Show cracks visual (make visible)
			var visual := wall.find_child("CrackVisual", false, false) as ColorRect
			if visual:
				visual.visible = true


# ---------------------------------------------------------------------------
# Phase 3 trap deactivation based on HP
# ---------------------------------------------------------------------------

func _process_phase3_trap_decay() -> void:
	if _phase < 3:
		return
	# Each 5% HP lost = 1 trap zone deactivates
	var hp_pct: float = float(limb_health[DamageZone.Zone.TORSO]) / _max_torso_hp
	var zones_to_keep := ceili(hp_pct / 0.05)
	while trap_zones.size() > zones_to_keep and not trap_zones.is_empty():
		var zone = trap_zones.pop_back()
		if is_instance_valid(zone):
			zone.queue_free()


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
		# Arms lost: no trap trigger, still summons + throws gold

	if DamageZone.is_leg(zone):
		# Float mechanism — keeps moving
		move_speed = _initial_move_speed


func _evaluate_mutilated_behavior() -> void:
	# Accountant keeps evading regardless
	if _current_state in ["patrol", "retreat"]:
		_enter_state("engage")
