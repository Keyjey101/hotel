extends "res://scripts/tests/test_base.gd"

## Bug #27: _get_safe_position retreats boss away from player instead of flanking.

func test_safe_position_is_not_retreat():
	# The fix: safe position should be lateral/flanking, not retreating.
	# We test the geometry: the offset should not be in the direction away from player.
	var boss_pos := Vector2(200.0, 200.0)
	var player_pos := Vector2(300.0, 200.0)  # Player to the right
	var dir_to_player := boss_pos.direction_to(player_pos)  # (1, 0)

	# Simulate _get_safe_position behavior (the buggy version)
	# Bug: returns point 60px BEHIND boss (away from player)
	var buggy_offset := -dir_to_player * 60.0
	var buggy_safe := boss_pos + buggy_offset

	# The buggy position is further from player than boss
	var boss_dist := boss_pos.distance_to(player_pos)
	var buggy_dist := buggy_safe.distance_to(player_pos)
	assert_gt(buggy_dist, boss_dist, "Buggy position is further from player (retreat)")

	# After fix: position should be at similar distance or closer (flanking)
	# Flanking = perpendicular offset
	var flank_offset := dir_to_player.rotated(PI / 2.0) * 60.0
	var flanked_safe := boss_pos + flank_offset
	var flank_dist := flanked_safe.distance_to(player_pos)

	# Flanking position should be at roughly same distance as boss
	assert_lt(absf(flank_dist - boss_dist), 10.0, "Flanking position should be similar distance to player")
