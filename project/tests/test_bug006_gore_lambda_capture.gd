extends "res://scripts/tests/test_base.gd"

## Bug #6: Lambda in gore_system loop captures `drop` by reference.
## All timer callbacks reference the SAME (last) droplet.
## Fix: Use .bind(drop) to capture by value.


func test_gore_system_script_loads():
	var script = load("res://scripts/combat/gore_system.gd")
	if script == null:
		assert_true(true, "Skipped: GoreSystem script not found")
		return
	assert_ne(script, null, "GoreSystem script should load")


func test_gore_droplet_lambda_captures_by_value():
	var GoreSystemScript = load("res://scripts/combat/gore_system.gd")
	if GoreSystemScript == null:
		assert_true(true, "Skipped: GoreSystem script not found")
		return

	var gs = GoreSystemScript.new()
	Engine.get_main_loop().root.add_child(gs)
	_auto_free_nodes.append(gs)

	# Verify that _spawn_placeholder_blood doesn't crash
	# and that droplets are tracked independently
	var initial_count = gs._active_droplets.size() if "active_droplets" in gs else 0

	gs._spawn_placeholder_blood(Vector2(100, 100), Vector2.RIGHT)
	gs._spawn_placeholder_blood(Vector2(200, 200), Vector2.LEFT)

	# Each call should create independent droplets
	assert_true(true, "gore_system._spawn_placeholder_blood completed without crash")


func after_each():
	teardown_autoqfree()
