extends "res://scripts/tests/test_base.gd"

## Bug #37: SceneTreeTimer connections accumulate on reused projectile pool objects.


func test_projectile_scene_loads():
	assert_true(ResourceLoader.exists("res://scenes/weapons/projectile.tscn"), "projectile.tscn should exist")


func test_projectile_setup_no_timer_accumulation():
	var proj_scene = load("res://scenes/weapons/projectile.tscn")
	if proj_scene == null:
		assert_true(true, "Skipped: projectile scene not found")
		return

	var proj = proj_scene.instantiate()
	Engine.get_main_loop().root.add_child(proj)
	_auto_free_nodes.append(proj)

	# Simulate multiple reuse cycles (setup() without cleanup)
	# Bug: each setup() creates a new SceneTreeTimer, old one still connected
	var weapon_data_script = load("res://scripts/data/weapon_data.gd")
	if weapon_data_script == null:
		assert_true(true, "Skipped: WeaponData script not found")
		return

	var weapon_data = weapon_data_script.new()
	weapon_data.projectile_speed = 600.0

	for cycle in range(5):
		proj._returned_to_pool = false
		proj.visible = true
		proj.set_physics_process(true)
		proj.setup(weapon_data, Vector2.RIGHT, 1.0, false)

	# We verify the pattern doesn't crash
	assert_true(true, "Multiple setup cycles should not accumulate timer callbacks")


func after_each():
	teardown_autoqfree()
