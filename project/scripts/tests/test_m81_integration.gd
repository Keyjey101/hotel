extends "res://scripts/tests/test_base.gd"

## TestM81Integration — Integration tests for M8.1 Game Feel & VFX changes.
## String-based source code checks replaced by behavioral tests in
## test_m81_behavioral.gd.


func test_tdd_performance_pooling() -> void:
	# TDD 9.2: Object pooling for blood particles, debris, projectiles
	var pool_script := load("res://scripts/effects/object_pool.gd")
	assert_ne(pool_script, null, "ObjectPool script exists per TDD 9.2")
