extends "res://scripts/world/floor_manager.gd"

## Floor06Manager — Floor 6 specific behavior.
## Adds fire hazards, one-way doors, arena wave rooms, and narrative.
## Extends FloorManager without modifying the base class.

# Fire hazard config: 8 dmg/s, 4s duration (13_FLOOR_DESIGN.md §7.2)
const FIRE_HAZARD_DPS: float = 8.0
const FIRE_HAZARD_DURATION: float = 4.0
const FIRE_HAZARD_RADIUS: float = 48.0
const FIRE_HAZARD_COLOR: Color = Color(1.0, 0.33, 0.0, 0.5)  # #FF5500 ember orange

const LAYER_PLAYER := 1
const LAYER_ENEMY := 2
const LAYER_PROJECTILE := 4

var _rng: RandomNumberGenerator
var _arena_started: bool = false


var HazardZoneScene: PackedScene = null
var ArenaRoomScript: GDScript = null


func _ready() -> void:
	super._ready()
	if ResourceLoader.exists("res://scenes/combat/hazard_zone.tscn"):
		HazardZoneScene = load("res://scenes/combat/hazard_zone.tscn")
	if ResourceLoader.exists("res://scripts/world/arena_room.gd"):
		ArenaRoomScript = load("res://scripts/world/arena_room.gd")

func load_floor(floor_num: int, seed_mgr: SeedManager) -> void:
	super.load_floor(floor_num, seed_mgr)
	_rng = seed_mgr.get_floor_rng(floor_num)

	if floor_num != 6:
		return

	_setup_fire_hazards()
	_setup_one_way_doors()
	_setup_arena_rooms()
	_setup_narrative()


# ---------------------------------------------------------------------------
# Fire hazards — braziers in B1, C1, BOSS (13_FLOOR_DESIGN.md §7.2)
# ---------------------------------------------------------------------------

func _setup_fire_hazards() -> void:
	var hazard_rooms := ["b1", "c1", "boss"]
	for room_id in hazard_rooms:
		if not rooms.has(room_id):
			continue
		var room: RoomInstance = rooms[room_id]
		# Place 2 fire hazards per room at strategic positions
		var positions := _get_hazard_positions(room, 2)
		for pos in positions:
			_create_fire_hazard(room, pos)


