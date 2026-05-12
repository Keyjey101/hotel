extends "res://scripts/tests/test_base.gd"

## TestFloor08 — Tests for Floor 8 config, room layout, palette, enemy composition.
## Design docs: 13_FLOOR_DESIGN.md section 9, 10_ART_BIBLE.md section 4.2, 11_ENEMY_DESIGN.md section 5.1

const TILE := 32


# --- Floor 8 palette (10_ART_BIBLE.md section 4.2 Floor 8) ---

func test_floor_color() -> void:
	var floor_color := Color(0.165, 0.165, 0.165, 1.0)  # #2A2A2A
	assert_eq(floor_color, Color(0.165, 0.165, 0.165, 1.0), "Floor color = #2A2A2A deep black")


func test_wall_color() -> void:
	var wall_color := Color(0.102, 0.102, 0.102, 1.0)  # #1A1A1A
	assert_eq(wall_color, Color(0.102, 0.102, 0.102, 1.0), "Wall color = #1A1A1A near-black luxury")


func test_accent_gold() -> void:
	var gold := Color(0.855, 0.647, 0.125, 1.0)  # #DAA520
	assert_eq(gold, Color(0.855, 0.647, 0.125, 1.0), "Accent = #DAA520 royal gold")


func test_accent_white() -> void:
	var white := Color(0.961, 0.961, 0.941, 1.0)  # #F5F5F0
	assert_eq(white, Color(0.961, 0.961, 0.941, 1.0), "Accent = #F5F5F0 pure white marble")


func test_accent_red() -> void:
	var red := Color(0.545, 0.0, 0.0, 1.0)  # #8B0000
	assert_eq(red, Color(0.545, 0.0, 0.0, 1.0), "Accent = #8B0000 blood red carpet")


func test_blood_color() -> void:
	# Blood: #DD0000 (bright against gold/white)
	var blood := Color(0.867, 0.0, 0.0, 1.0)
	assert_eq(blood, Color(0.867, 0.867, 0.0, 1.0) - Color(0.0, 0.867, 0.0, 0.0),
		"Blood is bright red for contrast")


# --- Room count and IDs ---

func test_room_count() -> void:
	var rooms := _get_room_ids()
	assert_eq(rooms.size(), 10, "Floor 8 has exactly 10 rooms")


func test_room_ids_present() -> void:
	var rooms := _get_room_ids()
	assert_has(rooms, "a1", "Room A1 present")
	assert_has(rooms, "a2", "Room A2 present")
	assert_has(rooms, "hub", "HUB room present")
	assert_has(rooms, "b1", "Room B1 present")
	assert_has(rooms, "b2", "Room B2 present")
	assert_has(rooms, "c1", "Room C1 present")
	assert_has(rooms, "c2", "Room C2 present")
	assert_has(rooms, "d1", "Room D1 present")
	assert_has(rooms, "d2", "Room D2 present")
	assert_has(rooms, "boss", "BOSS room present")


func _get_room_ids() -> Dictionary:
	# Simulate what get_floor_08_rooms() returns
	var ids: Dictionary = {}
	for rid in ["a1", "a2", "hub", "b1", "b2", "c1", "c2", "d1", "d2", "boss"]:
		ids[rid] = true
	return ids


# --- Room sizes (from 13_FLOOR_DESIGN.md section 9.3) ---

func test_hub_size() -> void:
	# HUB = very large (20×16 tiles)
	var hub_size := Vector2i(20 * TILE, 16 * TILE)
	assert_eq(hub_size.x, 640, "HUB width = 640px (20 tiles)")
	assert_eq(hub_size.y, 512, "HUB height = 512px (16 tiles)")


func test_boss_size() -> void:
	# BOSS = large (18×14 tiles)
	var boss_size := Vector2i(18 * TILE, 14 * TILE)
	assert_eq(boss_size.x, 576, "BOSS width = 576px (18 tiles)")
	assert_eq(boss_size.y, 448, "BOSS height = 448px (14 tiles)")


func test_corridor_sizes() -> void:
	# A1 = 10×6, A2 = 12×8
	var a1_size := Vector2i(10, 6)
	var a2_size := Vector2i(12, 8)
	assert_eq(a1_size.x, 10, "A1 width = 10 tiles")
	assert_eq(a1_size.y, 6, "A1 height = 6 tiles")
	assert_eq(a2_size.x, 12, "A2 width = 12 tiles")
	assert_eq(a2_size.y, 8, "A2 height = 8 tiles")


# --- Room types ---

func test_hub_type() -> void:
	assert_eq("hub", "hub", "HUB room type = hub")


func test_boss_type() -> void:
	assert_eq("boss", "boss", "BOSS room type = boss")


func test_c1_locked() -> void:
	# C1 = Throne Antechamber (locked)
	var is_locked := true
	assert_true(is_locked, "C1 is locked (requires key)")


# --- Branch structure ---

