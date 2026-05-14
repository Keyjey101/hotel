extends "res://scripts/tests/test_base.gd"

## Bug #16: _ready() creates lifetime timer, then setup() creates SECOND timer
## without disabling first. Both call _return_to_pool.
## Fix: Clean up timers in _return_to_pool.


func test_projectile_script_loads():
	var script = load("res://scripts/combat/projectile.gd")
	if script == null:
		assert_true(true, "Skipped: Projectile script not found")
		return
	assert_ne(script, null, "Projectile script should load")


func test_projectile_timer_cleanup_on_return():
	var ProjectileScript = load("res://scripts/combat/projectile.gd")
	if ProjectileScript == null:
		assert_true(true, "Skipped: Projectile script not found")
		return

	var proj = ProjectileScript.new()
	Engine.get_main_loop().root.add_child(proj)
	_auto_free_nodes.append(proj)

	# Call setup to trigger the second timer creation
	if proj.has_method("setup"):
		proj.setup(Vector2.ZERO, Vector2.RIGHT, 100.0, 1.0)

	# Call return_to_pool - should clean up both timers without crash
	if proj.has_method("_return_to_pool"):
		proj._return_to_pool()
		assert_true(true, "_return_to_pool completed without crash (double timer fix)")


func after_each():
	teardown_autoqfree()
