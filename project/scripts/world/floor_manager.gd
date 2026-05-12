class_name FloorManager
extends Node

## FloorManager — Loads and manages a floor's rooms, transitions, route gates.
## M3.2: Floor 1 — Service Underground.

@export var floor_number: int = 1

var rooms: Dictionary = {}          # room_id -> RoomInstance
var active_room_id: String = ""
var room_configs: Dictionary = {}   # room_id -> RoomConfig
var route_gates: Dictionary = {}    # branch -> bool (true = open)
var key_location: String = ""       # room_id where the key spawns
var has_key: bool = false
var _boss_unlocked: bool = false

# Enemy scene paths
const ENEMY_SCENES: Dictionary = {
	"staff": "res://scenes/enemies/staff.tscn",
	"guard": "res://scenes/enemies/guard.tscn",
	"handler": "res://scenes/enemies/handler.tscn",
	"head_chef": "res://scenes/enemies/head_chef.tscn",
	"seductress": "res://scenes/enemies/seductress.tscn",
	"bodyguard": "res://scenes/enemies/bodyguard.tscn",
	"madame": "res://scenes/bosses/boss_madame.tscn",
	"chef": "res://scenes/enemies/chef.tscn",
	"taster": "res://scenes/enemies/taster.tscn",
	"gourmand": "res://scenes/bosses/boss_gourmand.tscn",
	# Floor 4 — Vault (M7.2)
	"banker": "res://scenes/enemies/banker.tscn",
	"vault_drone": "res://scenes/enemies/vault_drone.tscn",
	"accountant": "res://scenes/bosses/boss_accountant.tscn",
	# Floor 5 — Spa (M7.2)
	"attendant": "res://scenes/enemies/attendant.tscn",
	"drowned_one": "res://scenes/enemies/drowned_one.tscn",
	"attendant_prime": "res://scenes/bosses/boss_attendant_prime.tscn",
	# Floor 6 — Arena (M7.2)
	"gladiator": "res://scenes/enemies/gladiator.tscn",
	"berserker": "res://scenes/enemies/berserker.tscn",
	"champion": "res://scenes/bosses/boss_champion.tscn",
	# Floor 7 — Observatory (M7.4)
	"spy": "res://scenes/enemies/spy.tscn",
	"shadow_stalker": "res://scenes/enemies/shadow_stalker.tscn",
	"cultist": "res://scenes/enemies/cultist.tscn",
	"curator": "res://scenes/bosses/boss_curator.tscn",
	# Floor 8 — Ballroom (M7.5)
	"royal_guard": "res://scenes/enemies/royal_guard.tscn",
	"champion_enemy": "res://scenes/enemies/champion.tscn",
	"consort": "res://scenes/bosses/boss_consort.tscn",
	# Floor 9 — Satan's Sanctum (M7.6)
	"demon": "res://scenes/enemies/demon.tscn",
	"sister": "res://scenes/bosses/boss_sister.tscn",
	"satan": "res://scenes/bosses/boss_satan.tscn",
}


func _ready() -> void:
	EventBus.room_cleared.connect(_on_event_bus_room_cleared)

	# Auto-load floor if GameManager has a run active
	if GameManager.seed_manager and GameManager.current_state == GameManager.GameState.PLAYING:
		load_floor(floor_number, GameManager.seed_manager)

	# Spawn player at PlayerSpawn marker
	var spawn_node := get_node_or_null("PlayerSpawn")
	if spawn_node != null:
		spawn_player(spawn_node.global_position)

	# Register camera in group for follow system
	var cam := get_node_or_null("Camera")
	if cam:
		cam.add_to_group("camera")

	# Show tutorial on first run, Floor 1
	if floor_number == 1:
		var settings := SaveManager.get_settings()
		if not settings.get("tutorial_shown", false):
			_show_tutorial()


func spawn_player(spawn_pos: Vector2) -> void:
	# Don't spawn if player already exists (e.g. scene reload)
	if get_tree().get_first_node_in_group("player") != null:
		return

	var player_scene := preload("res://scenes/player/player.tscn")
	var player := player_scene.instantiate()
	player.add_to_group("player")
	player.global_position = spawn_pos
	# Add as child of Floor root, not inside Rooms
	add_child(player)
	print("[FloorManager] Player spawned at %s" % spawn_pos)


