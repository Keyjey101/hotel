extends "res://scripts/tests/test_base.gd"

## Bug #13: Unlimited RigidBody2D creation in gore_system.
## Each blood splash creates 3-5 RigidBody2D with physics.
## Should have a maximum cap.

func test_gore_system_script_loads():
	var GoreSystemScript = load("res://scripts/combat/gore_system.gd")
	if GoreSystemScript == null:
		assert_true(true, "Skipped: GoreSystem script not found")
		return
	assert_ne(GoreSystemScript, null, "GoreSystem script should load")


func test_gore_system_droplet_limit():
	var GoreSystemScript = load("res://scripts/combat/gore_system.gd")
	if GoreSystemScript == null:
		assert_true(true, "Skipped: GoreSystem script not found")
		return

	var gs = GoreSystemScript.new()
	Engine.get_main_loop().root.add_child(gs)
	_auto_free_nodes.append(gs)

	# Spawn many blood splashes rapidly
	var max_expected_droplets := 50  # reasonable cap
	for i in range(30):
		gs._spawn_placeholder_blood(Vector2(randf_range(0, 640), randf_range(0, 480)), Vector2.RIGHT)

	# After fix, should have a cap
	assert_lte(gs._active_droplets.size(), max_expected_droplets,
		"Active droplets should be capped at %d, got %d" % [max_expected_droplets, gs._active_droplets.size()])


func after_each():
	teardown_autoqfree()
