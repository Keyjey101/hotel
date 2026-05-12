## Floor 6 config — Arena (Wrath).
## All room data from 13_FLOOR_DESIGN.md section 7.
## Palette: floor #0F0505, walls #1A0A0A, accent #CC1100 blood red, ember #FF5500, rust #B74A0E.

const F6_FLOOR := Color(0.059, 0.020, 0.020, 1.0)  # #0F0505 near-black red
const F6_WALL := Color(0.102, 0.039, 0.039, 1.0)   # #1A0A0A dark red-black
const TILE := 32


## Return all 9 rooms for Floor 6 as Dictionary[room_id -> RoomConfig].
static func get_floor_06_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Holding Cells ---
	# 8×6 tiles, corridor, 0 enemies, no loot, connects a2
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "Holding Cells",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 6),
		"size_px": Vector2(8 * TILE, 6 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 6 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 6 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Blood Corridor ---
	# 8×4 tiles, corridor, Gladiator×1, connects a1 + hub (one-way from a1)
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "Blood Corridor",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 4),
		"size_px": Vector2(8 * TILE, 4 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "gladiator", "count": 1}],
		"loot": [],
		"connections": ["a1", "hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 4 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 4 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Arena Floor ---
	# 14×12 tiles, hub, Gladiator×2 + Berserker×1, SMG
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Arena Floor",
		"room_type": "hub",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2(14 * TILE, 12 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [
			{"type": "gladiator", "count": 2},
			{"type": "berserker", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "smg"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 12 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 12 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(
			Vector2(14 * TILE, 12 * TILE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Gladiator Pit ---
	# 12×10 tiles, gallery (wave room), Gladiator×1 + Berserker×1 (waves), bat
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "Gladiator Pit",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 10),
		"size_px": Vector2(12 * TILE, 10 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "gladiator", "count": 1}, {"type": "berserker", "count": 1}],
		"loot": [{"type": "weapon", "id": "bat"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 10 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 10 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 10 * TILE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — Armory ---
	# 6×6 tiles, storage, Staff×1, random weapon + ammo
	rooms["b2"] = RoomConfig._make({
		"room_id": "b2",
		"room_name": "Armory",
		"room_type": "storage",
		"size_tiles": Vector2i(6, 6),
		"size_px": Vector2(6 * TILE, 6 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "weapon", "id": "random"}, {"type": "ammo"}],
		"connections": ["b1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(6 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(6 * TILE, 6 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(6 * TILE, 6 * TILE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — The Gauntlet ---
	# 12×8 tiles, trap, Berserker×2 + Gladiator×1, cult_relic (rare), LOCKED
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "The Gauntlet",
		"room_type": "trap",
		"size_tiles": Vector2i(12, 8),
		"size_px": Vector2(12 * TILE, 8 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "berserker", "count": 2}, {"type": "gladiator", "count": 1}],
		"loot": [{"type": "weapon", "id": "cult_relic", "rarity": "rare"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 8 * TILE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — Champion's Hall ---
	# 8×8 tiles, chamber, Guard×1, KEY(50%) + stat_upgrade
	rooms["c2"] = RoomConfig._make({
		"room_id": "c2",
		"room_name": "Champion's Hall",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE, 8 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "guard", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "stat_upgrade"}],
		"connections": ["c1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Spectator Stands ---
	# 10×8 tiles, gallery, Staff×2 + Guard×1, random weapon
	rooms["d1"] = RoomConfig._make({
		"room_id": "d1",
		"room_name": "Spectator Stands",
		"room_type": "gallery",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "staff", "count": 2}, {"type": "guard", "count": 1}],
		"loot": [{"type": "weapon", "id": "random"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — Beast Cages ---
	# 8×8 tiles, storage, Berserker×1, KEY(50%) + ammo
	rooms["d2"] = RoomConfig._make({
		"room_id": "d2",
		"room_name": "Beast Cages",
		"room_type": "storage",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE, 8 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "berserker", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}],
		"connections": ["d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — The Arena ---
	# 16×14 tiles, boss, Champion×1, cult artifact
	rooms["boss"] = RoomConfig._make({
		"room_id": "boss",
		"room_name": "The Arena",
		"room_type": "boss",
		"size_tiles": Vector2i(16, 14),
		"size_px": Vector2(16 * TILE, 14 * TILE),
		"floor_color": F6_FLOOR,
		"wall_color": F6_WALL,
		"enemies": [{"type": "boss_champion", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(16 * TILE, 14 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(16 * TILE, 14 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(16 * TILE, 14 * TILE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms
