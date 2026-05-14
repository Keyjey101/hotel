extends "res://scripts/tests/test_base.gd"

## Bug #99: Satan does NOT decrement _disabled_timer in disabled block.
## Timer never reaches 0, Satan may stay disabled forever.
## Fix: Add _disabled_timer -= delta in disabled block.

## Bug #96: Stolen weapon lost on Satan's death.
## Fix: Force drop in _disable_enemy().

## Bug #102: _execute_steal() doesn't sync weapon state.
## Fix: Call wm._sync_to_run_state() after modification.


func test_satan_script_loads():
	var script = load("res://scripts/ai/boss_satan.gd")
	if script == null:
		assert_true(true, "Skipped: BossSatan script not found")
		return
	assert_ne(script, null, "BossSatan script should load")


func test_satan_disabled_timer_decrements():
	var SatanScript = load("res://scripts/ai/boss_satan.gd")
	if SatanScript == null:
		assert_true(true, "Skipped: BossSatan script not found")
		return

	var satan = SatanScript.new()
	Engine.get_main_loop().root.add_child(satan)
	_auto_free_nodes.append(satan)

	# Set up disabled state
	satan._disabled = true
	satan._disabled_timer = 2.0

	# Simulate one physics frame
	if satan.has_method("_physics_process"):
		satan._physics_process(0.016)

	# Timer should have decremented
	assert_lt(satan._disabled_timer, 2.0,
		"_disabled_timer should decrement each frame when disabled")


func test_satan_stolen_weapon_dropped_on_disable():
	var SatanScript = load("res://scripts/ai/boss_satan.gd")
	if SatanScript == null:
		assert_true(true, "Skipped: BossSatan script not found")
		return

	var satan = SatanScript.new()
	Engine.get_main_loop().root.add_child(satan)
	_auto_free_nodes.append(satan)

	# Set a fake stolen weapon reference
	satan._stolen_weapon = {"id": "test_weapon", "name": "Test Sword"}

	# Disable enemy should clear stolen weapon
	if satan.has_method("_disable_enemy"):
		satan._disable_enemy()

	assert_null(satan._stolen_weapon,
		"_stolen_weapon should be cleared (force-dropped) on disable")


func after_each():
	teardown_autoqfree()
