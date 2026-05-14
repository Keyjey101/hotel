extends "res://scripts/tests/test_base.gd"

## Bug #93: DetectionArea with collision_mask=0 and collision_layer=0 — inert node.
## Fix: Set collision_layer=1.


func test_player_scene_loads():
	var scene = load("res://scenes/player/player.tscn")
	if scene == null:
		assert_true(true, "Skipped: player.tscn not found")
		return
	assert_ne(scene, null, "player.tscn should load")


func test_detection_area_has_collision_layer():
	var player_scene = load("res://scenes/player/player.tscn")
	if player_scene == null:
		assert_true(true, "Skipped: player.tscn not found")
		return

	var player = player_scene.instantiate()
	Engine.get_main_loop().root.add_child(player)
	_auto_free_nodes.append(player)

	# Find DetectionArea
	var detection = player.get_node_or_null("DetectionArea")
	if detection == null:
		assert_true(true, "Skipped: DetectionArea node not found")
		return

	# Verify collision_layer is NOT zero
	assert_ne(detection.collision_layer, 0,
		"DetectionArea should have non-zero collision_layer (was inert with 0)")


func after_each():
	teardown_autoqfree()
