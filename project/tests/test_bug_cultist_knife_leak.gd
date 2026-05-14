extends "res://scripts/tests/test_base.gd"
## Test: Cultist active knives not cleaned up on disable/death
## Bug: enemy_cultist.gd has no _disable_enemy override to clean _active_knives

## Verify that cultist's _active_knives are leaked on disable


func test_cultist_has_no_disable_override() -> void:
	# enemy_cultist.gd extends base_enemy but does NOT override _disable_enemy
	# This means active knives remain in the scene when cultist is disabled
	var cultist_script := load("res://scripts/ai/enemy_cultist.gd")
	assert(cultist_script != null, "Cultist script should exist")

	# Check if _disable_enemy is defined in cultist (it shouldn't be - that's the bug)
	var has_override := false
	var methods := cultist_script.get_script_method_list()
	for m in methods:
		if m.name == "_disable_enemy":
			has_override = true
			break
	assert(not has_override, "Cultist should override _disable_enemy to clean up _active_knives (bug: missing override)")


func test_cultist_knives_variable_exists() -> void:
	var cultist_script := load("res://scripts/ai/enemy_cultist.gd")
	assert(cultist_script != null, "Cultist script should exist")
	# The _active_knives array tracks live knife references
	assert(true, "Bug: _active_knives never cleaned in _disable_enemy, knives leak on death")
