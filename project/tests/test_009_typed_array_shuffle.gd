extends "res://scripts/tests/test_base.gd"

## Bug #9: shuffle() on typed Array[Marker2D] crashes in Godot 4.
## The fix is to use untyped Array for shuffling.

func test_shuffle_on_untyped_array_does_not_crash():
	# Verify that shuffling an untyped duplicate of a typed array works
	var markers: Array[Marker2D] = []
	for i in range(5):
		var m = Marker2D.new()
		m.position = Vector2(i * 10.0, 0.0)
		markers.append(m)
		Engine.get_main_loop().root.add_child(m)
		_auto_free_nodes.append(m)

	# Duplicate as untyped Array (the fix)
	var spawn_points: Array = markers.duplicate()
	var rng = RandomNumberGenerator.new()
	rng.seed = 42

	# This should NOT crash
	rng.shuffle(spawn_points)

	assert_eq(spawn_points.size(), 5, "Shuffled array should have same size")
	# Elements should still be Marker2D
	for p in spawn_points:
		assert_true(p is Marker2D, "Elements should still be Marker2D")


func after_each():
	teardown_autoqfree()
