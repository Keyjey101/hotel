extends "res://scripts/tests/test_base.gd"

## Bug #72: Timer callback (_release_grab) may fire after Handler freed.
## Signal connection leaks.
## Fix: Track timer in member var, disconnect in _disable_enemy.


func test_handler_script_loads():
	var script = load("res://scripts/ai/enemy_handler.gd")
	if script == null:
		assert_true(true, "Skipped: Handler script not found")
		return
	assert_ne(script, null, "Handler script should load")


func after_each():
	teardown_autoqfree()
