## Floor 8 config — Ballroom (Pride).
## All room data from 13_FLOOR_DESIGN.md section 9.
## Palette: floor #2A2A2A deep black, walls #1A1A1A near-black luxury, accent #DAA520 royal gold,
##   white #F5F5F0 marble, red carpet #8B0000.
## Blood: #DD0000 | BG: #1A1A1A

const F8_FLOOR := Color(0.165, 0.165, 0.165, 1.0)  # #2A2A2A deep black
const F8_WALL := Color(0.102, 0.102, 0.102, 1.0)   # #1A1A1A near-black luxury
const TILE := 32


## Return all 10 rooms for Floor 8 as Dictionary[room_id -> RoomConfig].
static func get_floor_08_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Grand Staircase ---
	# 10×6 tiles, corridor, Royal Guard×1, connects a2
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "Grand Staircase",
		"room_type": "corridor",
		"size_tiles": Vector2i(10, 6),
		"size_px": Vector2i(10 * TILE, 6 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [{"type": "royal_guard", "count": 1}],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(10 * TILE, 6 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2i(10 * TILE, 6 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Portrait Gallery ---
	# 12×8 tiles, gallery, Royal Guard×2, connects a1 + hub
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "Portrait Gallery",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 8),
		"size_px": Vector2i(12 * TILE, 8 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [{"type": "royal_guard", "count": 2}],
		"loot": [],
		"connections": ["a1", "hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(12 * TILE, 8 * TILE), 10),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2i(12 * TILE, 8 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Ballroom (massive) ---
	# 20×16 tiles, hub, Royal Guard×2 + Champion×1
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Ballroom",
		"room_type": "hub",
		"size_tiles": Vector2i(20, 16),
		"size_px": Vector2i(20 * TILE, 16 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [
			{"type": "royal_guard", "count": 2},
			{"type": "champion_enemy", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "shotgun"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(20 * TILE, 16 * TILE), 14),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(20 * TILE, 16 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(
			Vector2i(20 * TILE, 16 * TILE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Champagne Hall ---
	# 10×8 tiles, chamber, Royal Guard×2 + Cultist×1
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "Champagne Hall",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2i(10 * TILE, 8 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [
			{"type": "royal_guard", "count": 2},
			{"type": "cultist", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "axe"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2i(10 * TILE, 8 * TILE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — Trophy Room ---
	# 8×8 tiles, storage, Champion×1, stat_upgrade + KEY(50%)
	rooms["b2"] = RoomConfig._make({
		"room_id": "b2",
		"room_name": "Trophy Room",
		"room_type": "storage",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2i(8 * TILE, 8 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [{"type": "champion_enemy", "count": 1}],
		"loot": [{"type": "stat_upgrade"}, {"type": "key", "chance": 0.5}],
		"connections": ["b1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2i(8 * TILE, 8 * TILE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — Throne Antechamber (LOCKED) ---
	# 12×10 tiles, gallery, Royal Guard×3 + Cultist×1
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "Throne Antechamber",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 10),
		"size_px": Vector2i(12 * TILE, 10 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [
			{"type": "royal_guard", "count": 3},
			{"type": "cultist", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "sword"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(12 * TILE, 10 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(12 * TILE, 10 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2i(12 * TILE, 10 * TILE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — The Golden Chamber ---
	# 8×8 tiles, chamber, Champion×1 + Cultist×1, KEY(50%) + ammo
	rooms["c2"] = RoomConfig._make({
		"room_id": "c2",
		"room_name": "The Golden Chamber",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2i(8 * TILE, 8 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [
			{"type": "champion_enemy", "count": 1},
			{"type": "cultist", "count": 1},
		],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}],
		"connections": ["c1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2i(8 * TILE, 8 * TILE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Crystal Gallery ---
	# 10×8 tiles, gallery, Royal Guard×2 + Champion×1
	rooms["d1"] = RoomConfig._make({
		"room_id": "d1",
		"room_name": "Crystal Gallery",
		"room_type": "gallery",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2i(10 * TILE, 8 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [
			{"type": "royal_guard", "count": 2},
			{"type": "champion_enemy", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "bat"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(10 * TILE, 8 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2i(10 * TILE, 8 * TILE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — The Vault of Faces ---
	# 10×10 tiles, trap, Royal Guard×2 + Champion×1, random weapon + KEY(50%)
	rooms["d2"] = RoomConfig._make({
		"room_id": "d2",
		"room_name": "The Vault of Faces",
		"room_type": "trap",
		"size_tiles": Vector2i(10, 10),
		"size_px": Vector2i(10 * TILE, 10 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [
			{"type": "royal_guard", "count": 2},
			{"type": "champion_enemy", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "random"}, {"type": "key", "chance": 0.5}],
		"connections": ["d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(10 * TILE, 10 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(10 * TILE, 10 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2i(10 * TILE, 10 * TILE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — The Consort's Ballroom ---
	# 18×14 tiles, boss, Consort×1, cult artifact
	rooms["boss"] = RoomConfig._make({
		"room_id": "boss",
		"room_name": "The Consort's Ballroom",
		"room_type": "boss",
		"size_tiles": Vector2i(18, 14),
		"size_px": Vector2i(18 * TILE, 14 * TILE),
		"floor_color": F8_FLOOR,
		"wall_color": F8_WALL,
		"enemies": [{"type": "consort", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(18 * TILE, 14 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(18 * TILE, 14 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2i(18 * TILE, 14 * TILE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms


## Floor 8 specific: rooms with chandeliers (destructible)
const CHANDELIER_ROOMS: Array[String] = ["hub", "boss"]

## Floor 8 specific: rooms with red carpet
const CARPET_ROOMS: Array[String] = ["a1", "a2", "hub", "c1", "boss"]


## Apply Floor 8-specific elements to a room after setup:
## - Chandeliers in CHANDELIER_ROOMS
## - Red carpet accents in CARPET_ROOMS
## - Gold fixtures (destructible)
## - Portraits (interactable)
static func apply_floor_08_extras(room: RoomInstance) -> void:
	var rid: String = room.room_id

	if rid in CHANDELIER_ROOMS:
		_add_chandeliers(room)

	if rid in CARPET_ROOMS:
		_add_red_carpet(room)

	# Gold fixtures in all rooms
	_add_gold_fixtures(room)


## Chandeliers: destructible Area2D with HP=30.
## When destroyed → falls → AoE damage 40 in radius 60px.
static func _add_chandeliers(room: RoomInstance) -> void:
	var size := room.room_bounds.size
	var positions: Array[Vector2] = [
		Vector2(size.x * 0.3, 24.0),
		Vector2(size.x * 0.7, 24.0),
	]

	if room.room_type == "boss":
		# Extra chandelier in boss room
		positions.append(Vector2(size.x * 0.5, 24.0))

	for i in range(positions.size()):
		var chandelier := Area2D.new()
		chandelier.name = "Chandelier%d" % i
		chandelier.position = positions[i]
		chandelier.add_to_group("destructible")
		chandelier.add_to_group("chandeliers")

		var shape := CircleShape2D.new()
		shape.radius = 20.0
		var col := CollisionShape2D.new()
		col.shape = shape
		chandelier.add_child(col)

		# Visual: gold diamond shape
		var visual := ColorRect.new()
		visual.name = "ChandelierVisual"
		visual.size = Vector2(20, 12)
		visual.position = Vector2(-10, -6)
		visual.color = Color(0.855, 0.647, 0.125, 1.0)  # #DAA520 gold
		visual.z_index = 60
		chandelier.add_child(visual)

		# HP metadata
		chandelier.set_meta("hp", 30.0)
		chandelier.set_meta("max_hp", 30.0)
		chandelier.set_meta("damage", 40.0)
		chandelier.set_meta("radius", 60.0)
		chandelier.set_meta("is_chandelier", true)

		# Connect area hit to damage handler
		chandelier.area_entered.connect(_on_chandelier_hit.bind(chandelier, room))

		room.add_child(chandelier)


## Chandelier hit by player attack → reduce HP → destroy if 0
static func _on_chandelier_hit(area: Area2D, chandelier: Area2D, room: RoomInstance) -> void:
	if not is_instance_valid(chandelier):
		return
	if not area.is_in_group("player_attack") and not area.name.begins_with("Melee") and not area.name.begins_with("Projectile"):
		return

	var hp: float = chandelier.get_meta("hp", 30.0)
	hp -= 15.0  # Standard hit damage
	chandelier.set_meta("hp", hp)

	if hp <= 0.0:
		_destroy_chandelier(chandelier, room)


## Chandelier destroyed → fall → AoE damage
static func _destroy_chandelier(chandelier: Area2D, room: RoomInstance) -> void:
	var pos := chandelier.global_position
	var damage: float = chandelier.get_meta("damage", 40.0)
	var radius: float = chandelier.get_meta("radius", 60.0)

	# Remove chandelier
	if is_instance_valid(chandelier):
		chandelier.queue_free()

	# Create falling hazard zone
	var hazard := Area2D.new()
	hazard.name = "ChandelierFall"
	hazard.position = pos
	hazard.add_to_group("hazards")

	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	hazard.add_child(col)

	# Visual: debris
	var debris := ColorRect.new()
	debris.size = Vector2(radius * 2, radius * 0.5)
	debris.position = Vector2(-radius, -radius * 0.25)
	debris.color = Color(0.855, 0.647, 0.125, 0.6)  # Gold debris
	debris.z_index = 55
	hazard.add_child(debris)

	room.add_child(hazard)

	# Apply AoE damage to all bodies in radius
	var bodies := hazard.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("receive_damage"):
			body.receive_damage(damage, 0, false, 80.0, Vector2.ZERO)

	# Remove hazard after 0.5s
	var tree := room.get_tree()
	if tree:
		var timer := tree.create_timer(0.5)
		timer.timeout.connect(func() -> void:
			if is_instance_valid(hazard):
				hazard.queue_free()
		)


## Red carpet: decorative ColorRect strip down center
static func _add_red_carpet(room: RoomInstance) -> void:
	var size := room.room_bounds.size
	var carpet := ColorRect.new()
	carpet.name = "RedCarpet"
	carpet.color = Color(0.545, 0.0, 0.0, 0.4)  # #8B0000 with alpha
	carpet.size = Vector2(size.x * 0.3, size.y)
	carpet.position = Vector2(size.x * 0.35, 0.0)
	carpet.z_index = -1
	carpet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room.add_child(carpet)


## Gold fixtures: destructible StaticBody2D with HP=20
static func _add_gold_fixtures(room: RoomInstance) -> void:
	var size := room.room_bounds.size
	# Place 2-3 gold fixtures along walls
	var positions: Array[Vector2] = [
		Vector2(size.x * 0.25, 20.0),
		Vector2(size.x * 0.75, 20.0),
	]

	for i in range(positions.size()):
		var fixture := StaticBody2D.new()
		fixture.name = "GoldFixture%d" % i
		fixture.position = positions[i]
		fixture.add_to_group("destructible")

		var shape := RectangleShape2D.new()
		shape.size = Vector2(8, 8)
		var col := CollisionShape2D.new()
		col.shape = shape
		fixture.add_child(col)

		var visual := ColorRect.new()
		visual.size = Vector2(8, 8)
		visual.position = Vector2(-4, -4)
		visual.color = Color(0.855, 0.647, 0.125, 1.0)  # #DAA520
		visual.z_index = 60
		fixture.add_child(visual)

		fixture.set_meta("hp", 20.0)
		fixture.set_meta("is_fixture", true)

		room.add_child(fixture)
