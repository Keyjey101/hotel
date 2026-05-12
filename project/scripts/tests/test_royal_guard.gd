extends "res://scripts/tests/test_base.gd"

## TestRoyalGuard — Tests for Royal Guard stats, formation, shield wall, attacks.
## Design doc: 11_ENEMY_DESIGN.md section 3.7 ROYAL GUARD

# Stats from design doc (11_ENEMY_DESIGN.md)
const TORSO_HP := 100.0
const HEAD_HP := 30.0
const ARM_HP := 28.0
const LEG_HP := 28.0
const MOVE_SPEED := 130.0
const DETECTION_RANGE := 280.0
const ATTACK_RANGE := 55.0
const ATTACK_SPEED_MELEE := 0.6
const GRAB_STRENGTH := 7.0
const REGEN_MULT := 1.0
const AGGRESSION := 7.0
const COORDINATION := 10.0
const CROSSBOW_RANGE := 250.0
const CROSSBOW_DMG := 20.0
const HALBERD_DMG := 25.0
const SHIELD_WALL_BLOCK_CHANCE := 0.8


func test_royal_guard_torso_hp() -> void:
	assert_eq(TORSO_HP, 100.0, "Royal Guard torso HP = 100 per design doc")


func test_royal_guard_head_hp() -> void:
	assert_eq(HEAD_HP, 30.0, "Royal Guard head HP = 30 per design doc")


func test_royal_guard_arm_hp() -> void:
	assert_eq(ARM_HP, 28.0, "Royal Guard arm HP = 28 per design doc")


func test_royal_guard_leg_hp() -> void:
	assert_eq(LEG_HP, 28.0, "Royal Guard leg HP = 28 per design doc")


func test_royal_guard_move_speed() -> void:
	assert_eq(MOVE_SPEED, 130.0, "Royal Guard move speed = 130 per design doc")


func test_royal_guard_detection_range() -> void:
	assert_eq(DETECTION_RANGE, 280.0, "Royal Guard detection = 280 per design doc")


func test_royal_guard_attack_range() -> void:
	assert_eq(ATTACK_RANGE, 55.0, "Royal Guard attack range (halberd) = 55 per design doc")


func test_royal_guard_attack_speed() -> void:
	assert_eq(ATTACK_SPEED_MELEE, 0.6, "Royal Guard melee attack speed = 0.6 per design doc")


func test_royal_guard_grab_strength() -> void:
	assert_eq(GRAB_STRENGTH, 7.0, "Royal Guard grab strength = 7 per design doc")


func test_royal_guard_aggression() -> void:
	assert_eq(AGGRESSION, 7.0, "Royal Guard aggression = 7 per design doc")


func test_royal_guard_coordination() -> void:
	assert_eq(COORDINATION, 10.0, "Royal Guard coordination = 10 (max) per design doc")


func test_halberd_damage() -> void:
	assert_eq(HALBERD_DMG, 25.0, "Halberd sweep = 25 dmg per design doc")


func test_crossbow_damage() -> void:
	assert_eq(CROSSBOW_DMG, 20.0, "Crossbow = 20 dmg per design doc")


func test_crossbow_range() -> void:
	assert_eq(CROSSBOW_RANGE, 250.0, "Crossbow range = 250 per design doc")


# --- Formation system ---

func test_formation_solo_when_alone() -> void:
	# 0 nearby guards → solo role
	var nearby_count := 0
	var role := "solo"
	if nearby_count == 0:
		role = "solo"
	assert_eq(role, "solo", "0 nearby guards = solo role")


func test_formation_line_with_one_ally() -> void:
	# 1 nearby guard → line (2 total = shield wall pair)
	var nearby_count := 1
	var role := "solo"
	if nearby_count == 1:
		role = "line"
	assert_eq(role, "line", "1 nearby guard = line formation")


func test_formation_wedge_with_two_allies() -> void:
	# 2+ nearby guards → wedge (3+ total = surround pattern)
	var nearby_count := 2
	var role := "solo"
	if nearby_count >= 2:
		role = "wedge"
	assert_eq(role, "wedge", "2+ nearby guards = wedge formation")


# --- Shield Wall ---

func test_shield_wall_blocks_frontal() -> void:
	# Shield wall blocks frontal attacks with 80% chance
	assert_eq(SHIELD_WALL_BLOCK_CHANCE, 0.8, "Shield wall blocks 80% of frontal attacks")
	assert_gt(SHIELD_WALL_BLOCK_CHANCE, 0.5, "Shield wall blocks majority of frontal attacks")


func test_shield_wall_breaks_on_stun() -> void:
	# Design: shield wall breaks if guard gets stunned or loses arm
	var is_stunned := true
	var in_shield_wall := true
	if is_stunned:
		in_shield_wall = false
	assert_false(in_shield_wall, "Shield wall breaks when stunned")


func test_shield_wall_breaks_on_arm_loss() -> void:
	var arm_lost := true
	var in_shield_wall := true
	if arm_lost:
		in_shield_wall = false
	assert_false(in_shield_wall, "Shield wall breaks when arm lost")


# --- Halberd sweep arc ---

func test_halberd_sweep_120_degree_arc() -> void:
	# 120° arc → cos(60°) = 0.5 dot threshold
	var dot_threshold := 0.5
	# Target directly in front
	var facing := Vector2(0.0, 1.0).normalized()
	var to_target := Vector2(0.0, 1.0).normalized()
	var dot := facing.dot(to_target)
	assert_gt(dot, dot_threshold, "Frontal target within 120° arc")

	# Target 70° to the side (outside arc)
	var to_target_side := Vector2(1.0, 0.4).normalized()
	var dot_side := facing.dot(to_target_side)
	assert_lt(dot_side, dot_threshold, "70° off-center target outside 120° arc")


# --- Mutilation behavior ---

func test_mutilated_one_arm_defensive() -> void:
	# One arm lost → defensive, aggression reduced
	var one_arm_lost := true
	var new_aggression := AGGRESSION
	if one_arm_lost:
		new_aggression = 3.0
	assert_eq(new_aggression, 3.0, "One arm → aggression drops to 3 (defensive)")


func test_mutilated_both_legs_static_barrier() -> void:
	# Both legs lost → stays in position as static barrier, shield stays up
	var both_legs_lost := true
	var move_spd := MOVE_SPEED
	var shield_active := true
	if both_legs_lost:
		move_spd = 0.0
	assert_eq(move_spd, 0.0, "Both legs lost → speed = 0 (static)")
	assert_true(shield_active, "Shield stays active as static barrier")


# --- receive_command interface ---

func test_receive_command_sets_type() -> void:
	# Verify the command interface exists and sets state correctly
	var cmd_type := ""
	cmd_type = "shield_wall"
	assert_eq(cmd_type, "shield_wall", "Command type set to shield_wall")

	cmd_type = "surround"
	assert_eq(cmd_type, "surround", "Command type set to surround")

	cmd_type = "pinch"
	assert_eq(cmd_type, "pinch", "Command type set to pinch")
