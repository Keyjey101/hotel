extends "res://scripts/ai/base_enemy.gd"

## Boss — Attendant Prime (Floor 5: Spa/Sloth).
## Fog control boss. Invisible in fog, heals in fog, player destroys steam valves.
## Phases: Welcome (100-60%), Deep Tissue (60-25%), Checkout (25-0%).
## Design doc: 14_BOSS_DESIGN.md section 6.

# Fog system
var fog_patches: Array[Area2D] = []
var steam_valves: Array[StaticBody2D] = []
var fog_coverage: float = 0.5
var is_in_fog: bool = false
var _was_in_fog: bool = false
var fog_heal_rate: float = 5.0
var _toxic_fog: bool = false

# Phase tracking
var _phase: int = 1
var _max_torso_hp: float = 280.0

# Attack timers
var _fog_breath_timer: float = 8.0
var _steam_blast_timer: float = 12.0
var _sedative_touch_timer: float = 0.0

# Grab
var _grab_cooldown: float = 10.0
var _is_grabbing: bool = false
var _grab_timer: float = 0.0
var _is_blasting: bool = false
var _blast_pending: bool = false

# Mutilation
var _arms_lost: int = 0

# Pending steam blasts (timer-based, replacing await)
var _pending_blasts: Array[Dictionary] = []


func _ready() -> void:
	enemy_name = "Attendant Prime"
	enemy_type = "boss"

	torso_hp = 280.0
	head_hp = 50.0
	arm_hp = 50.0
	leg_hp = 50.0
	move_speed = 100.0
	detection_range = 400.0
	attack_range = 150.0
	attack_damage = 15.0
	attack_speed = 0.5
	grab_strength = 6.0
	regen_speed_mult = 1.5
	aggression = 4.0
	coordination = 7.0

	_max_torso_hp = torso_hp

	add_to_group("boss")
	super._ready()
	_create_boss_visuals()


func _create_boss_visuals() -> void:
	# Mist aura — larger than normal attendant
	var aura := ColorRect.new()
	aura.size = Vector2(32, 32)
	aura.color = Color(0.722, 0.847, 0.816, 0.3)  # #B8D8D0 alpha 0.3
	aura.position = Vector2(-16, -16)
	aura.z_index = -1
	sprite.add_child(aura)


# ---------------------------------------------------------------------------
# Physics
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_update_fog_state()
	_update_phase()
	_process_fog_healing(delta)
	_tick_timers(delta)
	_process_pending_blasts(delta)
	super._physics_process(delta)
	_update_fog_visibility()


func _update_fog_state() -> void:
	is_in_fog = false
	if hitbox == null:
		return
	var areas := hitbox.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("fog"):
			is_in_fog = true
			break

	# Update regen based on fog (only when state changes to avoid flickering)
	if is_in_fog != _was_in_fog:
		_was_in_fog = is_in_fog
		regen_speed_mult = 1.5 if is_in_fog else 0.5


func _update_phase() -> void:
	var hp_pct: float = float(limb_health[DamageZone.Zone.TORSO]) / _max_torso_hp
	var target_phase: int
	if hp_pct > 0.6:
		target_phase = 1
	elif hp_pct > 0.25:
		target_phase = 2
	else:
		target_phase = 3
	# Phase transitions are one-directional only
	if target_phase > _phase:
		_phase = target_phase
		_on_phase_changed()


func _on_phase_changed() -> void:
	match _phase:
		2:
			fog_coverage = 0.75
			_spawn_extra_fog()
		3:
			fog_coverage = 0.9
			_toxic_fog = true
			_spawn_extra_fog()
			_make_fog_toxic()


func _process_fog_healing(delta: float) -> void:
	if _disabled:
		return
	if is_in_fog and limb_health[DamageZone.Zone.TORSO] < _max_torso_hp:
		limb_health[DamageZone.Zone.TORSO] = minf(
			limb_health[DamageZone.Zone.TORSO] + fog_heal_rate * delta,
			_max_torso_hp
		)


func _tick_timers(delta: float) -> void:
	_fog_breath_timer -= delta
	_steam_blast_timer -= delta
	_grab_cooldown -= delta
	if _is_grabbing:
		_grab_timer -= delta
		if _grab_timer <= 0.0:
			_is_grabbing = false


