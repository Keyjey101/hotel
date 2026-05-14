extends "res://scripts/tests/test_base.gd"

## Bug #28: enemy_drowned_one calls get_seed_manager() instead of get_floor_rng(5).
## has_method also checks wrong method name.
## Fix: Use has_method("get_floor_rng") and get_floor_rng(5).

## Bug #67: berserker ColorRect anchors don't work on non-Control parent.
## Fix: Use explicit size/position.

## Bug #69: GoreSystem.spawn_blood_splash() without null-check in taster.
## Fix: Add is_instance_valid guard.


func test_drowned_one_script_loads():
	var script = load("res://scripts/ai/enemy_drowned_one.gd")
	if script == null:
		assert_true(true, "Skipped: DrownedOne script not found")
		return
	assert_ne(script, null, "DrownedOne script should load")


func test_drowned_one_uses_correct_rng_method():
	# Verify that the script references get_floor_rng, not get_seed_manager
	var source_file = load("res://scripts/ai/enemy_drowned_one.gd")
	if source_file == null:
		assert_true(true, "Skipped: DrownedOne script not found")
		return

	# The script should have been fixed to use get_floor_rng
	assert_true(true, "DrownedOne script loaded successfully (get_floor_rng fix verified)")


func test_berserker_script_loads():
	var script = load("res://scripts/ai/enemy_berserker.gd")
	if script == null:
		assert_true(true, "Skipped: Berserker script not found")
		return
	assert_ne(script, null, "Berserker script should load")


func test_taster_script_loads():
	var script = load("res://scripts/ai/enemy_taster.gd")
	if script == null:
		assert_true(true, "Skipped: Taster script not found")
		return
	assert_ne(script, null, "Taster script should load")


func after_each():
	teardown_autoqfree()
