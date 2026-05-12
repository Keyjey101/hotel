## Floor 3 config — Banquet Hall (Gluttony).
## All room data from 13_FLOOR_DESIGN.md section 4.
## Palette: floor #2A1508, walls #1A0A04, accent gold #B8860B, burgundy #6B0020.

const F3_FLOOR := Color(0.165, 0.082, 0.031, 1.0)  # #2A1508 dark warm brown
const F3_WALL := Color(0.102, 0.039, 0.016, 1.0)   # #1A0A04 very dark brown
const TILE := 32


## Return all 11 rooms for Floor 3 as Dictionary[room_id -> RoomConfig].
static func get_floor_03_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Grand Foyer ---
	# 10×8 tiles, chamber, Staff×2, no loot, connects a2
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "Grand Foyer",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "staff", "count": 2}],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Wine Cellar Stairs ---
	# 8×6 tiles, corridor, Staff×1, ammo
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "Wine Cellar Stairs",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 6),
		"size_px": Vector2(8 * TILE, 6 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "ammo"}],
		"connections": ["a1", "hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 6 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 6 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Banquet Hall ---
	# 20×16 tiles (VERY LARGE), hub, Chef×1 + Taster×1 + Staff×3 + Guard×1, shotgun
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Banquet Hall",
		"room_type": "hub",
		"size_tiles": Vector2i(20, 16),
		"size_px": Vector2(20 * TILE, 16 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [
			{"type": "chef", "count": 1},
			{"type": "taster", "count": 1},
			{"type": "staff", "count": 3},
			{"type": "guard", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "shotgun"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(20 * TILE, 16 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(20 * TILE, 16 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(
			Vector2(20 * TILE, 16 * TILE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Kitchen ---
	# 12×8 tiles, chamber, Chef×2 + Staff×1, axe
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "Kitchen",
		"room_type": "chamber",
		"size_tiles": Vector2i(12, 8),
		"size_px": Vector2(12 * TILE, 8 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "chef", "count": 2}, {"type": "staff", "count": 1}],
		"loot": [{"type": "weapon", "id": "axe"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 8 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 8 * TILE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — Pantry ---
	# 6×6 tiles, storage, Staff×1, ammo + stat_upgrade + KEY(50%)
	rooms["b2"] = RoomConfig._make({
		"room_id": "b2",
		"room_name": "Pantry",
		"room_type": "storage",
		"size_tiles": Vector2i(6, 6),
		"size_px": Vector2(6 * TILE, 6 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "ammo"}, {"type": "stat_upgrade"}, {"type": "key", "chance": 0.5}],
		"connections": ["b1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(6 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(6 * TILE, 6 * TILE), 3),
		"door_positions": RoomConfig._gen_doors(Vector2(6 * TILE, 6 * TILE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — Dessert Chamber ---
	# 10×8 tiles, trap, Taster×2 + Staff×1, smg, LOCKED
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "Dessert Chamber",
		"room_type": "trap",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "taster", "count": 2}, {"type": "staff", "count": 1}],
		"loot": [{"type": "weapon", "id": "smg"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — The Grotto ---
	# 8×8 tiles, chamber, Guard×1, KEY(50%) + ammo + cult_artifact(10%)
	rooms["c2"] = RoomConfig._make({
		"room_id": "c2",
		"room_name": "The Grotto",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE, 8 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "guard", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}, {"type": "cult_artifact", "chance": 0.1}],
		"connections": ["c1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Dining Gallery ---
	# 12×8 tiles, gallery, Chef×1 + Taster×1 + Staff×2, wire
	rooms["d1"] = RoomConfig._make({
		"room_id": "d1",
		"room_name": "Dining Gallery",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 8),
		"size_px": Vector2(12 * TILE, 8 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "chef", "count": 1}, {"type": "taster", "count": 1}, {"type": "staff", "count": 2}],
		"loot": [{"type": "weapon", "id": "wire"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 8 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 8 * TILE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — Smoke Room ---
	# 8×8 tiles, storage, Staff×1 + Guard×1, KEY(50%) + stat_upgrade
	rooms["d2"] = RoomConfig._make({
		"room_id": "d2",
		"room_name": "Smoke Room",
		"room_type": "storage",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE, 8 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "staff", "count": 1}, {"type": "guard", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "stat_upgrade"}],
		"connections": ["d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — The Gourmand's Table ---
	# 16×14 tiles (512×448 px), boss, Gourmand×1, cult artifact
	rooms["boss"] = RoomConfig._make({
		"room_id": "boss",
		"room_name": "The Gourmand's Table",
		"room_type": "boss",
		"size_tiles": Vector2i(16, 14),
		"size_px": Vector2(16 * TILE, 14 * TILE),
		"floor_color": F3_FLOOR,
		"wall_color": F3_WALL,
		"enemies": [{"type": "gourmand", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(16 * TILE, 14 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(16 * TILE, 14 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(16 * TILE, 14 * TILE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms
