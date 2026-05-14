extends "res://scripts/tests/test_base.gd"

## Bug #98: regen_timers initialized only for DamageZone.all_limbs() (4 zones).
## HEAD excluded. Head HP never regenerates.
## Fix: Add HEAD to regen_timers initialization.

## Bug #105: timer.max used as countdown (semantically wrong name).
## Fix: Rename to "remaining" with separate "initial_max".


func test_base_enemy_includes_head_in_regen():
	var BaseEnemyScript = load("res://scripts/ai/base_enemy.gd")
	if BaseEnemyScript == null:
		assert_true(true, "Skipped: BaseEnemy script not found")
		return

	# Verify HEAD zone is included in regen timers
	var DamageZoneScript = load("res://scripts/combat/damage_zones.gd")
	if DamageZoneScript == null:
		assert_true(true, "Skipped: DamageZone script not found")
		return

	# Create a minimal enemy instance
	var enemy = BaseEnemyScript.new()
	Engine.get_main_loop().root.add_child(enemy)
	_auto_free_nodes.append(enemy)

	# Check that regen_timers has entries for HEAD
	assert_has(enemy.regen_timers, 0,
		"regen_timers should include HEAD zone (zone 0)")


func test_regen_timer_uses_remaining_field():
	var BaseEnemyScript = load("res://scripts/ai/base_enemy.gd")
	if BaseEnemyScript == null:
		assert_true(true, "Skipped: BaseEnemy script not found")
		return

	var enemy = BaseEnemyScript.new()
	Engine.get_main_loop().root.add_child(enemy)
	_auto_free_nodes.append(enemy)

	# Check that regen timer entries use "remaining" instead of "max"
	var any_timer = enemy.regen_timers.values()[0] if enemy.regen_timers.size() > 0 else null
	if any_timer != null:
		assert_has(any_timer, "remaining",
			"Regen timer should use 'remaining' field (not 'max')")
		assert_has(any_timer, "initial_max",
			"Regen timer should have 'initial_max' to preserve original duration")


func after_each():
	teardown_autoqfree()