func load_floor(floor_num: int, seed_mgr: SeedManager) -> void:
	floor_number = floor_num
	rooms.clear()
	room_configs.clear()
	active_room_id = ""
	has_key = false
	_boss_unlocked = false

	# 1. Load room configs
	if floor_num == 1:
		room_configs = load("res://scripts/world/floor_01_config.gd").get_floor_01_rooms()
	elif floor_num == 2:
		room_configs = load("res://scripts/world/floor_02_config.gd").get_floor_02_rooms()
	elif floor_num == 3:
		room_configs = load("res://scripts/world/floor_03_config.gd").get_floor_03_rooms()
	elif floor_num == 4:
		room_configs = load("res://scripts/world/floor_04_config.gd").get_floor_04_rooms()
	elif floor_num == 5:
		room_configs = load("res://scripts/world/floor_05_config.gd").get_floor_05_rooms()
	elif floor_num == 6:
		room_configs = load("res://scripts/world/floor_06_config.gd").get_floor_06_rooms()
	elif floor_num == 7:
		room_configs = load("res://scripts/world/floor_07_config.gd").get_floor_07_rooms()
	elif floor_num == 8:
		room_configs = load("res://scripts/world/floor_08_config.gd").get_floor_08_rooms()
	elif floor_num == 9:
		room_configs = load("res://scripts/world/floor_09_config.gd").get_floor_09_rooms()
	else:
		push_error("FloorManager: floor %d config not implemented" % floor_num)
		return

	# 2. Determine route gates: 2 of 3 branches (b/c/d) open, 1 closed
	_setup_route_gates(seed_mgr)

	# 3. Determine key location (seed-based between B2, C2, D2)
	_setup_key_location(seed_mgr)

	# 4. Create rooms programmatically
	var rooms_container := get_node_or_null("Rooms")
	if rooms_container == null:
		rooms_container = Node2D.new()
		rooms_container.name = "Rooms"
		add_child(rooms_container)

	for room_id in room_configs:
		var config: RoomConfig = room_configs[room_id]

		# Skip rooms on closed branch
		if config.branch in ["b", "c", "d"] and not route_gates.get(config.branch, false):
			continue

		var room_instance := RoomInstance.new()
		room_instance.setup_from_config(config)
		rooms_container.add_child(room_instance)

		# Floor 7: apply darkness zones, cameras, light sources
		if floor_num == 7:
			load("res://scripts/world/floor_07_config.gd").apply_floor_07_extras(room_instance)
		# Floor 8: apply chandeliers, carpet, gold fixtures
		if floor_num == 8:
			load("res://scripts/world/floor_08_config.gd").apply_floor_08_extras(room_instance)
		# Floor 9: apply memory hall fragments, narrative passages
		if floor_num == 9:
			load("res://scripts/world/floor_09_config.gd").apply_floor_09_extras(room_instance)
		rooms[room_id] = room_instance
		room_instance.deactivate()

		# Connect room_cleared signal (emits RoomInstance)
		room_instance.room_cleared.connect(_on_room_instance_cleared)

	# 5. Deactivate boss room initially (unlock after all rooms cleared)
	if rooms.has("boss"):
		rooms["boss"].process_mode = Node.PROCESS_MODE_DISABLED

	# 6. Activate start room (a1)
	if rooms.has("a1"):
		_activate_room("a1")
	else:
		push_error("FloorManager: start room a1 not found")


func _setup_route_gates(seed_mgr: SeedManager) -> void:
	var gate_config := seed_mgr.get_gate_config(floor_number, 3)
	# Branches mapped: 0=b, 1=c, 2=d
	var branch_names := ["b", "c", "d"]
	route_gates.clear()

	# Open all branches first
	for b in branch_names:
		route_gates[b] = true

	# Close one branch
	var closed_idx: int = gate_config["closed"]
	if closed_idx >= 0 and closed_idx < branch_names.size():
		route_gates[branch_names[closed_idx]] = false

	# A and hub always open
	route_gates["a"] = true
	route_gates["hub"] = true
	route_gates["boss"] = true


func _setup_key_location(seed_mgr: SeedManager) -> void:
	var rng := seed_mgr.get_floor_rng(floor_number)
	# Key in one of the open branch endpoints
	var candidates: Array[String] = []
	if route_gates.get("b", false):
		candidates.append("b2")
	if route_gates.get("c", false):
		candidates.append("c2")
	if route_gates.get("d", false):
		candidates.append("d2")

	if candidates.is_empty():
		# Fallback: key always in b2
		key_location = "b2"
	else:
		var idx := rng.randi_range(0, candidates.size() - 1)
		key_location = candidates[idx]