func _get_hazard_positions(room: RoomInstance, count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var size := room.room_bounds.size
	var margin := 64.0
	# Place near corners
	var candidates := [
		Vector2(margin, margin),
		Vector2(size.x - margin, margin),
		Vector2(margin, size.y - margin),
		Vector2(size.x - margin, size.y - margin),
		Vector2(size.x * 0.5, margin),
		Vector2(size.x * 0.5, size.y - margin),
	]
	for i in range(mini(count, candidates.size())):
		positions.append(candidates[i])
	while positions.size() < count:
		positions.append(Vector2(
			_rng.randf_range(margin, size.x - margin),
			_rng.randf_range(margin, size.y - margin)
		))
	return positions


func _create_fire_hazard(room: RoomInstance, pos: Vector2) -> void:
	# Create a brazier visual + dormant hazard zone
	var brazier := Area2D.new()
	brazier.name = "Brazier"
	brazier.position = pos
	brazier.collision_layer = 0
	brazier.collision_mask = LAYER_PLAYER | LAYER_ENEMY | LAYER_PROJECTILE
	brazier.monitoring = true
	brazier.add_to_group("fire_hazards")

	var shape := CircleShape2D.new()
	shape.radius = 24.0
	var col := CollisionShape2D.new()
	col.shape = shape
	brazier.add_child(col)

	# Brazier visual (placeholder)
	var visual := ColorRect.new()
	visual.size = Vector2(12, 16)
	visual.position = Vector2(-6, -8)
	visual.color = Color(0.455, 0.29, 0.055, 1.0)  # #B74A0E rust
	brazier.add_child(visual)

	# Dormant fire zone (activates on knockback into brazier)
	brazier.set_meta("is_fire_hazard", true)
	brazier.set_meta("fire_dps", FIRE_HAZARD_DPS)
	brazier.set_meta("fire_duration", FIRE_HAZARD_DURATION)
	brazier.set_meta("fire_radius", FIRE_HAZARD_RADIUS)
	brazier.set_meta("fire_active", false)
	brazier.set_meta("fire_color", FIRE_HAZARD_COLOR)

	# Activate on body entering (simulates knockback triggering)
	brazier.body_entered.connect(_on_brazier_body_entered.bind(brazier))

	room.add_child(brazier)


func _on_brazier_body_entered(body: Node2D, brazier: Area2D) -> void:
	if brazier.get_meta("fire_active", false):
		return
	# Activate fire when a body (enemy or player) gets knocked into the brazier
	if body.is_in_group("player") or body.is_in_group("enemy"):
		_ignite_brazier(brazier)


func _ignite_brazier(brazier: Area2D) -> void:
	brazier.set_meta("fire_active", true)

	# Create the active fire hazard zone
	var fire_zone
	if HazardZoneScene:
		fire_zone = HazardZoneScene.instantiate()
	else:
		fire_zone = HazardZone.new()
	if fire_zone == null:
		return
	fire_zone.damage_per_second = brazier.get_meta("fire_dps", FIRE_HAZARD_DPS)
	fire_zone.duration = brazier.get_meta("fire_duration", FIRE_HAZARD_DURATION)
	fire_zone.zone_radius = brazier.get_meta("fire_radius", FIRE_HAZARD_RADIUS)
	fire_zone.zone_color = brazier.get_meta("fire_color", FIRE_HAZARD_COLOR)
	fire_zone.position = Vector2.ZERO  # Relative to parent
	fire_zone.name = "FireZone"

	# Add to brazier's parent (the room)
	var parent := brazier.get_parent()
	if parent:
		parent.add_child(fire_zone)
		fire_zone.global_position = brazier.global_position

	# Change brazier visual to active (glowing)
	for child in brazier.get_children():
		if child is ColorRect:
			child.color = Color(1.0, 0.33, 0.0, 1.0)  # #FF5500 ember


# ---------------------------------------------------------------------------
# One-way doors — A2 (one-way from A1), C1 (one-way from HUB)
# ---------------------------------------------------------------------------

func _setup_one_way_doors() -> void:
	# A2: one-way door from A1 (can only go forward)
	_setup_one_way_room("a2", "top")  # Entry from top, can't go back
	# C1: one-way door (locked until key, then one-way entry)
	_setup_one_way_room("c1", "left")  # Entry from left


func _setup_one_way_room(room_id: String, entry_side: String) -> void:
	if not rooms.has(room_id):
		return
	var room: RoomInstance = rooms[room_id]
	# Mark doors as one-way: the door matching entry_side is one-way
	for door in room.doors:
		if not door is Area2D:
			continue
		var side: String = door.get_meta("entry_side", "")
		if side == entry_side:
			door.set_meta("one_way", true)
			door.set_meta("one_way_direction", entry_side)


# ---------------------------------------------------------------------------
# Arena wave rooms — B1 (waves), BOSS (wave boss)
# ---------------------------------------------------------------------------

func _setup_arena_rooms() -> void:
	# B1 — Gladiator Pit: 2 waves
	_setup_arena_b1()
	# BOSS room already handled by boss_champion.gd wave system


func _setup_arena_b1() -> void:
	if not rooms.has("b1"):
		return
	var room: RoomInstance = rooms["b1"]

	var arena := Node2D.new()
	arena.name = "ArenaRoom"
	if ArenaRoomScript == null:
		return

	room.add_child(arena)
	arena.set_script.call_deferred(ArenaRoomScript)

	# Configure waves for B1 per spec
	var arena_script := arena as Node2D
	# Wave configs set via metadata since we can't set exported arrays before _ready
	arena.set_meta("wave_configs", [
		{
			"enemy_types": ["gladiator"],
			"counts": [1],
			"spawn_point_indices": [0],
		},
		{
			"enemy_types": ["gladiator", "berserker"],
			"counts": [2, 1],
			"spawn_point_indices": [0, 1, 2],
		},
	])

	# Connect room activation to arena start
	room.player_entered.connect(_on_arena_room_entered.bind(arena))

	# If room is already active (edge case), trigger arena manually
	if room.is_active:
		_on_arena_room_entered(room, arena)

	# Collect door node paths relative to arena
	var door_paths: Array[String] = []
	for i in range(room.doors.size()):
		var door := room.doors[i]
		door_paths.append(arena.get_path_to(door))
	arena.set_meta("door_node_paths", door_paths)


func _on_arena_room_entered(room: RoomInstance, arena: Node2D) -> void:
	if not is_instance_valid(arena):
		return
	if _arena_started:
		return
	_arena_started = true
	if not arena.is_node_ready():
		await get_tree().process_frame
	if not is_instance_valid(arena):
		return
	var player := get_tree().get_first_node_in_group("player") if is_instance_valid(get_tree()) else null
	if not is_instance_valid(player):
		_arena_started = false
		return
	if arena.has_method("start_arena"):
		# Apply saved wave configs
		if arena.has_meta("wave_configs"):
			var configs = arena.get_meta("wave_configs")
			if configs is Array:
				arena.wave_configs.clear()
				for cfg in configs:
					arena.wave_configs.append(Dictionary(cfg))
		if arena.has_meta("door_node_paths"):
			var paths = arena.get_meta("door_node_paths")
			if paths is Array:
				arena.door_nodes.clear()
				for p in paths:
					arena.door_nodes.append(NodePath(p))
		arena.start_arena()


# ---------------------------------------------------------------------------
# Narrative — fight poster in A1 (16_NARRATIVE_DESIGN.md §Floor 6)
# ---------------------------------------------------------------------------

func _setup_narrative() -> void:
	if not rooms.has("a1"):
		return
	var room: RoomInstance = rooms["a1"]

	var label := Label.new()
	label.name = "NarrativeLabel"
	label.text = "TONIGHT: The Undying vs. The Volunteer...\nOnly one leaves the Arena."
	label.position = Vector2(room.room_bounds.size.x * 0.5 - 80.0, 32.0)
	label.add_theme_color_override("font_color", Color(0.8, 0.067, 0.0, 1.0))  # #CC1100 blood red
	label.add_theme_font_size_override("font_size", 8)
	room.add_child(label)
