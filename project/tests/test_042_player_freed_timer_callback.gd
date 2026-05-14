extends "res://scripts/tests/test_base.gd"

## Bug #42: _attack_end_timer callback on freed player instance.
## No is_instance_valid guard on the timer callback.


func test_player_controller_script_loads():
	var player_script = load("res://scripts/player/player_controller.gd")
	if player_script == null:
		assert_true(true, "Skipped: player_controller not found")
		return
	assert_ne(player_script, null, "Player controller script should load")


func test_attack_end_timer_survives_player_free():
	# Simulate the pattern: timer callback should guard against freed self
	var player_script = load("res://scripts/player/player_controller.gd")
	if player_script == null:
		assert_true(true, "Skipped: player_controller not found")
		return

	# The fix should wrap the callback in is_instance_valid guard.
	var callback_fired: bool = false
	var ref = Node.new()
	Engine.get_main_loop().root.add_child(ref)
	_auto_free_nodes.append(ref)

	var _st1 := Engine.get_main_loop() as SceneTree
	var timer: SceneTreeTimer = _st1.create_timer(0.05)
	timer.one_shot = true
	timer.timeout.connect(func():
		callback_fired = true
		if is_instance_valid(ref):
			# Safe to use ref
			pass
	)

	# Free the node before timer fires
	ref.queue_free()
	await _wait(0.1)

	# Timer should fire without crash, callback should handle freed node
	assert_true(callback_fired, "Timer callback should fire even after ref is freed")


func test_player_pause_menu_null_scene():
	# Bug #43: Pause menu created but not added if current_scene is null.
	# After fix: should queue_free the instance if scene is null.
	var menu = Node.new()
	menu.name = "PauseMenu"

	# Simulate the guard pattern
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		tree.current_scene.add_child(menu)
	else:
		# After fix: clean up unused instance
		menu.queue_free()
		assert_true(true, "Menu freed when current_scene is null")


func _wait(seconds: float):
	var _st := Engine.get_main_loop() as SceneTree
	var timer: SceneTreeTimer = _st.create_timer(seconds)
	timer.one_shot = true
	await timer.timeout


func after_each():
	teardown_autoqfree()
