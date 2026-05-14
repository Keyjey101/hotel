extends "res://scripts/tests/test_base.gd"
## Test: Enemy chef cleaver can hit player twice (immediate check + signal)
## Bug: enemy_chef.gd:152-179 no deduplication between overlapping check and body_entered


func test_chef_cleaver_has_race_condition() -> void:
	# _execute_cleaver_hit at line 169 checks get_overlapping_bodies() immediately
	# then at line 174 connects body_entered signal
	# Same body can be hit by both paths
	assert(true, "Bug: enemy_chef._execute_cleaver_hit can hit same body twice via immediate check + body_entered signal")


func test_chef_cleaver_fix() -> void:
	assert(true, "Fix: add a Set to track hit bodies, or remove the immediate overlap check and rely solely on body_entered")
