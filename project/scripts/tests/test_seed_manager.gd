extends "res://scripts/tests/test_base.gd"

## TestSeedManager — Tests for deterministic randomization.

var sm: SeedManager


func before_each() -> void:
	sm = SeedManager.new(12345)


func test_same_seed_same_floor_rng() -> void:
	var rng1 := sm.get_floor_rng(3)
	var rng2 := sm.get_floor_rng(3)
	assert_eq(rng1.randi(), rng2.randi(), "Same seed + floor = same first random")


func test_different_floors_different_rng() -> void:
	var rng1 := sm.get_floor_rng(1)
	var rng2 := sm.get_floor_rng(2)
	assert_ne(rng1.randi(), rng2.randi(), "Different floors produce different RNG")


func test_same_seed_same_room_rng() -> void:
	var rng1 := sm.get_room_rng(3, 5)
	var rng2 := sm.get_room_rng(3, 5)
	assert_eq(rng1.randi(), rng2.randi(), "Same seed + floor + room = same random")


func test_different_rooms_different_rng() -> void:
	var rng1 := sm.get_room_rng(1, 0)
	var rng2 := sm.get_room_rng(1, 1)
	assert_ne(rng1.randi(), rng2.randi(), "Different rooms produce different RNG")


func test_enemy_config_deterministic() -> void:
	var c1 := sm.get_room_enemy_config(1, 0, 10)
	var c2 := sm.get_room_enemy_config(1, 0, 10)
	assert_eq(c1.count, c2.count, "Same enemy count for same seed/floor/room")
	assert_eq(c1.active_points, c2.active_points, "Same spawn points for same seed/floor/room")


func test_enemy_config_respects_spawn_max() -> void:
	var config := sm.get_room_enemy_config(1, 0, 5)
	assert_lte(config.count, 5, "Enemy count doesn't exceed spawn points")


func test_enemy_config_respects_spawn_min() -> void:
	var config := sm.get_room_enemy_config(1, 0, 10)
	assert_gte(config.count, 6, "Enemy count at least 60% of spawn points")


func test_loot_config_deterministic() -> void:
	var l1 := sm.get_room_loot_config(1, 0, 5)
	var l2 := sm.get_room_loot_config(1, 0, 5)
	assert_eq(l1.count, l2.count, "Same loot count for same params")


func test_gate_config_deterministic() -> void:
	var g1 := sm.get_gate_config(1, 3)
	var g2 := sm.get_gate_config(1, 3)
	assert_eq(g1.open, g2.open, "Same open branches")
	assert_eq(g1.closed, g2.closed, "Same closed branch")


func test_gate_config_has_2_open_1_closed() -> void:
	var config := sm.get_gate_config(1, 3)
	assert_eq(config["open"].size(), 2, "2 branches open")
	# closed is a single int (branch index), not an array
	assert_true(config["closed"] is int, "closed is a branch index")
	assert_true(config["open"].has(config["closed"]) == false, "closed branch not in open list")


func test_different_seeds_produce_different_results() -> void:
	var sm2 := SeedManager.new(99999)
	var rng1 := sm.get_floor_rng(1)
	var rng2 := sm2.get_floor_rng(1)
	assert_ne(rng1.randi(), rng2.randi(), "Different seeds = different results")


func assert_lte(value: float, limit: float, message: String = "") -> void:
	if value > limit:
		var msg := "Expected %s <= %s" % [str(value), str(limit)]
		if message != "": msg = message
		_test_runner.report_failure(msg)

func assert_gte(value: float, minimum: float, message: String = "") -> void:
	if value < minimum:
		var msg := "Expected %s >= %s" % [str(value), str(minimum)]
		if message != "": msg = message
		_test_runner.report_failure(msg)
