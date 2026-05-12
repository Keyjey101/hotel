class_name RoomConfig
extends RefCounted

## RoomConfig — Data for a single room in Floor 1: Service Underground.
## All data from 13_FLOOR_DESIGN.md section 2.

var room_id: String
var room_name: String
var room_type: String           # corridor/chamber/storage/hub/boss
var size_tiles: Vector2i
var size_px: Vector2
var floor_color: Color
var wall_color: Color
var enemies: Array[Dictionary]  # [{"type": "staff", "count": 2}]
var loot: Array[Dictionary]     # [{"type": "weapon", "id": "knife"}]
var connections: Array[String]  # room_ids this room connects to
var spawn_point_positions: Array[Vector2]
var loot_zone_positions: Array[Vector2]
var door_positions: Array[Dictionary]  # [{"pos": Vector2, "target_room": "a2", "entry_side": "right"}]
var branch: String              # a/b/c/d/hub/boss
var is_locked: bool = false


static func _make(cfg: Dictionary):
	# Create instance via load since class_name self-reference not allowed in static
	var script := load("res://scripts/world/floor_01_config.gd")
	var rc = script.new()
	rc.room_id = cfg["room_id"]
	rc.room_name = cfg["room_name"]
	rc.room_type = cfg["room_type"]
	rc.size_tiles = cfg["size_tiles"]
	rc.size_px = cfg["size_px"]
	rc.floor_color = cfg["floor_color"]
	rc.wall_color = cfg["wall_color"]
	rc.enemies = cfg["enemies"]
	rc.loot = cfg["loot"]
	rc.connections = cfg["connections"]
	rc.spawn_point_positions = cfg["spawn_point_positions"]
	rc.loot_zone_positions = cfg["loot_zone_positions"]
	rc.door_positions = cfg["door_positions"]
	rc.branch = cfg["branch"]
	rc.is_locked = cfg.get("is_locked", false)
	return rc


## Generate spawn points evenly across floor area with margin.
static func _gen_spawn_points(size_px: Vector2, count: int, margin: float = 48.0, spacing: float = 64.0) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var inner_w := size_px.x - 2.0 * margin
	var inner_h := size_px.y - 2.0 * margin
	if inner_w <= 0.0 or inner_h <= 0.0:
		points.append(Vector2(size_px.x * 0.5, size_px.y * 0.5))
		return points
	var cols := maxi(1, int(inner_w / spacing) + 1)
	var rows := maxi(1, int(inner_h / spacing) + 1)
	var step_x := inner_w / maxi(1, cols - 1) if cols > 1 else 0.0
	var step_y := inner_h / maxi(1, rows - 1) if rows > 1 else 0.0
	for r in range(rows):
		for c in range(cols):
			points.append(Vector2(margin + c * step_x, margin + r * step_y))
	# Trim or pad to desired count
	while points.size() > count:
		points.pop_back()
	while points.size() < count:
		var idx := points.size()
		points.append(Vector2(
			margin + fposmod(float(hash(str(idx) + "x")), size_px.x - 2.0 * margin),
			margin + fposmod(float(hash(str(idx) + "y")), size_px.y - 2.0 * margin)
		))
	return points


## Generate loot zone positions in strategic locations (corners, walls).
static func _gen_loot_zones(size_px: Vector2, count: int) -> Array[Vector2]:
	var zones: Array[Vector2] = []
	var margin := 40.0
	var candidates := [
		Vector2(margin, margin),
		Vector2(size_px.x - margin, margin),
		Vector2(margin, size_px.y - margin),
		Vector2(size_px.x - margin, size_px.y - margin),
		Vector2(size_px.x * 0.5, margin),
		Vector2(size_px.x * 0.5, size_px.y - margin),
		Vector2(margin, size_px.y * 0.5),
		Vector2(size_px.x - margin, size_px.y * 0.5),
	]
	for i in range(mini(count, candidates.size())):
		zones.append(candidates[i])
	while zones.size() < count:
		var idx := zones.size()
		zones.append(Vector2(
			margin + fposmod(float(hash(str(idx + 100) + "lx")), size_px.x - 2.0 * margin),
			margin + fposmod(float(hash(str(idx + 100) + "ly")), size_px.y - 2.0 * margin)
		))
	return zones


