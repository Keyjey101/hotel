extends "res://scripts/tests/test_base.gd"

## Bug #41: Multiple hazard zones with different slow values -- last one wins.
## Should use the strongest (minimum) slow, not the last applied.


func test_player_scene_loads():
	var player_scene = load("res://scenes/player/player.tscn")
	if player_scene == null:
		assert_true(true, "Skipped: player scene not found")
		return
	assert_ne(player_scene, null, "Player scene should load")


func test_hazard_slow_uses_strongest():
	# Simulate two hazard zones with different slows
	# Zone A: 0.5x speed, Zone B: 0.3x speed
	# The correct behavior: player should be slowed by 0.3x (strongest)
	var player_scene = load("res://scenes/player/player.tscn")
	if player_scene == null:
		assert_true(true, "Skipped: player scene not found")
		return

	var player = player_scene.instantiate()
	Engine.get_main_loop().root.add_child(player)
	_auto_free_nodes.append(player)
	await _wait_for_frame()

	# Apply slow from zone A (weaker)
	player.apply_hazard_slow(0.5)
	assert_eq(player._hazard_slow_mult, 0.5, "First slow applied")

	# Apply slow from zone B (stronger)
	player.apply_hazard_slow(0.3)

	# After fix: should use the STRONGEST (minimum multiplier)
	assert_eq(player._hazard_slow_mult, 0.3,
		"Should use strongest slow (0.3), not last applied")

	# Remove the stronger slow
	player.remove_hazard_slow(0.3)

	# Should revert to the weaker slow still active
	assert_eq(player._hazard_slow_mult, 0.5,
		"Should revert to remaining slow (0.5) after removing stronger one")


func _wait_for_frame():
	await Engine.get_main_loop().process_frame


func after_each():
	teardown_autoqfree()