func _update_fog_visibility() -> void:
	if sprite == null:
		return
	if is_in_fog:
		# Invisible in fog — but visible for 0.5s when attacking in phase 3
		if _phase >= 3 and _attack_cooldown > 0.5:
			sprite.modulate.a = 1.0
		else:
			sprite.modulate.a = 0.1
	else:
		sprite.modulate.a = 1.0


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	# Faster in fog
	var speed := 150.0 if is_in_fog else move_speed

	# Stop moving while telegraphing steam blast
	if _is_blasting or _blast_pending:
		velocity = Vector2.ZERO
		return

	# Move toward player but prefer to stay in fog patches
	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * speed
	_direction = dir

	if dist <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	_direction = global_position.direction_to(_target.global_position)
	velocity = Vector2.ZERO

	# Grab player into fog
	if _phase >= 2 and _grab_cooldown <= 0.0 and not _is_grabbing:
		if global_position.distance_to(_target.global_position) <= 60.0:
			_perform_grab()
			return

	# Sedative Touch — close range slow
	if global_position.distance_to(_target.global_position) <= 40.0:
		if _attack_cooldown <= 0.0:
			_perform_sedative_touch()
			_attack_cooldown = 1.0 / attack_speed
			return

	# Fog Breath — expand fog
	if _fog_breath_timer <= 0.0 and _arms_lost < 2:
		_perform_fog_breath()
		_fog_breath_timer = 8.0 if _phase < 3 else 4.0
		return

	# Steam Blast — damage from fog
	if _phase >= 2 and _steam_blast_timer <= 0.0:
		_perform_steam_blast()
		_steam_blast_timer = 10.0 if _phase < 3 else 6.0
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.5:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Fog Breath — expand existing fog zone
# ---------------------------------------------------------------------------

func _perform_fog_breath() -> void:
	if fog_patches.is_empty():
		return
	# Expand a random fog patch
	var patch: Area2D = fog_patches.pick_random()
	if not is_instance_valid(patch):
		return
	# Scale up the patch by expanding collision shape
	for child in patch.get_children():
		if child is CollisionShape2D and child.shape is CircleShape2D:
			child.shape.radius += 20.0
	# Update visual
	for child in patch.get_children():
		if child is ColorRect:
			var new_size: float = child.size.x + 40.0
			child.size = Vector2(new_size, new_size)
			child.position = Vector2(-new_size * 0.5, -new_size * 0.5)


# ---------------------------------------------------------------------------
# Sedative Touch — melee slow
# ---------------------------------------------------------------------------

func _perform_sedative_touch() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	# Apply sedative slow via event
	EventBus.player_captured.emit()
	# Also deal damage
	if _target.has_method("receive_damage"):
		_target.receive_damage(attack_damage, DamageZone.Zone.TORSO, false, 10.0, global_position.direction_to(_target.global_position))


# ---------------------------------------------------------------------------
# Steam Blast — AoE damage from fog
# ---------------------------------------------------------------------------

func _perform_steam_blast() -> void:
	if _is_blasting or _blast_pending:
		return
	_blast_pending = true
	if _target == null or not is_instance_valid(_target):
		_blast_pending = false
		return
	var dist := global_position.distance_to(_target.global_position)
	if dist > 200.0:
		return

	_is_blasting = true

	# Telegraph: brief fog ripple visual
	var telegraph := ColorRect.new()
	telegraph.size = Vector2(80, 80)
	telegraph.position = global_position - Vector2(40, 40)
	telegraph.color = Color(0.722, 0.847, 0.816, 0.5)
	telegraph.z_index = 5
	get_tree().current_scene.add_child(telegraph)

	# Store pending blast for deferred processing instead of await
	_pending_blasts.append({
		"telegraph_rect": telegraph,
		"elapsed": 0.0,
		"delay": 0.3,
	})


func _process_pending_blasts(delta: float) -> void:
	var i := _pending_blasts.size() - 1
	while i >= 0:
		var entry: Dictionary = _pending_blasts[i]
		entry["elapsed"] += delta
		if entry["elapsed"] >= entry["delay"]:
			var rect: ColorRect = entry["telegraph_rect"]
			if is_instance_valid(rect):
				rect.queue_free()
			_blast_pending = false
			_execute_steam_blast()
			_pending_blasts.remove_at(i)
		i -= 1


func _execute_steam_blast() -> void:
	if not is_instance_valid(self):
		_is_blasting = false
		return

	if _target == null or not is_instance_valid(_target):
		_is_blasting = false
		return

	# AoE damage + stun
	if _target.has_method("receive_damage"):
		_target.receive_damage(30.0, DamageZone.Zone.TORSO, false, 30.0, global_position.direction_to(_target.global_position))
	if _target.has_method("apply_stun"):
		_target.apply_stun(1.0)

	# Hazard zone for visual
	var zone = preload("res://scenes/combat/hazard_zone.tscn").instantiate()
	zone.damage_per_second = 0.0
	zone.slow_factor = 1.0
	zone.duration = 0.5
	zone.zone_color = Color(0.722, 0.847, 0.816)
	zone.zone_radius = 60.0
	zone.global_position = global_position
	get_tree().current_scene.add_child(zone)
	_is_blasting = false