## Place door at center of wall facing connected room.
static func _gen_doors(size_px: Vector2, connections: Array[String], sides: Array[String]) -> Array[Dictionary]:
	var doors: Array[Dictionary] = []
	var w := size_px.x
	var h := size_px.y
	for i in range(connections.size()):
		var side: String = sides[i] if i < sides.size() else "bottom"
		var pos := Vector2.ZERO
		match side:
			"top":
				pos = Vector2(w * 0.5, 0.0)
			"bottom":
				pos = Vector2(w * 0.5, h)
			"left":
				pos = Vector2(0.0, h * 0.5)
			"right":
				pos = Vector2(w, h * 0.5)
		doors.append({"pos": pos, "target_room": connections[i], "entry_side": side})
	return doors


## Floor 1 palette
const FLOOR_COLOR := Color(0.290, 0.290, 0.243, 1.0)  # #4A4A3E
const WALL_COLOR := Color(0.165, 0.165, 0.180, 1.0)   # #2A2A2E
const TILE_SIZE := 32


## Return all 10 rooms for Floor 1 as Dictionary[room_id -> RoomConfig].
static func get_floor_01_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Entry Shaft ---
	# 13_FLOOR_DESIGN.md §2.3: 8×6 tiles, corridor, 0 enemies, no loot, connects a2
	rooms["a1"] = _make({
		"room_id": "a1",
		"room_name": "Entry Shaft",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 6),
		"size_px": Vector2(8 * TILE_SIZE, 6 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": _gen_spawn_points(Vector2(8 * TILE_SIZE, 6 * TILE_SIZE), 8),
		"loot_zone_positions": [],
		"door_positions": _gen_doors(Vector2(8 * TILE_SIZE, 6 * TILE_SIZE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Service Corridor ---
	# §2.3: 12×4 tiles, corridor, Staff×2, Knife
	rooms["a2"] = _make({
		"room_id": "a2",
		"room_name": "Service Corridor",
		"room_type": "corridor",
		"size_tiles": Vector2i(12, 4),
		"size_px": Vector2(12 * TILE_SIZE, 4 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "staff", "count": 2}],
		"loot": [{"type": "weapon", "id": "knife"}],
		"connections": ["a1", "hub"],
		"spawn_point_positions": _gen_spawn_points(Vector2(12 * TILE_SIZE, 4 * TILE_SIZE), 8),
		"loot_zone_positions": _gen_loot_zones(Vector2(12 * TILE_SIZE, 4 * TILE_SIZE), 1),
		"door_positions": _gen_doors(Vector2(12 * TILE_SIZE, 4 * TILE_SIZE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — Boiler Room ---
	# §2.3: 14×12 tiles, hub, Staff×2 + Guard×1, Bat, 4 exits
	rooms["hub"] = _make({
		"room_id": "hub",
		"room_name": "Boiler Room",
		"room_type": "hub",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2(14 * TILE_SIZE, 12 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "staff", "count": 2}, {"type": "guard", "count": 1}],
		"loot": [{"type": "weapon", "id": "bat"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": _gen_spawn_points(Vector2(14 * TILE_SIZE, 12 * TILE_SIZE), 12),
		"loot_zone_positions": _gen_loot_zones(Vector2(14 * TILE_SIZE, 12 * TILE_SIZE), 2),
		"door_positions": _gen_doors(
			Vector2(14 * TILE_SIZE, 12 * TILE_SIZE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Laundry Room ---
	# §2.3: 10×8 tiles, chamber, Staff×3, Pistol
	rooms["b1"] = _make({
		"room_id": "b1",
		"room_name": "Laundry Room",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE_SIZE, 8 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "staff", "count": 3}],
		"loot": [{"type": "weapon", "id": "pistol"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": _gen_spawn_points(Vector2(10 * TILE_SIZE, 8 * TILE_SIZE), 10),
		"loot_zone_positions": _gen_loot_zones(Vector2(10 * TILE_SIZE, 8 * TILE_SIZE), 2),
		"door_positions": _gen_doors(Vector2(10 * TILE_SIZE, 8 * TILE_SIZE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — Linen Storage ---
	# §2.3: 6×6 tiles, storage, Staff×1, Ammo + stat_upgrade + KEY(50%)
	rooms["b2"] = _make({
		"room_id": "b2",
		"room_name": "Linen Storage",
		"room_type": "storage",
		"size_tiles": Vector2i(6, 6),
		"size_px": Vector2(6 * TILE_SIZE, 6 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "staff", "count": 1}],
		"loot": [{"type": "ammo"}, {"type": "stat_upgrade"}, {"type": "key", "chance": 0.5}],
		"connections": ["b1"],
		"spawn_point_positions": _gen_spawn_points(Vector2(6 * TILE_SIZE, 6 * TILE_SIZE), 8),
		"loot_zone_positions": _gen_loot_zones(Vector2(6 * TILE_SIZE, 6 * TILE_SIZE), 3),
		"door_positions": _gen_doors(Vector2(6 * TILE_SIZE, 6 * TILE_SIZE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — Meat Processing ---
	# §2.3: 12×10 tiles, chamber, Handler×1 + Staff×2, Axe, LOCKED
	rooms["c1"] = _make({
		"room_id": "c1",
		"room_name": "Meat Processing",
		"room_type": "chamber",
		"size_tiles": Vector2i(12, 10),
		"size_px": Vector2(12 * TILE_SIZE, 10 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "handler", "count": 1}, {"type": "staff", "count": 2}],
		"loot": [{"type": "weapon", "id": "axe"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": _gen_spawn_points(Vector2(12 * TILE_SIZE, 10 * TILE_SIZE), 10),
		"loot_zone_positions": _gen_loot_zones(Vector2(12 * TILE_SIZE, 10 * TILE_SIZE), 2),
		"door_positions": _gen_doors(Vector2(12 * TILE_SIZE, 10 * TILE_SIZE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — Freezer Room ---
	# §2.3: 8×8 tiles, chamber, Guard×1, KEY(50%) + ammo
	rooms["c2"] = _make({
		"room_id": "c2",
		"room_name": "Freezer Room",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE_SIZE, 8 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "guard", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}],
		"connections": ["c1"],
		"spawn_point_positions": _gen_spawn_points(Vector2(8 * TILE_SIZE, 8 * TILE_SIZE), 8),
		"loot_zone_positions": _gen_loot_zones(Vector2(8 * TILE_SIZE, 8 * TILE_SIZE), 2),
		"door_positions": _gen_doors(Vector2(8 * TILE_SIZE, 8 * TILE_SIZE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Maintenance Tunnels ---
	# §2.3: 16×4 tiles, corridor, Staff×2 + Guard×1, Wire
	rooms["d1"] = _make({
		"room_id": "d1",
		"room_name": "Maintenance Tunnels",
		"room_type": "corridor",
		"size_tiles": Vector2i(16, 4),
		"size_px": Vector2(16 * TILE_SIZE, 4 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "staff", "count": 2}, {"type": "guard", "count": 1}],
		"loot": [{"type": "weapon", "id": "wire"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": _gen_spawn_points(Vector2(16 * TILE_SIZE, 4 * TILE_SIZE), 8),
		"loot_zone_positions": _gen_loot_zones(Vector2(16 * TILE_SIZE, 4 * TILE_SIZE), 1),
		"door_positions": _gen_doors(Vector2(16 * TILE_SIZE, 4 * TILE_SIZE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — Generator Room ---
	# §2.3: 10×8 tiles, storage, Guard×1 + Staff×1, KEY(if not B2) + random weapon
	rooms["d2"] = _make({
		"room_id": "d2",
		"room_name": "Generator Room",
		"room_type": "storage",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE_SIZE, 8 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "guard", "count": 1}, {"type": "staff", "count": 1}],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "weapon", "id": "random"}],
		"connections": ["d1"],
		"spawn_point_positions": _gen_spawn_points(Vector2(10 * TILE_SIZE, 8 * TILE_SIZE), 9),
		"loot_zone_positions": _gen_loot_zones(Vector2(10 * TILE_SIZE, 8 * TILE_SIZE), 2),
		"door_positions": _gen_doors(Vector2(10 * TILE_SIZE, 8 * TILE_SIZE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — Head Chef's Kitchen ---
	# §2.3: 16×14 tiles, boss, Head Chef×1, cult artifact
	rooms["boss"] = _make({
		"room_id": "boss",
		"room_name": "Head Chef's Kitchen",
		"room_type": "boss",
		"size_tiles": Vector2i(16, 14),
		"size_px": Vector2(16 * TILE_SIZE, 14 * TILE_SIZE),
		"floor_color": FLOOR_COLOR,
		"wall_color": WALL_COLOR,
		"enemies": [{"type": "head_chef", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": _gen_spawn_points(Vector2(16 * TILE_SIZE, 14 * TILE_SIZE), 12),
		"loot_zone_positions": _gen_loot_zones(Vector2(16 * TILE_SIZE, 14 * TILE_SIZE), 2),
		"door_positions": _gen_doors(Vector2(16 * TILE_SIZE, 14 * TILE_SIZE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms
