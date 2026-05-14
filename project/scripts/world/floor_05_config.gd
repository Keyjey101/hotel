## Floor 5 config — Spa (Sloth).
## All room data from 13_FLOOR_DESIGN.md section 6.
## Palette: floor #D0E0E0, walls #8AABA0, accent #3CBEB0 turquoise, seafoam #B8D8D0.

extends "res://scripts/world/floor_01_config.gd"
const F5_FLOOR := Color(0.816, 0.878, 0.878, 1.0)  # #D0E0E0 light blue-grey
const F5_WALL := Color(0.541, 0.671, 0.627, 1.0)   # #8AABA0 muted teal
const TILE := 32


## Return all 10 rooms for Floor 5 as Dictionary[room_id -> RoomConfig].
static func get_floor_05_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Reception Lounge ---
	# 10×6 tiles, corridor, Staff×1, no loot, connects a2
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "Reception Lounge",
		"room_type": "corridor",
		"size_tiles": Vector2i(10, 6),
		"size_px": Vector2(10 * TILE, 6 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 6 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 6 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Steam Corridor ---
	# 8×6 tiles, corridor, Attendant×1, ammo
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "Steam Corridor",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 6),
		"size_px": Vector2(8 * TILE, 6 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "attendant", "count": 1}],
		"loot": [{"type": "ammo"}],
		"connections": ["a1", "hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 6 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 6 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Pool ---
	# 16×14 tiles (large), hub, Attendant×2 + Drowned One×1 + Staff×2, shotgun
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Pool",
		"room_type": "hub",
		"size_tiles": Vector2i(16, 14),
		"size_px": Vector2(16 * TILE, 14 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [
			{"type": "attendant", "count": 2},
			{"type": "drowned_one", "count": 1},
			{"type": "staff", "count": 2},
		],
		"loot": [{"type": "weapon", "id": "shotgun"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(16 * TILE, 14 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(16 * TILE, 14 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(
			Vector2(16 * TILE, 14 * TILE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Sauna Wing ---
	# 10×8 tiles, chamber, Attendant×2, wire
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "Sauna Wing",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "attendant", "count": 2}],
		"loot": [{"type": "weapon", "id": "wire"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — Mud Baths ---
	# 6×6 tiles, storage, Staff×1, stat_upgrade + ammo + KEY(50%)
	rooms["b2"] = RoomConfig._make({
		"room_id": "b2",
		"room_name": "Mud Baths",
		"room_type": "storage",
		"size_tiles": Vector2i(6, 6),
		"size_px": Vector2(6 * TILE, 6 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "stat_upgrade"}, {"type": "ammo"}, {"type": "key", "chance": 0.5}],
		"connections": ["b1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(6 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(6 * TILE, 6 * TILE), 3),
		"door_positions": RoomConfig._gen_doors(Vector2(6 * TILE, 6 * TILE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — Treatment Rooms ---
	# 10×8 tiles, trap, Attendant×1 + Drowned One×1, cult_blade (rare), LOCKED
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "Treatment Rooms",
		"room_type": "trap",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "attendant", "count": 1}, {"type": "drowned_one", "count": 1}],
		"loot": [{"type": "weapon", "id": "cult_blade", "rarity": "rare"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — The Surgery ---
	# 8×8 tiles, chamber, Guard×1, KEY(50%) + ammo
	rooms["c2"] = RoomConfig._make({
		"room_id": "c2",
		"room_name": "The Surgery",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE, 8 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "guard", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}],
		"connections": ["c1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Relaxation Garden ---
	# 12×8 tiles, gallery, Attendant×1 + Drowned One×1 + Staff×1, stat_upgrade
	rooms["d1"] = RoomConfig._make({
		"room_id": "d1",
		"room_name": "Relaxation Garden",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 8),
		"size_px": Vector2(12 * TILE, 8 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "attendant", "count": 1}, {"type": "drowned_one", "count": 1}, {"type": "staff", "count": 1}],
		"loot": [{"type": "stat_upgrade"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 8 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 8 * TILE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — Steam Engine Room ---
	# 10×8 tiles, storage, Guard×1 + Staff×1, KEY(50%) + random weapon
	rooms["d2"] = RoomConfig._make({
		"room_id": "d2",
		"room_name": "Steam Engine Room",
		"room_type": "storage",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "guard", "count": 1}, {"type": "staff", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "weapon", "id": "random"}],
		"connections": ["d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — Attendant Prime's Sanctuary ---
	# 14×12 tiles, boss, Attendant Prime×1, cult artifact
	rooms["boss"] = RoomConfig._make({
		"room_id": "boss",
		"room_name": "Attendant Prime's Sanctuary",
		"room_type": "boss",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2(14 * TILE, 12 * TILE),
		"floor_color": F5_FLOOR,
		"wall_color": F5_WALL,
		"enemies": [{"type": "attendant_prime", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 12 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 12 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(14 * TILE, 12 * TILE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms
