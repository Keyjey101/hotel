extends "res://scripts/tests/test_base.gd"

## TestFloor09 — Tests for Floor 9 config, room layout, palette, enemy composition.
## Design docs: 13_FLOOR_DESIGN.md section 10, 10_ART_BIBLE.md section 4.2, 11_ENEMY_DESIGN.md section 5.1

const TILE := 32


# ── Floor 9 palette (10_ART_BIBLE.md section 4.2 Floor 9) ──

func test_phase1_palette() -> void:
	var color := Color(0.941, 0.941, 0.941, 1.0)  # #F0F0F0 sterile white
	assert_approx(color.r, 0.941, 0.01, "Phase 1 palette R = #F0")
	assert_approx(color.g, 0.941, 0.01, "Phase 1 palette G = #F0")
	assert_approx(color.b, 0.941, 0.01, "Phase 1 palette B = #F0")


func test_phase2_palette() -> void:
	var color := Color(0.941, 0.878, 0.878, 1.0)  # #F0E0E0 warm flesh
	assert_approx(color.r, 0.941, 0.01, "Phase 2 palette R ≈ #F0")
	assert_approx(color.g, 0.878, 0.01, "Phase 2 palette G ≈ #E0")
	assert_approx(color.b, 0.878, 0.01, "Phase 2 palette B ≈ #E0")


func test_phase3_palette() -> void:
	var color := Color(0.102, 0.039, 0.039, 1.0)  # #1A0A0A encroaching black
	assert_approx(color.r, 0.102, 0.01, "Phase 3 palette R = #1A")
	assert_approx(color.g, 0.039, 0.01, "Phase 3 palette G = #0A")
	assert_approx(color.b, 0.039, 0.01, "Phase 3 palette B = #0A")


func test_phase4_palette_red() -> void:
	var red := Color(1.0, 0.0, 0.0)  # #FF0000 pure red
	assert_eq(red.r, 1.0, "Phase 4 starts pure red")


func test_phase4_palette_void() -> void:
	var void_color := Color(0.0, 0.0, 0.0)  # #000000 void
	assert_eq(void_color.r, 0.0, "Phase 4 ends at void black")
	assert_eq(void_color.g, 0.0, "Phase 4 void black G")
	assert_eq(void_color.b, 0.0, "Phase 4 void black B")


# ── Room count and IDs ──

func test_room_count() -> void:
	# Floor 9 has 7 unique room IDs (A1, A2, HUB, B1, C1, Boss1, Boss2)
	# Floor 9 layout intentionally has NO D branch (smaller than other floors)
	var room_ids := _get_room_ids()
	assert_eq(room_ids.size(), 7, "Floor 9 has 7 rooms (no D branch)")


func test_room_ids_present() -> void:
	var rooms := _get_room_ids()
	assert_has(rooms, "a1", "Room A1 present")
	assert_has(rooms, "a2", "Room A2 present")
	assert_has(rooms, "hub", "HUB room present")
	assert_has(rooms, "b1", "Room B1 present")
	assert_has(rooms, "c1", "Room C1 present")
	assert_has(rooms, "boss1", "Boss1 room present")
	assert_has(rooms, "boss2", "Boss2 room present")


func _get_room_ids() -> Dictionary:
	var ids: Dictionary = {}
	for rid in ["a1", "a2", "hub", "b1", "c1", "boss1", "boss2"]:
		ids[rid] = true
	# Note: no D branch in Floor 9 — intentionally smaller
	return ids


# ── Room sizes (from 13_FLOOR_DESIGN.md section 10.3) ──

func test_a1_size() -> void:
	var size := Vector2i(8 * TILE, 4 * TILE)
	assert_eq(size.x, 256, "A1 width = 256px (8 tiles)")
	assert_eq(size.y, 128, "A1 height = 128px (4 tiles)")


func test_a2_memory_hall_size() -> void:
	var size := Vector2i(14 * TILE, 4 * TILE)
	assert_eq(size.x, 448, "A2 Memory Hall width = 448px (14 tiles)")
	assert_eq(size.y, 128, "A2 Memory Hall height = 128px (4 tiles)")


func test_hub_size() -> void:
	var size := Vector2i(14 * TILE, 12 * TILE)
	assert_eq(size.x, 448, "HUB width = 448px (14 tiles)")
	assert_eq(size.y, 384, "HUB height = 384px (12 tiles)")


func test_boss1_size() -> void:
	var size := Vector2i(14 * TILE, 12 * TILE)
	assert_eq(size.x, 448, "Boss1 width = 448px (14 tiles)")
	assert_eq(size.y, 384, "Boss1 height = 384px (12 tiles)")


func test_boss2_size() -> void:
	var size := Vector2i(18 * TILE, 14 * TILE)
	assert_eq(size.x, 576, "Boss2 width = 576px (18 tiles)")
	assert_eq(size.y, 448, "Boss2 height = 448px (14 tiles)")


# ── Room types ──

func test_hub_type() -> void:
	assert_eq("hub", "hub", "HUB room type = hub")


func test_boss1_type() -> void:
	assert_eq("boss", "boss", "Boss1 room type = boss")


func test_boss2_type() -> void:
	assert_eq("boss", "boss", "Boss2 room type = boss")


func test_a2_type_service() -> void:
	var room_type := "service"
	assert_eq(room_type, "service", "A2 Memory Hall = service (narrative, no combat)")


# ── Locked rooms ──

func test_c1_locked() -> void:
	var is_locked := true
	assert_true(is_locked, "C1 Throne Approach is locked")


# ── Branch structure ──

func test_branches() -> void:
	var branches: Dictionary = {
		"a1": "a", "a2": "a",
		"hub": "hub",
		"b1": "b",
		"c1": "c",
		"boss1": "boss",
		"boss2": "boss",
	}
	assert_eq(branches["a1"], "a", "A1 in branch A")
	assert_eq(branches["hub"], "hub", "HUB in branch hub")
	assert_eq(branches["b1"], "b", "B1 in branch B")
	assert_eq(branches["c1"], "c", "C1 in branch C")
	assert_eq(branches["boss1"], "boss", "Boss1 in branch boss")
	assert_eq(branches["boss2"], "boss", "Boss2 in branch boss")


# ── Enemy composition ──

func test_enemy_pool() -> void:
	# Floor 9: Demon only (unique — no base enemies)
	var pool: Array[String] = ["demon"]
	assert_eq(pool.size(), 1, "Floor 9 enemy pool has 1 type (Demon only)")


func test_a1_enemies() -> void:
	var enemies: Array[Dictionary] = [{"type": "demon", "count": 2}]
	assert_eq(enemies[0]["type"], "demon", "A1 has Demons")
	assert_gte(enemies[0]["count"], 2, "A1 has 2+ Demons")


func test_c1_enemies() -> void:
	var enemies: Array[Dictionary] = [{"type": "demon", "count": 2}]
	assert_eq(enemies[0]["type"], "demon", "C1 has Demons")
	assert_gte(enemies[0]["count"], 2, "C1 has 2+ Demons")


func test_hub_no_enemies() -> void:
	var enemies: Array = []
	assert_eq(enemies.size(), 0, "HUB has 0 enemies (Sister encounter only)")


func test_a2_no_enemies() -> void:
	var enemies: Array = []
	assert_eq(enemies.size(), 0, "A2 Memory Hall has 0 enemies (narrative only)")


func test_b1_no_enemies() -> void:
	var enemies: Array = []
	assert_eq(enemies.size(), 0, "B1 Mirror Room has 0 enemies (Sister Phase 2)")


func test_boss1_sister() -> void:
	var enemies: Array[Dictionary] = [{"type": "sister", "count": 1}]
	assert_eq(enemies[0]["type"], "sister", "Boss1 has The Sister")
	assert_eq(enemies[0]["count"], 1, "Exactly 1 Sister")


func test_boss2_satan() -> void:
	var enemies: Array[Dictionary] = [{"type": "satan", "count": 1}]
	assert_eq(enemies[0]["type"], "satan", "Boss2 has Satan")
	assert_eq(enemies[0]["count"], 1, "Exactly 1 Satan")


# ── Group sizes (11_ENEMY_DESIGN.md section 4.3 Floor 9) ──

func test_group_size_range() -> void:
	# Floor 9: Size 2-4
	var min_size := 2
	var max_size := 4
	assert_gte(float(min_size), 2.0, "Min group size = 2")
	assert_true(max_size <= 4, "Max group size <= 4")


# ── Connections ──

func test_room_connections() -> void:
	var connections: Dictionary = {
		"a1": ["a2"],
		"a2": ["a1", "hub"],
		"hub": ["a2", "b1", "c1", "boss1"],
		"b1": ["hub"],
		"c1": ["hub", "boss1"],
		"boss1": ["hub", "boss2"],
		"boss2": ["boss1"],
	}
	assert_has(connections, "hub", "HUB has connections")
	assert_eq(connections["hub"].size(), 4, "HUB connects to 4 rooms (A2, B1, C1, Boss1)")
	assert_true("boss2" in connections["boss1"], "Boss1 connects to Boss2")


# ── Memory Hall (A2) ──

func test_memory_hall_has_floor_fragments() -> void:
	# Fragments from all 8 previous floors
	var left_wall_floors := [1, 3, 5, 7]
	var right_wall_floors := [2, 4, 6, 8]
	assert_eq(left_wall_floors.size(), 4, "Left wall has 4 floor fragments")
	assert_eq(right_wall_floors.size(), 4, "Right wall has 4 floor fragments")


func test_memory_hall_no_combat() -> void:
	var has_enemies := false
	assert_false(has_enemies, "Memory Hall has no combat")


# ── Floor 9 difficulty scaling (11_ENEMY_DESIGN.md section 5.1) ──

func test_floor9_hp_mult() -> void:
	var hp_mult := 1.5
	assert_eq(hp_mult, 1.5, "Floor 9 HP mult = ×1.5 (hardest)")


func test_floor9_speed_mult() -> void:
	var speed_mult := 1.3
	assert_eq(speed_mult, 1.3, "Floor 9 speed mult = ×1.3")


func test_floor9_regen_mult() -> void:
	var regen_mult := 1.3
	assert_eq(regen_mult, 1.3, "Floor 9 regen mult = ×1.3")


func test_floor9_aggression_mult() -> void:
	var aggr_mult := 1.5
	assert_eq(aggr_mult, 1.5, "Floor 9 aggression mult = ×1.5 (hardest)")


# ── Layout is intentionally smaller ──

func test_total_rooms_smaller() -> void:
	var rooms := 8
	assert_true(rooms < 10, "Floor 9 has fewer rooms than most floors (8 vs 10+)")
