extends "res://scripts/tests/test_base.gd"

## Bug #16: _exit_tree doesn't disconnect hit_stop timer or viewport size_changed.

const ScreenEffectsScript = preload("res://scripts/effects/screen_effects.gd")


func test_screen_effects_script_loads():
	assert_ne(ScreenEffectsScript, null, "ScreenEffects script should load")


func test_exit_tree_disconnects_viewport_signal():
	var effects = ScreenEffectsScript.new()
	Engine.get_main_loop().root.add_child(effects)
	_auto_free_nodes.append(effects)

	# Check that viewport size_changed is connected
	var vp = effects.get_viewport()
	if vp == null:
		assert_true(true, "Skipped: viewport not available")
		return

	var connected_before := false
	for conn in vp.size_changed.get_connections():
		if conn.callable == effects._resize_overlays:
			connected_before = true
	assert_true(connected_before, "size_changed should be connected while in tree")

	# Remove from tree
	Engine.get_main_loop().root.remove_child(effects)

	# After fix: signal should be disconnected
	var connected_after := false
	for conn in vp.size_changed.get_connections():
		if conn.callable == effects._resize_overlays:
			connected_after = true
	assert_false(connected_after, "size_changed should be disconnected after _exit_tree")

	if is_instance_valid(effects):
		effects.queue_free()


func test_exit_tree_restores_time_scale():
	var effects = ScreenEffectsScript.new()
	Engine.get_main_loop().root.add_child(effects)
	_auto_free_nodes.append(effects)

	# Trigger a hit_stop
	effects.hit_stop(5.0)  # Long duration
	assert_lt(Engine.time_scale, 1.0, "time_scale should be reduced during hit_stop")

	# Remove from tree while hit_stop active
	Engine.get_main_loop().root.remove_child(effects)

	# After fix: time_scale should be restored to 1.0
	assert_eq(Engine.time_scale, 1.0, "time_scale should be 1.0 after _exit_tree")

	if is_instance_valid(effects):
		effects.queue_free()
	Engine.time_scale = 1.0


func after_each():
	teardown_autoqfree()
	Engine.time_scale = 1.0
