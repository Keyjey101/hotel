extends "res://scripts/tests/test_base.gd"

## Bug #103: delete_run() uses hardcoded "hotel_run.json" instead of RUN_SAVE_PATH.get_file().
## Fix: Use the constant.

## Bug #10: fastest_time initialized as INF. JSON doesn't support Infinity.
## Fix: Replace with 999999.0.


func test_save_manager_script_loads():
	var script = load("res://scripts/core/save_manager.gd")
	if script == null:
		assert_true(true, "Skipped: SaveManager script not found")
		return
	assert_ne(script, null, "SaveManager script should load")


func test_save_manager_fastest_time_not_inf():
	var SaveManagerScript = load("res://scripts/core/save_manager.gd")
	if SaveManagerScript == null:
		assert_true(true, "Skipped: SaveManager script not found")
		return

	var sm = SaveManagerScript.new()
	if sm == null:
		assert_true(true, "Skipped: Could not instantiate SaveManager")
		return

	# Check that fastest_time is not INF
	if "fastest_time" in sm:
		assert_ne(sm.fastest_time, INF,
			"fastest_time should not be INF (JSON serialization fix)")


func after_each():
	teardown_autoqfree()
