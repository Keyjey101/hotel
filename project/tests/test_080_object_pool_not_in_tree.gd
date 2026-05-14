extends "res://scripts/tests/test_base.gd"

## Bug #80: ObjectPool doesn't fill if not added to tree (_ready not called).

const ObjectPoolScript = preload("res://scripts/effects/object_pool.gd")


func test_object_pool_script_loads():
	assert_ne(ObjectPoolScript, null, "ObjectPool script should load")


func test_pool_returns_null_if_not_in_tree():
	var melee_scene = load("res://scenes/weapons/melee_hit.tscn")
	if melee_scene == null:
		assert_true(true, "Skipped: melee_hit scene not found")
		return

	var pool = ObjectPoolScript.new(melee_scene, 5, 10)
	# NOT added to tree -- _ready won't be called, _expand won't work

	var instance = pool.get_instance()
	assert_eq(instance, null, "Pool not in tree should return null from get_instance")


func test_pool_works_when_in_tree():
	var melee_scene = load("res://scenes/weapons/melee_hit.tscn")
	if melee_scene == null:
		assert_true(true, "Skipped: melee_hit scene not found")
		return

	var pool = ObjectPoolScript.new(melee_scene, 5, 10)
	Engine.get_main_loop().root.add_child(pool)
	_auto_free_nodes.append(pool)

	await _wait_for_frame()

	var instance = pool.get_instance()
	assert_ne(instance, null, "Pool in tree should return instances")

	if is_instance_valid(instance):
		pool.return_instance(instance)


func _wait_for_frame():
	await Engine.get_main_loop().process_frame


func after_each():
	teardown_autoqfree()
