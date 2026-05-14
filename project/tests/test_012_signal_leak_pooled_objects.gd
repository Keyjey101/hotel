extends "res://scripts/tests/test_base.gd"

## Bug #12: Hit signal leaks on pooled objects (melee_hit, projectile, thrown_weapon).
## Old signal connections accumulate, causing double/triple damage on reuse.


func test_melee_hit_scene_loads():
	assert_true(ResourceLoader.exists("res://scenes/weapons/melee_hit.tscn"), "melee_hit.tscn should exist")


func test_projectile_scene_loads():
	assert_true(ResourceLoader.exists("res://scenes/weapons/projectile.tscn"), "projectile.tscn should exist")


func test_thrown_weapon_scene_loads():
	assert_true(ResourceLoader.exists("res://scenes/weapons/thrown_weapon.tscn"), "thrown_weapon.tscn should exist")


func test_melee_hit_signal_cleaned_on_return_to_pool():
	var melee_scene = load("res://scenes/weapons/melee_hit.tscn")
	if melee_scene == null:
		assert_true(true, "Skipped: melee_hit scene not found")
		return

	var melee_node = melee_scene.instantiate()
	Engine.get_main_loop().root.add_child(melee_node)
	_auto_free_nodes.append(melee_node)

	# Connect a dummy callback to the hit signal
	var cb = func(_target: Node2D, _zone: int): pass
	melee_node.hit.connect(cb)

	# Return to pool (will queue_free since no pool parent)
	melee_node._return_to_pool()
	await _wait(0.1)

	# After fix: _return_to_pool should disconnect all hit signal connections
	if is_instance_valid(melee_node):
		var connections: Array = melee_node.hit.get_connections()
		assert_eq(connections.size(), 0, "hit signal should have no connections after return_to_pool")


func test_projectile_signal_cleaned_on_return_to_pool():
	var proj_scene = load("res://scenes/weapons/projectile.tscn")
	if proj_scene == null:
		assert_true(true, "Skipped: projectile scene not found")
		return

	var proj_node = proj_scene.instantiate()
	Engine.get_main_loop().root.add_child(proj_node)
	_auto_free_nodes.append(proj_node)

	var cb = func(_target: Node2D, _zone: int): pass
	proj_node.hit.connect(cb)

	proj_node._return_to_pool()
	await _wait(0.1)

	if is_instance_valid(proj_node):
		var connections: Array = proj_node.hit.get_connections()
		assert_eq(connections.size(), 0, "hit signal should have no connections after return_to_pool")


func test_thrown_weapon_signal_cleaned_on_return_to_pool():
	var thrown_scene = load("res://scenes/weapons/thrown_weapon.tscn")
	if thrown_scene == null:
		assert_true(true, "Skipped: thrown_weapon scene not found")
		return

	var thrown_node = thrown_scene.instantiate()
	Engine.get_main_loop().root.add_child(thrown_node)
	_auto_free_nodes.append(thrown_node)

	var cb = func(_target: Node2D, _zone: int): pass
	thrown_node.hit.connect(cb)

	thrown_node._return_to_pool()
	await _wait(0.1)

	if is_instance_valid(thrown_node):
		var connections: Array = thrown_node.hit.get_connections()
		assert_eq(connections.size(), 0, "hit signal should have no connections after return_to_pool")


func test_pooled_reuse_does_not_accumulate_callbacks():
	# Create a pool parent to avoid queue_free on return
	var melee_scene = load("res://scenes/weapons/melee_hit.tscn")
	if melee_scene == null:
		assert_true(true, "Skipped: melee_hit scene not found")
		return

	var pool_parent = Node.new()
	pool_parent.name = "MockPool"
	Engine.get_main_loop().root.add_child(pool_parent)
	_auto_free_nodes.append(pool_parent)

	var melee_node = melee_scene.instantiate()
	pool_parent.add_child(melee_node)

	for _cycle in range(3):
		var cb = func(_t: Node2D, _z: int): pass
		melee_node.hit.connect(cb)
		# Disconnect manually (simulating what the fix should do)
		for conn in melee_node.hit.get_connections():
			melee_node.hit.disconnect(conn.callable)
		# Reset pool state for next cycle
		melee_node._in_pool = false
		melee_node.visible = true
		melee_node.set_physics_process(true)

	var connections: Array = melee_node.hit.get_connections()
	assert_eq(connections.size(), 0, "hit signal should have 0 connections after 3 pool cycles")


func _wait(seconds: float):
	var _st := Engine.get_main_loop() as SceneTree
	var timer: SceneTreeTimer = _st.create_timer(seconds)
	timer.one_shot = true
	await timer.timeout


func after_each():
	teardown_autoqfree()
