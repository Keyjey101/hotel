extends "res://scripts/tests/test_base.gd"

## TestRunState — Tests for RunState: stats, artifacts, HP management.

var state: RunState


func before_each() -> void:
	state = RunState.new()


func test_initial_state() -> void:
	assert_eq(state.current_floor, 1, "Starts at floor 1")
	assert_eq(state.player_hp, 100.0, "Starts with 100 HP")
	assert_eq(state.player_max_hp, 100.0, "Max HP is 100")
	assert_eq(state.player_speed, 200.0, "Speed is 200")
	assert_eq(state.active_slot, 0, "Active slot is 0")
	assert_eq(state.weapon_slots.size(), 2, "2 weapon slots")
	assert_eq(state.enemies_mutilated, 0, "No kills yet")
	assert_eq(state.limbs_severed, 0, "No severs yet")


func test_stat_upgrade_applies() -> void:
	state.apply_stat_upgrade("max_hp", 25.0)
	assert_eq(state.player_max_hp, 125.0, "Max HP increases by 25")


func test_stat_upgrade_stacks() -> void:
	state.apply_stat_upgrade("max_hp", 25.0)
	state.apply_stat_upgrade("max_hp", 25.0)
	assert_eq(state.player_max_hp, 150.0, "Two stacks = +50 HP")


func test_stat_upgrade_diminishing_third_stack() -> void:
	state.apply_stat_upgrade("max_hp", 25.0)
	state.apply_stat_upgrade("max_hp", 25.0)
	state.apply_stat_upgrade("max_hp", 25.0)
	# 3rd stack at 50% = 12.5
	assert_approx(state.player_max_hp, 162.5, 0.1, "3rd stack has diminishing returns")


func test_speed_upgrade_percentage() -> void:
	state.apply_stat_upgrade("speed", 0.12)
	assert_approx(state.player_speed, 224.0, 0.1, "Speed increases by 12%")


func test_multiple_different_stats() -> void:
	state.apply_stat_upgrade("max_hp", 25.0)
	state.apply_stat_upgrade("speed", 0.12)
	assert_eq(state.player_max_hp, 125.0, "HP unaffected by speed upgrade")
	assert_approx(state.player_speed, 224.0, 0.1, "Speed unaffected by HP upgrade")


func test_artifact_add() -> void:
	var artifact := Resource.new()
	artifact.set_meta("name", "Demon Eye")
	state.add_artifact(artifact)
	assert_eq(state.cult_artifacts.size(), 1, "Artifact added")


func test_has_artifact() -> void:
	assert_false(state.has_artifact("Demon Eye"), "No artifact initially")
	var artifact := Resource.new()
	artifact.name = "Demon Eye"
	state.add_artifact(artifact)
	assert_true(state.has_artifact("Demon Eye"), "Artifact found after adding")


func test_has_no_artifact() -> void:
	assert_false(state.has_artifact("Nonexistent"), "Returns false for unknown artifact")


func test_hp_clamp_minimum() -> void:
	state.player_hp = -50.0
	# RunState doesn't clamp HP directly, but let's verify max_hp can't go below 1
	state.apply_stat_upgrade("max_hp", -200.0)
	assert_gte(state.player_max_hp, 1.0, "Max HP never goes below 1")


func test_weapon_slots_initially_empty() -> void:
	assert_eq(state.weapon_slots[0], null, "Slot 0 empty")
	assert_eq(state.weapon_slots[1], null, "Slot 1 empty")


func test_run_time_positive() -> void:
	var t := state.get_run_time()
	assert_gt(t, 0.0, "Run time is positive")
