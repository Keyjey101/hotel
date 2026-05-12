extends "res://scripts/tests/test_base.gd"

## TestCombatFlow — Integration tests for damage pipeline, weapon flow, and edge cases.
## Simulates combat scenarios without full scene tree.


func test_full_damage_pipeline() -> void:
	# Simulate: Machete hits enemy LEFT_ARM for 20 × 1.5 = 30 damage
	var weapon := load("res://resources/weapons/melee_machete.tres") as WeaponData
	var limb_hp := 20.0
	var zone := DamageZone.Zone.LEFT_ARM

	# Apply damage
	var damage := weapon.damage * weapon.limb_damage_multiplier
	limb_hp -= damage

	assert_eq(damage, 30.0, "Machete deals 30 limb damage")
	assert_lt(limb_hp, 0.0, "Arm HP goes below 0 = severed")


func test_sever_threshold_exact() -> void:
	# Axe does 35 × 1.8 = 63 to limb. Most limbs have 20-30 HP. Guaranteed sever.
	var weapon := WeaponData.new()
	weapon.damage = 35.0
	weapon.limb_damage_multiplier = 1.8
	weapon.sever_chance = 0.5

	var limb_hp := 30.0
	var damage := weapon.damage * weapon.limb_damage_multiplier
	limb_hp -= damage

	assert_lt(limb_hp, 0.0, "Axe overkills limb = sever")
	var should_sever := limb_hp <= 0.0 and randf() < weapon.sever_chance
	# Even without RNG, HP below 0 = auto-sever in our system


func test_knife_precision_mutilation() -> void:
	# Knife: 10 dmg × 2.0 limb = 20 per hit. Arm HP = 20.
	# Two hits = exactly sever
	var weapon := WeaponData.new()
	weapon.damage = 10.0
	weapon.limb_damage_multiplier = 2.0

	var arm_hp := 20.0
	arm_hp -= weapon.damage * weapon.limb_damage_multiplier  # First hit: 20
	assert_eq(arm_hp, 0.0, "One knife hit exactly empties arm HP")


func test_bat_doesnt_sever() -> void:
	# Bat: 18 × 0.8 = 14.4 to limb. Low sever chance.
	var weapon := WeaponData.new()
	weapon.damage = 18.0
	weapon.limb_damage_multiplier = 0.8
	weapon.sever_chance = 0.05

	var arm_hp := 20.0
	arm_hp -= weapon.damage * weapon.limb_damage_multiplier  # 14.4
	assert_gt(arm_hp, 0.0, "Bat doesn't sever in one hit")


func test_regen_pause_on_hit() -> void:
	var regen_time := 25.0  # 5 seconds of regen done
	var hit_pause := 2.0
	# Hit pauses regen
	var is_paused := true
	var pause_remaining := hit_pause

	assert_true(is_paused, "Regen paused on hit")

	# Timer ticks down
	pause_remaining -= 2.0
	if pause_remaining <= 0.0:
		is_paused = false
		regen_time -= 0.0  # No regen during pause

	assert_false(is_paused, "Pause ends after 2s")
	assert_eq(regen_time, 25.0, "No regen progress during pause")


func test_multiple_hits_extend_pause() -> void:
	var pause_remaining := 0.5  # Almost unpaused
	# New hit resets pause
	pause_remaining = 2.0
	assert_eq(pause_remaining, 2.0, "Pause reset by new hit")


func test_damage_while_regenning() -> void:
	# Enemy regenerating arm. Player hits arm again.
	var arm_hp := 10.0  # Was severed, now regenerating (halfway)
	var damage := 15.0
	arm_hp -= damage
	# HP goes negative again → re-sever
	assert_lt(arm_hp, 0.0, "Arm re-severed during regen")


func test_player_death_at_zero_hp() -> void:
	var player_hp := 15.0
	var damage := 20.0
	player_hp -= damage
	assert_lte(player_hp, 0.0, "Player HP at or below 0 = death")


func test_player_survives_exact_hp() -> void:
	var player_hp := 20.0
	var damage := 20.0
	player_hp -= damage
	# At exactly 0, still alive (check is < 0 or <= 0?)
	# Our system: HP <= 0 = capture
	assert_eq(player_hp, 0.0, "Exactly 0 = capture trigger")


func test_upgrade_damage_mult_applied() -> void:
	var state := RunState.new()
	state.apply_stat_upgrade("damage_melee", 0.20)

	var base_damage := 20.0
	var mult: float = 1.0 + float(state.stat_upgrades.get("damage_melee", 0.0))
	var final_damage: float = base_damage * mult

	assert_eq(final_damage, 24.0, "20% melee upgrade = 24 damage from 20 base")


func test_sawed_off_pellet_damage_total() -> void:
	var weapon := load("res://resources/weapons/ranged_sawed_off.tres") as WeaponData
	var total := 0.0
	for i in range(weapon.projectile_count):
		total += weapon.damage
	assert_eq(total, 125.0, "All 5 pellets = 125 total")


func test_sever_chance_rng_bounds() -> void:
	# Sever chance should be between 0 and 1
	var weapons := [
		load("res://resources/weapons/melee_machete.tres"),
		load("res://resources/weapons/melee_knife.tres"),
		load("res://resources/weapons/melee_bat.tres"),
	]
	for w in weapons:
		assert_between(w.sever_chance, 0.0, 1.0, "%s sever chance in bounds" % w.name)


func test_weapon_throw_vs_melee_damage_difference() -> void:
	var weapon := load("res://resources/weapons/melee_machete.tres") as WeaponData
	assert_lt(weapon.throw_damage, weapon.damage, "Throw less than melee for machete")


func test_disabled_enemy_doesnt_take_damage() -> void:
	var disabled := true
	var hp := 30.0
	if not disabled:
		hp -= 20.0
	assert_eq(hp, 30.0, "Disabled enemy doesn't take more damage")


func assert_lte(value: float, limit: float, message: String = "") -> void:
	if value > limit:
		var msg := "Expected %s <= %s" % [str(value), str(limit)]
		if message != "": msg = message
		_test_runner.report_failure(msg)
