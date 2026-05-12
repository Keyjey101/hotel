## Floor 9 config — Satan's Sanctum (Reality Shift).
## All room data from 13_FLOOR_DESIGN.md section 10.
## Palette: SHIFTING — Phase 1 #F0F0F0 sterile white, Phase 2 #F0E0E0 warm flesh,
##   Phase 3 #1A0A0A encroaching black, Phase 4 #FF0000 pure red → #000000 void.
## Blood: shifts with palette | BG: shifts with phases
## 8 rooms — intentionally smaller, escalation not sprawl.

const F9_FLOOR_P1 := Color(0.941, 0.941, 0.941, 1.0)  # #F0F0F0 sterile white
const F9_FLOOR_P3 := Color(0.102, 0.039, 0.039, 1.0)  # #1A0A0A encroaching black
const F9_WALL := Color(0.08, 0.08, 0.08, 1.0)
const TILE := 32


## Return all 8 rooms for Floor 9 as Dictionary[room_id -> RoomConfig].
static func get_floor_09_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — White Corridor ---
	# 8×4 tiles, corridor, Demon×2-3, sterile wrong
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "White Corridor",
		"room_type": "corridor",
		"size_tiles": Vector2i(8, 4),
		"size_px": Vector2i(8 * TILE, 4 * TILE),
		"floor_color": F9_FLOOR_P1,
		"wall_color": F9_WALL,
		"enemies": [{"type": "demon", "count": 2}],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(8 * TILE, 4 * TILE), 6),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2i(8 * TILE, 4 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — The Memory Hall ---
	# 14×4 tiles, corridor, NO enemies, narrative room
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "The Memory Hall",
		"room_type": "service",
		"size_tiles": Vector2i(14, 4),
		"size_px": Vector2i(14 * TILE, 4 * TILE),
		"floor_color": F9_FLOOR_P1,
		"wall_color": F9_WALL,
		"enemies": [],
		"loot": [],
		"connections": ["a1", "hub"],
		"spawn_point_positions": [],
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2i(14 * TILE, 4 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Waiting Room ---
	# 14×12 tiles, hub, NO enemies (Sister encounter Phase 1)
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Waiting Room",
		"room_type": "hub",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2i(14 * TILE, 12 * TILE),
		"floor_color": Color(0.941, 0.878, 0.878, 1.0),  # #F0E0E0 warm flesh
		"wall_color": F9_WALL,
		"enemies": [],
		"loot": [],
		"connections": ["a2", "b1", "c1", "boss1"],
		"spawn_point_positions": [],
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(14 * TILE, 12 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(
			Vector2i(14 * TILE, 12 * TILE),
			["a2", "b1", "c1", "boss1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — The Mirror Room ---
	# 10×8 tiles, chamber, NO enemies (Sister encounter Phase 2)
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "The Mirror Room",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2i(10 * TILE, 8 * TILE),
		"floor_color": Color(0.941, 0.878, 0.878, 1.0),
		"wall_color": F9_WALL,
		"enemies": [],
		"loot": [],
		"connections": ["hub"],
		"spawn_point_positions": [],
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2i(10 * TILE, 8 * TILE), ["hub"], ["left"]),
		"branch": "b",
	})

	# --- C1 — The Throne Approach (locked) ---
	# 10×8 tiles, corridor, Demon×2-3
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "The Throne Approach",
		"room_type": "corridor",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2i(10 * TILE, 8 * TILE),
		"floor_color": F9_FLOOR_P3,
		"wall_color": F9_WALL,
		"enemies": [{"type": "demon", "count": 2}],
		"loot": [],
		"connections": ["hub", "boss1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(10 * TILE, 8 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2i(10 * TILE, 8 * TILE), ["hub", "boss1"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- BOSS 1 — The Sister's Chamber ---
	# 14×12 tiles, boss, Sister encounter (narrative + optional combat)
	rooms["boss1"] = RoomConfig._make({
		"room_id": "boss1",
		"room_name": "The Sister's Chamber",
		"room_type": "boss",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2i(14 * TILE, 12 * TILE),
		"floor_color": Color(0.941, 0.878, 0.878, 1.0),
		"wall_color": F9_WALL,
		"enemies": [{"type": "sister", "count": 1}],
		"loot": [],
		"connections": ["hub", "boss2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(14 * TILE, 12 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(14 * TILE, 12 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(
			Vector2i(14 * TILE, 12 * TILE),
			["hub", "boss2"],
			["top", "bottom"]
		),
		"branch": "boss",
	})

	# --- BOSS 2 — Satan's Sanctum ---
	# 18×14 tiles, boss, abstract geometry, Satan fight
	rooms["boss2"] = RoomConfig._make({
		"room_id": "boss2",
		"room_name": "Satan's Sanctum",
		"room_type": "boss",
		"size_tiles": Vector2i(18, 14),
		"size_px": Vector2i(18 * TILE, 14 * TILE),
		"floor_color": Color(0.04, 0.04, 0.04, 1.0),  # #0A0A0A near void
		"wall_color": Color(0.02, 0.02, 0.02, 1.0),
		"enemies": [{"type": "satan", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "void_contract"}],
		"connections": ["boss1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2i(18 * TILE, 14 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2i(18 * TILE, 14 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(
			Vector2i(18 * TILE, 14 * TILE),
			["boss1"],
			["top"]
		),
		"branch": "boss",
	})

	return rooms


## Apply Floor 9-specific elements: shifting palette, Memory Hall fragments
static func apply_floor_09_extras(room: RoomInstance) -> void:
	var rid: String = room.room_id

	if rid == "a2":
		_add_memory_hall_fragments(room)

	if rid in ["hub", "boss1", "b1"]:
		_add_passage_text(room)


## Memory Hall: tile accents from all 8 previous floors
static func _add_memory_hall_fragments(room: RoomInstance) -> void:
	var size := room.room_bounds.size

	# Left wall accents (Floors 1, 3, 5, 7)
	var left_colors: Array[Color] = [
		Color(0.478, 0.353, 0.180, 0.7),   # Floor 1 rust
		Color(0.722, 0.533, 0.043, 0.7),   # Floor 3 gold
		Color(0.235, 0.745, 0.690, 0.7),   # Floor 5 turquoise
		Color(0.102, 0.102, 0.416, 0.7),   # Floor 7 indigo
	]

	# Right wall accents (Floors 2, 4, 6, 8)
	var right_colors: Array[Color] = [
		Color(0.545, 0.0, 0.216, 0.7),     # Floor 2 crimson
		Color(1.0, 0.843, 0.0, 0.7),       # Floor 4 gold
		Color(0.8, 0.067, 0.0, 0.7),       # Floor 6 blood red
		Color(0.855, 0.647, 0.125, 0.7),   # Floor 8 royal gold
	]

	var segment_width := size.x / 4.0

	# Left wall fragments
	for i in range(4):
		var frag := ColorRect.new()
		frag.name = "MemoryLeft%d" % i
		frag.size = Vector2(3.0 * 32, 32)  # 3 tiles wide, 1 tile tall
		frag.position = Vector2(segment_width * i + 8.0, 8.0)
		frag.color = left_colors[i]
		frag.z_index = -1
		room.add_child(frag)

	# Right wall fragments
	for i in range(4):
		var frag := ColorRect.new()
		frag.name = "MemoryRight%d" % i
		frag.size = Vector2(3.0 * 32, 32)
		frag.position = Vector2(segment_width * i + 8.0, size.y - 40.0)
		frag.color = right_colors[i]
		frag.z_index = -1
		room.add_child(frag)

	# Passage text label
	var passage := Label.new()
	passage.text = "the building is remembering itself through you"
	passage.position = Vector2(size.x * 0.15, size.y * 0.45)
	passage.add_theme_font_size_override("font_size", 6)
	passage.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 0.5))
	passage.z_index = 10
	room.add_child(passage)


## Narrative passage text in Sister encounter rooms
static func _add_passage_text(room: RoomInstance) -> void:
	var size := room.room_bounds.size

	var texts: Array[String] = [
		"Signed: [REDACTED]. Price: Eternal service.",
		"She volunteered. She wanted this.",
		"The Hotel doesn't have guests. It has inmates.",
	]

	for i in range(texts.size()):
		var label := Label.new()
		label.text = texts[i]
		label.position = Vector2(20.0 + i * 160.0, size.y - 20.0)
		label.add_theme_font_size_override("font_size", 5)
		label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 0.3))
		label.z_index = 10
		room.add_child(label)
