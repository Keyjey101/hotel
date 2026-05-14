extends "res://scripts/tests/test_base.gd"

## Bug #1: hit_stop() permanently freezes the game when called multiple times.
## _hit_stop_count increments on each call, but only ONE timer is active.
## After 5 fast calls, _hit_stop_count = 5, timer decrements to 4,
## Engine.time_scale stays 0.01 forever.

const ScreenEffectsScript = preload("res://scripts/effects/screen_effects.gd")


func test_hit_stop_count_matches_timer_fires():
	# Simulate 5 rapid hit_stop calls and verify Engine.time_scale resets to 1.0
	var effects = _create_screen_effects()
	Engine.time_scale = 1.0

	# Call hit_stop 5 times rapidly (simulating multi-hit combat)
	for i in range(5):
		effects.hit_stop(0.05)

	# After first call, count should be 1
	assert_eq(effects._hit_stop_count, 5, "Count should be 5 after 5 calls")

	# Wait long enough for all hit_stops to expire
	await _wait(0.3)

	assert_eq(Engine.time_scale, 1.0, "Engine.time_scale should return to 1.0 after all hit_stops expire")

	# Cleanup
	_safe_queue_free(effects)
	Engine.time_scale = 1.0


func test_hit_stop_single_call_restores_time_scale():
	var effects = _create_screen_effects()
	Engine.time_scale = 1.0

	effects.hit_stop(0.05)
	assert_eq(Engine.time_scale, 0.01, "time_scale should be 0.01 during hit_stop")

	await _wait(0.2)
	assert_eq(Engine.time_scale, 1.0, "time_scale should restore after single hit_stop")

	_safe_queue_free(effects)
	Engine.time_scale = 1.0


func test_screen_effects_script_loads():
	assert_ne(ScreenEffectsScript, null, "ScreenEffects script should load")


func _create_screen_effects():
	var effects = ScreenEffectsScript.new()
	Engine.get_main_loop().root.add_child(effects)
	_auto_free_nodes.append(effects)
	return effects


func _wait(seconds: float):
	var _st := Engine.get_main_loop() as SceneTree
	var timer: SceneTreeTimer = _st.create_timer(seconds)
	timer.one_shot = true
	await timer.timeout


func _safe_queue_free(node: Node):
	if is_instance_valid(node):
		node.queue_free()


func after_each():
	teardown_autoqfree()
	Engine.time_scale = 1.0