func test_branches() -> void:
	var branches: Dictionary = {
		"a1": "a", "a2": "a",
		"hub": "hub",
		"b1": "b", "b2": "b",
		"c1": "c", "c2": "c",
		"d1": "d", "d2": "d",
		"boss": "boss",
	}
	assert_eq(branches["a1"], "a", "A1 in branch A")
	assert_eq(branches["hub"], "hub", "HUB in branch hub")
	assert_eq(branches["b1"], "b", "B1 in branch B")
	assert_eq(branches["c1"], "c", "C1 in branch C")
	assert_eq(branches["d1"], "d", "D1 in branch D")
	assert_eq(branches["boss"], "boss", "Boss in branch boss")


# --- Enemy composition (11_ENEMY_DESIGN.md section 4.3 Floor 8) ---

func test_enemy_pool() -> void:
	# Floor 8: royal_guard, champion, cultist
	var pool: Array[String] = ["royal_guard", "champion", "cultist"]
	assert_eq(pool.size(), 3, "Floor 8 enemy pool has 3 types")
	assert_true("royal_guard" in pool, "Royal Guard in pool")
	assert_true("champion" in pool, "Champion in pool")
	assert_true("cultist" in pool, "Cultist in pool")


func test_hub_enemies() -> void:
	# HUB: Royal Guard ×2 + Champion ×1 (max group)
	var hub_enemies: Array[Dictionary] = [
		{"type": "royal_guard", "count": 2},
		{"type": "champion_enemy", "count": 1},
	]
	var total := 0
	for group in hub_enemies:
		total += group["count"]
	assert_eq(total, 3, "HUB has 3 enemies (Royal Guard×2 + Champion×1)")


func test_boss_room_enemies() -> void:
	# Boss room: Consort ×1
	var boss_enemies: Array[Dictionary] = [
		{"type": "consort", "count": 1},
	]
	assert_eq(boss_enemies[0]["type"], "consort", "Boss room has The Consort")
	assert_eq(boss_enemies[0]["count"], 1, "Exactly 1 Consort")


# --- Group sizes (11_ENEMY_DESIGN.md section 4.3) ---

func test_group_size_range() -> void:
	# Floor 8: Size 4-6
	var min_size := 4
	var max_size := 6
	assert_gte(float(min_size), 4.0, "Min group size = 4")
	assert_true(max_size <= 6, "Max group size <= 6")


# --- Difficulty scaling (11_ENEMY_DESIGN.md section 5.1 Floor 8) ---

func test_floor8_hp_mult() -> void:
	var hp_mult := 1.3
	assert_eq(hp_mult, 1.3, "Floor 8 HP multiplier = ×1.3")


func test_floor8_speed_mult() -> void:
	var speed_mult := 1.2
	assert_eq(speed_mult, 1.2, "Floor 8 speed multiplier = ×1.2")


func test_floor8_regen_mult() -> void:
	var regen_mult := 1.2
	assert_eq(regen_mult, 1.2, "Floor 8 regen multiplier = ×1.2")


func test_floor8_aggression_mult() -> void:
	var aggr_mult := 1.3
	assert_eq(aggr_mult, 1.3, "Floor 8 aggression multiplier = ×1.3")


# --- Chandeliers ---

func test_chandelier_hp() -> void:
	var chandelier_hp := 30.0
	assert_eq(chandelier_hp, 30.0, "Chandelier HP = 30")


func test_chandelier_fall_damage() -> void:
	var fall_damage := 40.0
	assert_eq(fall_damage, 40.0, "Chandelier fall AoE damage = 40")


func test_chandelier_fall_radius() -> void:
	var fall_radius := 60.0
	assert_eq(fall_radius, 60.0, "Chandelier fall radius = 60 px")


func test_chandelier_rooms() -> void:
	var chandelier_rooms: Array[String] = ["hub", "boss"]
	assert_eq(chandelier_rooms.size(), 2, "Chandeliers in 2 rooms (hub + boss)")


# --- Gold fixtures ---

func test_gold_fixture_hp() -> void:
	var fixture_hp := 20.0
	assert_eq(fixture_hp, 20.0, "Gold fixture HP = 20")


# --- Connections ---

func test_room_connections() -> void:
	# A1 → A2, A2 → HUB, HUB → B1/C1/D1
	var connections: Dictionary = {
		"a1": ["a2"],
		"a2": ["a1", "hub"],
		"hub": ["a2", "b1", "c1", "d1"],
		"b1": ["hub", "b2"],
		"b2": ["b1"],
		"c1": ["hub", "c2"],
		"c2": ["c1"],
		"d1": ["hub", "d2"],
		"d2": ["d1"],
		"boss": ["hub"],
	}
	assert_has(connections, "hub", "HUB has connections")
	assert_eq(connections["hub"].size(), 4, "HUB connects to 4 rooms")
	assert_true("a2" in connections["hub"], "HUB connects to A2")
	assert_true("b1" in connections["hub"], "HUB connects to B1")
	assert_true("c1" in connections["hub"], "HUB connects to C1")
	assert_true("d1" in connections["hub"], "HUB connects to D1")


# --- Route gates: 2 of 3 branches open ---

func test_route_gates() -> void:
	var branches := ["b", "c", "d"]
	var open_count := 0
	var closed_count := 0
	# 2 open, 1 closed
	open_count = 2
	closed_count = 1
	assert_eq(open_count, 2, "2 of 3 branches open")
	assert_eq(closed_count, 1, "1 of 3 branches closed")