func _activate_room(room_id: String) -> void:
	if not rooms.has(room_id):
		push_warning("FloorManager: room %s not found" % room_id)
		return
	active_room_id = room_id
	var room: RoomInstance = rooms[room_id]
	room.activate()


func transition_to_room(target_room_id: String) -> void:
	if not rooms.has(target_room_id):
		push_warning("FloorManager: target room %s not found" % target_room_id)
		return

	var config: RoomConfig = room_configs.get(target_room_id)

	# Check if room is locked (C1 requires key)
	if config != null and config.is_locked and not has_key:
		print("[FloorManager] Door to %s is locked. Need a key." % config.room_name)
		return

	# Unlock C1 if player has key
	if config != null and config.is_locked and has_key:
		print("[FloorManager] Unlocking %s with key." % config.room_name)
		config.is_locked = false

	# Determine entry side from current room's door
	var entry_side := _get_entry_side(target_room_id)

	# Play floor transition SFX if crossing branches
	var current_config: RoomConfig = room_configs.get(active_room_id)
	if current_config != null and config != null:
		if current_config.branch != config.branch:
			AudioManager.SFXPlayer.play_sfx("floor_transition")

	# Deactivate current room
	if not active_room_id.is_empty() and rooms.has(active_room_id):
		rooms[active_room_id].deactivate()

	# Activate target room
	_activate_room(target_room_id)

	# Move player to entry position
	_move_player_to_entry(target_room_id, entry_side)

	# Spawn enemies on first entry
	var target_room: RoomInstance = rooms[target_room_id]
	if not target_room._enemies_spawned:
		_spawn_enemies(target_room, config)
		target_room._enemies_spawned = true
		_spawn_loot(target_room, config)

	# Emit event
	EventBus.room_entered.emit(floor_number, target_room_id)


func _get_entry_side(target_room_id: String) -> String:
	if active_room_id.is_empty():
		return ""
	var current_room: RoomInstance = rooms.get(active_room_id)
	if current_room == null:
		return ""
	# Find door in current room that leads to target
	for door in current_room.doors:
		if door.get_meta("target_room_id", "") == target_room_id:
			return door.get_meta("entry_side", "")
	return ""


func _move_player_to_entry(room_id: String, entry_side: String) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var room: RoomInstance = rooms[room_id]
	if room == null:
		return
	# Player enters from the opposite side of the door they came through
	var entry_pos := room.get_entry_position(entry_side)
	player.global_position = room.global_position + entry_pos


func _spawn_enemies(room: RoomInstance, config: RoomConfig) -> void:
	if config == null or config.enemies.is_empty():
		return

	var enemy_count := 0
	var spawn_points := room.spawn_points.duplicate()
	# Shuffle spawn points for variety
	spawn_points.shuffle()

	var spawn_idx := 0
	for enemy_group: Dictionary in config.enemies:
		var type: String = enemy_group["type"]
		var count: int = enemy_group["count"]

		if not ENEMY_SCENES.has(type):
			push_warning("FloorManager: unknown enemy type '%s'" % type)
			continue

		var scene_path: String = ENEMY_SCENES[type]
		if not ResourceLoader.exists(scene_path):
			push_warning("FloorManager: enemy scene not found: %s" % scene_path)
			continue

		var scene: PackedScene = load(scene_path)
		for i in range(count):
			if enemy_count >= 10:
				push_warning("FloorManager: max 10 enemies per room reached")
				return
			var pos: Vector2 = Vector2(room.room_bounds.size.x * 0.5, room.room_bounds.size.y * 0.5)
			if spawn_idx < spawn_points.size():
				pos = spawn_points[spawn_idx].position
				spawn_idx += 1
			var enemy := room.add_enemy(scene, pos)
			if enemy != null:
				enemy_count += 1
				enemy.process_mode = Node.PROCESS_MODE_INHERIT if room.is_active else Node.PROCESS_MODE_DISABLED