# ---------------------------------------------------------------------------
# Grab — drag player into fog
# ---------------------------------------------------------------------------

func _perform_grab() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	_is_grabbing = true
	_grab_timer = 2.0
	_grab_cooldown = 10.0

	# Apply slow to player
	EventBus.player_captured.emit()

	# If in fog, extra disorientation
	if is_in_fog and _target.has_method("apply_stun"):
		_target.apply_stun(0.5)


# ---------------------------------------------------------------------------
# Fog management
# ---------------------------------------------------------------------------

func _spawn_extra_fog() -> void:
	# Spawn additional fog patches to reach target coverage
	var current_count := fog_patches.size()
	var target_count := ceili(fog_coverage * 10.0)  # Approximate

	for i in range(target_count - current_count):
		var fog := Area2D.new()
		fog.name = "FogPatch_%d" % (current_count + i)
		fog.add_to_group("fog")
		fog.position = Vector2(randf_range(-150, 150), randf_range(-120, 120))

		var shape := CircleShape2D.new()
		shape.radius = randf_range(50.0, 80.0)
		var col := CollisionShape2D.new()
		col.shape = shape
		fog.add_child(col)

		# Visual overlay
		var visual := ColorRect.new()
		var vis_size := shape.radius * 2.0
		visual.size = Vector2(vis_size, vis_size)
		visual.position = Vector2(-vis_size * 0.5, -vis_size * 0.5)
		visual.color = Color(0.722, 0.847, 0.816, 0.4)
		visual.z_index = 3
		fog.add_child(visual)

		# Store parent room/scene reference
		var parent_room := _find_room_instance()
		if parent_room:
			parent_room.add_child(fog)
		else:
			get_tree().current_scene.add_child(fog)

		fog_patches.append(fog)


func _make_fog_toxic() -> void:
	_toxic_fog = true
	# Apply toxic damage zone to all fog patches
	for patch in fog_patches:
		if not is_instance_valid(patch):
			continue
		var zone = preload("res://scenes/combat/hazard_zone.tscn").instantiate()
		zone.damage_per_second = 3.0
		zone.slow_factor = 0.7
		zone.duration = 999.0  # Effectively permanent
		zone.zone_color = Color(0.5, 0.7, 0.6, 0.3)
		zone.zone_radius = 10.0  # Small radius, zone sits inside fog patch
		zone.global_position = Vector2.ZERO  # Relative to parent
		patch.add_child(zone)


func _find_room_instance() -> RoomInstance:
	var node := get_parent()
	while node != null:
		if node is RoomInstance:
			return node
		node = node.get_parent()
	return null


# ---------------------------------------------------------------------------
# Steam valve interaction (called by external breakable objects)
# ---------------------------------------------------------------------------

func on_valve_destroyed(valve: StaticBody2D) -> void:
	steam_valves.erase(valve)
	# Remove nearest fog patch
	if not fog_patches.is_empty():
		var nearest_idx := 0
		var nearest_dist := valve.global_position.distance_to(fog_patches[0].global_position)
		for i in range(1, fog_patches.size()):
			var d := valve.global_position.distance_to(fog_patches[i].global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest_idx = i
		var patch := fog_patches.pop_at(nearest_idx) as Area2D
		if is_instance_valid(patch):
			patch.queue_free()

	# Recalculate coverage
	fog_coverage = fog_patches.size() / 10.0
	print("[Attendant Prime] Valve destroyed! Fog coverage: %.0f%%" % (fog_coverage * 100))


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_ARM])

	if DamageZone.is_leg(zone):
		# Slower but still moves in fog
		if not is_in_fog:
			move_speed = _initial_move_speed * 0.5


# ---------------------------------------------------------------------------
# Death override — clean up toxic fog hazard zones
# ---------------------------------------------------------------------------

func _disable_enemy() -> void:
	# Clean up all fog patches and their toxic hazard children
	for patch in fog_patches:
		if is_instance_valid(patch):
			patch.queue_free()
	fog_patches.clear()
	for valve in steam_valves:
		if is_instance_valid(valve):
			valve.queue_free()
	steam_valves.clear()
	super._disable_enemy()
