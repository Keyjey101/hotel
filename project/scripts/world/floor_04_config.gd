## Floor 4 config — Vault (Greed).
## All room data from 13_FLOOR_DESIGN.md section 5.
## Palette: floor #0E0E1E, walls #1A1A3A, accent #FFD700 gold, steel #5A6A7A, silver #C0C8D0.

const F4_FLOOR := Color(0.055, 0.055, 0.118, 1.0)  # #0E0E1E dark navy bg
const F4_WALL := Color(0.102, 0.102, 0.227, 1.0)   # #1A1A3A dark navy
const TILE := 32


## Return all 10 rooms for Floor 4 as Dictionary[room_id -> RoomConfig].
static func get_floor_04_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Security Checkpoint ---
	# 8×6 tiles, corridor, 0 enemies, no loot, connects a2
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "Security Checkpoint",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 6),
		"size_px": Vector2i(8 * TILE, 6 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 6 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 6 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Steel Corridor ---
	# 10×4 tiles, corridor, Guard×2, ammo
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "Steel Corridor",
		"room_type": "corridor",
		"size_tiles": Vector2i(10, 4),
		"size_px": Vector2i(10 * TILE, 4 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "guard", "count": 2}],
		"loot": [{"type": "ammo"}],
		"connections": ["a1", "hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 4 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 4 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 4 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Counting Room ---
	# 14×10 tiles, hub, Banker×1 + Guard×2 + Staff×2, SMG
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Counting Room",
		"room_type": "hub",
		"size_tiles": Vector2i(14, 10),
		"size_px": Vector2i(14 * TILE, 10 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [
			{"type": "banker", "count": 1},
			{"type": "guard", "count": 2},
			{"type": "staff", "count": 2},
		],
		"loot": [{"type": "weapon", "id": "smg"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 10 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 10 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(
			Vector2i(14 * TILE, 10 * TILE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Safety Deposit Wing ---
	# 10×8 tiles, chamber, Guard×2 + Staff×1, shotgun
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "Safety Deposit Wing",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2i(10 * TILE, 8 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "guard", "count": 2}, {"type": "staff", "count": 1}],
		"loot": [{"type": "weapon", "id": "shotgun"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — The Archive ---
	# 6×6 tiles, storage, Staff×1, ammo + stat_upgrade + KEY(50%)
	rooms["b2"] = RoomConfig._make({
		"room_id": "b2",
		"room_name": "The Archive",
		"room_type": "storage",
		"size_tiles": Vector2i(6, 6),
		"size_px": Vector2i(6 * TILE, 6 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "ammo"}, {"type": "stat_upgrade"}, {"type": "key", "chance": 0.5}],
		"connections": ["b1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(6 * TILE, 6 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(6 * TILE, 6 * TILE), 3),
		"door_positions": RoomConfig._gen_doors(Vector2(6 * TILE, 6 * TILE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — Laser Grid Hall ---
	# 12×8 tiles, trap, Banker×1 + Vault Drone×2, cult_pistol (rare), LOCKED
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "Laser Grid Hall",
		"room_type": "trap",
		"size_tiles": Vector2i(12, 8),
		"size_px": Vector2i(12 * TILE, 8 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "banker", "count": 1}, {"type": "vault_drone", "count": 2}],
		"loot": [{"type": "weapon", "id": "cult_pistol", "rarity": "rare"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 8 * TILE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — The Inner Vault ---
	# 8×8 tiles, chamber, Guard×1, KEY(50%) + ammo + cult_artifact(10%)
	rooms["c2"] = RoomConfig._make({
		"room_id": "c2",
		"room_name": "The Inner Vault",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2i(8 * TILE, 8 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "guard", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}, {"type": "cult_artifact", "chance": 0.1}],
		"connections": ["c1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Gold Storage ---
	# 12×8 tiles, gallery, Banker×1 + Guard×2, axe
	rooms["d1"] = RoomConfig._make({
		"room_id": "d1",
		"room_name": "Gold Storage",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 8),
		"size_px": Vector2i(12 * TILE, 8 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "banker", "count": 1}, {"type": "guard", "count": 2}],
		"loot": [{"type": "weapon", "id": "axe"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 8 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 8 * TILE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — Coin Minting ---
	# 8×8 tiles, storage, Staff×1 + Guard×1, KEY(50%) + stat_upgrade
	rooms["d2"] = RoomConfig._make({
		"room_id": "d2",
		"room_name": "Coin Minting",
		"room_type": "storage",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2i(8 * TILE, 8 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "staff", "count": 1}, {"type": "guard", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "stat_upgrade"}],
		"connections": ["d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — The Accountant's Office ---
	# 14×12 tiles, boss, Accountant×1, cult artifact
	rooms["boss"] = RoomConfig._make({
		"room_id": "boss",
		"room_name": "The Accountant's Office",
		"room_type": "boss",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2i(14 * TILE, 12 * TILE),
		"floor_color": F4_FLOOR,
		"wall_color": F4_WALL,
		"enemies": [{"type": "accountant", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 12 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 12 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(14 * TILE, 12 * TILE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms
