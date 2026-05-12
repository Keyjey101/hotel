## Floor 2 config — Red Light District (Lust).
## All room data from 13_FLOOR_DESIGN.md section 3.
## Palette: floor #1A0A15, walls #0A0A0F, accent #8B0035, neon #FF1A6D.

const F2_FLOOR := Color(0.102, 0.039, 0.082, 1.0)  # #1A0A15 dark red-black
const F2_WALL := Color(0.039, 0.039, 0.059, 1.0)   # #0A0A0F near-black
const TILE := 32


## Return all 10 rooms for Floor 2 as Dictionary[room_id -> RoomConfig].
static func get_floor_02_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Velvet Entryway ---
	# 13_FLOOR_DESIGN.md §3.2: 8×6 tiles, corridor, 0 enemies, no loot, connects a2
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "Velvet Entryway",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 6),
		"size_px": Vector2i(8 * TILE, 6 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 6 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 6 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Neon Corridor ---
	# 12×4 tiles, corridor, Staff×2, SMG
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "Neon Corridor",
		"room_type": "corridor",
		"size_tiles": Vector2i(12, 4),
		"size_px": Vector2i(12 * TILE, 4 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "staff", "count": 2}],
		"loot": [{"type": "weapon", "id": "smg"}],
		"connections": ["a1", "hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 4 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 4 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 4 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Lounge ---
	# 14×12 tiles, hub, Seductress×1 + Bodyguard×1 + Staff×2, Bat
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Lounge",
		"room_type": "hub",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2i(14 * TILE, 12 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "seductress", "count": 1}, {"type": "bodyguard", "count": 1}, {"type": "staff", "count": 2}],
		"loot": [{"type": "weapon", "id": "bat"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 12 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 12 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(
			Vector2i(14 * TILE, 12 * TILE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Hall of Mirrors ---
	# 14×12 tiles, gallery, Seductress×2 + Bodyguard×1, Cult Blade (rare)
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "Hall of Mirrors",
		"room_type": "gallery",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2i(14 * TILE, 12 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "seductress", "count": 2}, {"type": "bodyguard", "count": 1}],
		"loot": [{"type": "weapon", "id": "cult_blade", "rarity": "rare"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 12 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 12 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(14 * TILE, 12 * TILE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — Peep Room ---
	# 6×6 tiles, storage, Staff×1, Ammo + stat_upgrade + KEY(50%)
	rooms["b2"] = RoomConfig._make({
		"room_id": "b2",
		"room_name": "Peep Room",
		"room_type": "storage",
		"size_tiles": Vector2i(6, 6),
		"size_px": Vector2i(6 * TILE, 6 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "ammo"}, {"type": "stat_upgrade"}, {"type": "key", "chance": 0.5}],
		"connections": ["b1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(6 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(6 * TILE, 6 * TILE), 3),
		"door_positions": RoomConfig._gen_doors(Vector2(6 * TILE, 6 * TILE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — Silk Chamber ---
	# 10×8 tiles, chamber, Seductress×2, Pistol, LOCKED
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "Silk Chamber",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2i(10 * TILE, 8 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "seductress", "count": 2}],
		"loot": [{"type": "weapon", "id": "pistol"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — The Boudoir ---
	# 8×8 tiles, chamber, Bodyguard×1 + Staff×1, KEY(50%) + ammo
	rooms["c2"] = RoomConfig._make({
		"room_id": "c2",
		"room_name": "The Boudoir",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2i(8 * TILE, 8 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "bodyguard", "count": 1}, {"type": "staff", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}],
		"connections": ["c1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Red Light Gallery ---
	# 12×6 tiles, gallery, Seductress×1 + Bodyguard×1 + Staff×2, Wire
	rooms["d1"] = RoomConfig._make({
		"room_id": "d1",
		"room_name": "Red Light Gallery",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 6),
		"size_px": Vector2i(12 * TILE, 6 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "seductress", "count": 1}, {"type": "bodyguard", "count": 1}, {"type": "staff", "count": 2}],
		"loot": [{"type": "weapon", "id": "wire"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 6 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 6 * TILE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — Dressing Room ---
	# 8×8 tiles, storage, Staff×1, KEY(50%) + stat_upgrade + random weapon
	rooms["d2"] = RoomConfig._make({
		"room_id": "d2",
		"room_name": "Dressing Room",
		"room_type": "storage",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2i(8 * TILE, 8 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "stat_upgrade"}, {"type": "weapon", "id": "random"}],
		"connections": ["d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — Madame's Chamber ---
	# 14×12 tiles, boss, Madame×1, cult artifact
	rooms["boss"] = RoomConfig._make({
		"room_id": "boss",
		"room_name": "Madame's Chamber",
		"room_type": "boss",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2i(14 * TILE, 12 * TILE),
		"floor_color": F2_FLOOR,
		"wall_color": F2_WALL,
		"enemies": [{"type": "madame", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 12 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 12 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(14 * TILE, 12 * TILE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms
