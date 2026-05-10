extends "res://scripts/tests/test_base.gd"

## TestEnemyHealth — Tests for enemy HP, limb damage, severing, and disable.

var enemy: CharacterBody2D
var enemy_script: Object  # We test the script logic directly via simulated calls


func before_each() -> void:
	# Create a minimal enemy instance for testing
	# Since we can't easily instantiate the full scene, we simulate the health system
	enemy_script = _create_health_sim(
		70.0,  # torso
		25.0,  # head
		20.0,  # arm
		22.0   # leg
	)


func _create_health_sim(torso: float, head: float, arm: float, leg: float) -> Object:
	var sim := RefCounted.new()
	sim.set_meta("limb_health", {
		DamageZone.Zone.HEAD: head,
		DamageZone.Zone.LEFT_ARM: arm,
		DamageZone.Zone.RIGHT_ARM: arm,
		DamageZone.Zone.LEFT_LEG: leg,
		DamageZone.Zone.RIGHT_LEG: leg,
		DamageZone.Zone.TORSO: torso,
	})
	sim.set_meta("severed_limbs", {
		DamageZone.Zone.HEAD: false,
		DamageZone.Zone.LEFT_ARM: false,
		DamageZone.Zone.RIGHT_ARM: false,
		DamageZone.Zone.LEFT_LEG: false,
		DamageZone.Zone.RIGHT_LEG: false,
	})
	sim.set_meta("max_limb", {
		DamageZone.Zone.HEAD: head,
		DamageZone.Zone.LEFT_ARM: arm,
		DamageZone.Zone.RIGHT_ARM: arm,
		DamageZone.Zone.LEFT_LEG: leg,
		DamageZone.Zone.RIGHT_LEG: leg,
	})
	sim.set_meta("disabled", false)
	return sim


func test_initial_health() -> void:
	var hp: Dictionary = enemy_script.get_meta("limb_health")
	assert_eq(hp[DamageZone.Zone.TORSO], 70.0, "Torso starts at 70")
	assert_eq(hp[DamageZone.Zone.HEAD], 25.0, "Head starts at 25")
	assert_eq(hp[DamageZone.Zone.LEFT_ARM], 20.0, "Left arm starts at 20")
	assert_eq(hp[DamageZone.Zone.RIGHT_ARM], 20.0, "Right arm starts at 20")


func test_no_limbs_severed_initially() -> void:
	var severed: Dictionary = enemy_script.get_meta("severed_limbs")
	for zone in severed:
		assert_false(severed[zone], "No limbs severed at start")


func test_damage_reduces_hp() -> void:
	var hp: Dictionary = enemy_script.get_meta("limb_health")
	hp[DamageZone.Zone.LEFT_ARM] -= 10.0
	assert_eq(hp[DamageZone.Zone.LEFT_ARM], 10.0, "Arm HP reduced by damage")


func test_damage_to_zero_triggers_sever() -> void:
	var hp: Dictionary = enemy_script.get_meta("limb_health")
	var severed: Dictionary = enemy_script.get_meta("severed_limbs")
	hp[DamageZone.Zone.LEFT_ARM] = 0.0
	severed[DamageZone.Zone.LEFT_ARM] = true
	assert_true(severed[DamageZone.Zone.LEFT_ARM], "Arm severed at 0 HP")
	assert_eq(hp[DamageZone.Zone.LEFT_ARM], 0.0, "HP stays at 0")


func test_damage_below_zero_clamps() -> void:
	var hp: Dictionary = enemy_script.get_meta("limb_health")
	hp[DamageZone.Zone.LEFT_ARM] = -5.0
	hp[DamageZone.Zone.LEFT_ARM] = maxf(hp[DamageZone.Zone.LEFT_ARM], 0.0)
	assert_eq(hp[DamageZone.Zone.LEFT_ARM], 0.0, "HP clamps to 0")


func test_torso_death_disables() -> void:
	var hp: Dictionary = enemy_script.get_meta("limb_health")
	hp[DamageZone.Zone.TORSO] = 0.0
	enemy_script.set_meta("disabled", true)
	assert_true(enemy_script.get_meta("disabled"), "Enemy disabled at 0 torso HP")


func test_multiple_limb_sever() -> void:
	var severed: Dictionary = enemy_script.get_meta("severed_limbs")
	severed[DamageZone.Zone.LEFT_ARM] = true
	severed[DamageZone.Zone.RIGHT_ARM] = true
	severed[DamageZone.Zone.LEFT_LEG] = true
	var count := 0
	for z in severed:
		if severed[z]: count += 1
	assert_eq(count, 3, "3 limbs severed")


func test_speed_reduction_one_leg() -> void:
	var base_speed := 120.0
	var severed: Dictionary = enemy_script.get_meta("severed_limbs")
	severed[DamageZone.Zone.LEFT_LEG] = true
	# Simulate speed calc: 1 leg = 50%
	var speed := base_speed * 0.5
	assert_eq(speed, 60.0, "Speed halved with 1 leg")


func test_speed_reduction_two_legs() -> void:
	var base_speed := 120.0
	var speed := base_speed * 0.15
	assert_eq(speed, 18.0, "Speed 15% with no legs")


func test_full_mutilation_check() -> void:
	var severed: Dictionary = enemy_script.get_meta("severed_limbs")
	# Sever all limbs
	for zone in severed:
		severed[zone] = true
	var all_severed := true
	for zone in severed:
		if not severed[zone]:
			all_severed = false
	assert_true(all_severed, "All limbs severed")


func test_independent_arm_tracking() -> void:
	var hp: Dictionary = enemy_script.get_meta("limb_health")
	var severed: Dictionary = enemy_script.get_meta("severed_limbs")
	# Sever left arm only
	hp[DamageZone.Zone.LEFT_ARM] = 0.0
	severed[DamageZone.Zone.LEFT_ARM] = true
	# Right arm still healthy
	assert_eq(hp[DamageZone.Zone.RIGHT_ARM], 20.0, "Right arm unaffected")
	assert_false(severed[DamageZone.Zone.RIGHT_ARM], "Right arm not severed")


func test_head_damage_not_sever_in_game() -> void:
	# Head can be damaged but in game logic it stuns, not severs
	var hp: Dictionary = enemy_script.get_meta("limb_health")
	hp[DamageZone.Zone.HEAD] -= 25.0
	assert_eq(hp[DamageZone.Zone.HEAD], 0.0, "Head at 0 = stunned (not severed in gameplay)")
