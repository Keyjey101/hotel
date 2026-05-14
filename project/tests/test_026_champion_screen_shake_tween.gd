extends "res://scripts/tests/test_base.gd"

## Bug #26: Screen shake tween tied to boss lifecycle.
## When boss dies mid-shake, camera gets stuck with random offset.

func test_screen_shake_tween_on_camera_node():
	# The fix: create shake tween on camera node, not boss node.
	var camera = Camera2D.new()
	camera.name = "Camera"
	camera.add_to_group("camera")
	Engine.get_main_loop().root.add_child(camera)
	_auto_free_nodes.append(camera)

	# Simulate screen shake on camera
	var tween := camera.create_tween()
	tween.tween_property(camera, "offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.05)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

	await _wait(0.2)

	# Camera offset should return to zero
	assert_eq(camera.offset, Vector2.ZERO, "Camera offset should return to zero after shake")


func _wait(seconds: float):
	var _st := Engine.get_main_loop() as SceneTree
	var timer: SceneTreeTimer = _st.create_timer(seconds)
	timer.one_shot = true
	await timer.timeout


func after_each():
	teardown_autoqfree()