func _spawn_loot(room: RoomInstance, config: RoomConfig) -> void:
	if config == null or config.loot.is_empty():
		return

	var loot_idx := 0
	for loot_item: Dictionary in config.loot:
		var loot_type: String = loot_item.get("type", "")

		# Key only spawns in key_location room
		if loot_type == "key" and config.room_id != key_location:
			continue

		# Determine position
		var pos := Vector2(room.room_bounds.size.x * 0.5, room.room_bounds.size.y * 0.5)
		if loot_idx < room.loot_zones.size():
			pos = room.loot_zones[loot_idx].position
			loot_idx += 1

		# Create pickup node
		var pickup := _create_pickup(loot_item, pos)
		if pickup != null:
			room.add_child(pickup)


func _create_pickup(loot_item: Dictionary, pos: Vector2) -> Area2D:
	var pickup := Area2D.new()
	pickup.name = "Pickup_%s" % loot_item.get("type", "item")
	pickup.position = pos
	pickup.add_to_group("pickups")

	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 16)
	var col := CollisionShape2D.new()
	col.shape = shape
	pickup.add_child(col)

	# Visual
	var visual := ColorRect.new()
	visual.size = Vector2(12, 12)
	visual.position = Vector2(-6, -6)
	match loot_item.get("type", ""):
		"weapon":
			visual.color = Color(0.2, 0.6, 1.0, 0.8)
		"key":
			visual.color = Color(1.0, 0.9, 0.0, 0.9)
			pickup.set_meta("is_key", true)
		"ammo":
			visual.color = Color(0.8, 0.4, 0.1, 0.8)
		"stat_upgrade":
			visual.color = Color(0.0, 1.0, 0.5, 0.8)
		"cult_artifact":
			visual.color = Color(0.7, 0.0, 1.0, 0.9)
		_:
			visual.color = Color(1.0, 1.0, 1.0, 0.5)
	pickup.add_child(visual)

	# Store loot data in metadata
	pickup.set_meta("loot_type", loot_item.get("type", ""))
	pickup.set_meta("loot_id", loot_item.get("id", ""))

	# Connect pickup
	pickup.body_entered.connect(_on_pickup_collected.bind(pickup))

	return pickup


func _on_pickup_collected(body: Node2D, pickup: Area2D) -> void:
	if not body.is_in_group("player"):
		return

	AudioManager.SFXPlayer.play_sfx_2d("item_pickup", pickup.global_position)

	var loot_type: String = pickup.get_meta("loot_type", "")

	# Handle key pickup
	if pickup.get_meta("is_key", false):
		has_key = true
		print("[FloorManager] Key collected!")

	match loot_type:
		"weapon":
			print("[FloorManager] Weapon picked up: %s" % pickup.get_meta("loot_id", "unknown"))
		"ammo":
			print("[FloorManager] Ammo picked up")
		"stat_upgrade":
			print("[FloorManager] Stat upgrade collected")
			EventBus.upgrade_collected.emit(null)
		"cult_artifact":
			print("[FloorManager] Cult artifact collected!")
			EventBus.artifact_collected.emit(null)
		"key":
			pass  # Handled above

	pickup.queue_free()


func _on_room_instance_cleared(room: RoomInstance) -> void:
	_check_clear_progress(room.room_id)


func _on_event_bus_room_cleared(_floor_num: int, room_id: String) -> void:
	_check_clear_progress(room_id)


func _check_clear_progress(rid: String) -> void:
	# Check if all non-boss rooms are cleared → unlock boss
	var all_cleared := true
	for rid_check in rooms:
		if rid_check == "boss":
			continue
		var r: RoomInstance = rooms[rid_check]
		if not r.is_cleared:
			all_cleared = false
			break

	if all_cleared and not _boss_unlocked:
		_boss_unlocked = true
		AudioManager.SFXPlayer.play_sfx("boss_unlock")
		if rooms.has("boss"):
			rooms["boss"].process_mode = Node.PROCESS_MODE_INHERIT
			print("[FloorManager] Boss room unlocked!")

	# Boss room cleared → floor complete
	if rid == "boss":
		EventBus.mini_boss_defeated.emit(floor_number)
		EventBus.floor_completed.emit(floor_number)
		print("[FloorManager] Floor %d complete!" % floor_number)


func _show_tutorial() -> void:
	var tutorial_scene := preload("res://scenes/ui/tutorial_overlay.tscn")
	var tutorial := tutorial_scene.instantiate()
	add_child(tutorial)
