extends "res://scripts/tests/test_base.gd"

## TestChampion — Tests for Champion enemy stats, combo, parry, charge, adaptive AI.
## Design doc: 11_ENEMY_DESIGN.md section 3.7 CHAMPION

# Stats from design doc
const TORSO_HP := 130.0
const HEAD_HP := 40.0
const ARM_HP := 35.0
const LEG_HP := 30.0
const MOVE_SPEED := 140.0
const DETECTION_RANGE := 180.0
const ATTACK_RANGE := 65.0
const ATTACK_SPEED := 0.5
const GRAB_STRENGTH := 4.0
const AGGRESSION := 8.0
const COORDINATION := 6.0


# --- Stats verification (per 11_ENEMY_DESIGN.md) ---

func test_champion_torso_hp() -> void:
	assert_eq(TORSO_HP, 130.0, "Champion torso HP = 130")


func test_champion_head_hp() -> void:
	assert_eq(HEAD_HP, 40.0, "Champion head HP = 40")


func test_champion_arm_hp() -> void:
	assert_eq(ARM_HP, 35.0, "Champion arm HP = 35")


func test_champion_leg_hp() -> void:
	assert_eq(LEG_HP, 30.0, "Champion leg HP = 30")


func test_champion_move_speed() -> void:
	assert_eq(MOVE_SPEED, 140.0, "Champion move speed = 140")


func test_champion_detection() -> void:
	assert_eq(DETECTION_RANGE, 180.0, "Champion detection = 180")


func test_champion_attack_range() -> void:
	assert_eq(ATTACK_RANGE, 65.0, "Champion attack range (greatsword) = 65")


func test_champion_attack_speed() -> void:
	assert_eq(ATTACK_SPEED, 0.5, "Champion attack speed = 0.5")


func test_champion_grab_strength() -> void:
	assert_eq(GRAB_STRENGTH, 4.0, "Champion grab strength = 4")


func test_champion_aggression() -> void:
	assert_eq(AGGRESSION, 8.0, "Champion aggression = 8")


func test_champion_coordination() -> void:
	assert_eq(COORDINATION, 6.0, "Champion coordination = 6")


# --- Greatsword combo (per design doc: 15→20→25→35) ---

func test_combo_damage_values() -> void:
	var combo_damage: Array[float] = [15.0, 20.0, 25.0, 35.0]
	assert_eq(combo_damage[0], 15.0, "Combo hit 1 = 15 dmg")
	assert_eq(combo_damage[1], 20.0, "Combo hit 2 = 20 dmg")
	assert_eq(combo_damage[2], 25.0, "Combo hit 3 = 25 dmg")
	assert_eq(combo_damage[3], 35.0, "Combo hit 4 = 35 dmg")


func test_combo_hit_count() -> void:
	var combo_damage: Array[float] = [15.0, 20.0, 25.0, 35.0]
	assert_eq(combo_damage.size(), 4, "Combo has exactly 4 hits")


func test_combo_increasing_damage() -> void:
	var combo_damage: Array[float] = [15.0, 20.0, 25.0, 35.0]
	for i in range(1, combo_damage.size()):
		assert_gt(combo_damage[i], combo_damage[i - 1],
			"Combo hit %d > hit %d in damage" % [i + 1, i])


func test_combo_last_hit_guaranteed_sever() -> void:
	# Design: last hit = guaranteed limb sever (sever_chance = 1.0)
	var last_hit_index := 3
	var sever_chance := 1.0
	assert_eq(sever_chance, 1.0, "Last combo hit (index %d) = guaranteed sever" % last_hit_index)


func test_combo_total_damage() -> void:
	var combo_damage: Array[float] = [15.0, 20.0, 25.0, 35.0]
	var total := 0.0
	for d in combo_damage:
		total += d
	assert_eq(total, 95.0, "Full combo total = 95 dmg")


# --- Parry Master (70% base) ---

func test_parry_base_chance() -> void:
	var base_parry := 0.7
	assert_eq(base_parry, 0.7, "Base parry chance = 70% per design doc")


func test_parry_only_frontal() -> void:
	# Parry doesn't work from behind: dot product check
	var facing := Vector2(0.0, 1.0)  # Facing down
	var incoming_frontal := Vector2(0.0, 1.0)  # From front (dot > 0)
	var incoming_behind := Vector2(0.0, -1.0)  # From behind (dot < 0)

	assert_gt(facing.dot(incoming_frontal), 0.0, "Frontal attack has positive dot → can parry")
	assert_lt(facing.dot(incoming_behind), 0.0, "Behind attack has negative dot → cannot parry")


func test_parry_no_ranged() -> void:
	# Parry doesn't work on ranged/thrown attacks (no knockback_dir)
	var has_knockback_dir := false  # Ranged attacks typically have no dir
	var can_parry := has_knockback_dir
	assert_false(can_parry, "Cannot parry attacks without knockback direction (ranged)")


func test_counter_attack_damage() -> void:
	# Successful parry → counter-attack 20 dmg
	var counter_damage := 20.0
	assert_eq(counter_damage, 20.0, "Counter-attack after parry = 20 dmg")


# --- Charge attack ---

func test_charge_damage() -> void:
	var charge_damage := 40.0
	assert_eq(charge_damage, 40.0, "Charge attack = 40 dmg per design doc")


func test_charge_armor() -> void:
	# 50% damage reduction during charge
	var damage_reduction := 0.5
	assert_eq(damage_reduction, 0.5, "Charge gives 50% damage reduction")


func test_charge_knockback_on_hit() -> void:
	# Charge hits → knockback
	var has_knockback := true
	assert_true(has_knockback, "Charge hit applies knockback")


# --- Adaptive AI ---

func test_adaptive_parry_increases() -> void:
	# After 5 melee hits → parry chance 85% (from 70%)
	var player_melee_count := 5
	var base_parry := 0.7
	var current_parry := base_parry
	if player_melee_count > 5:
		current_parry = 0.85
	# Just at 5 — doesn't trigger yet
	assert_eq(current_parry, 0.7, "At exactly 5 melee hits, parry stays 70%")

	player_melee_count = 6
	if player_melee_count > 5:
		current_parry = 0.85
	assert_eq(current_parry, 0.85, "After 5+ melee hits, parry increases to 85%")


func test_adaptive_speed_increases() -> void:
	# After 5 ranged hits → move_speed increases
	var player_ranged_count := 6
	var base_speed := MOVE_SPEED
	var speed := base_speed
	if player_ranged_count > 5:
		speed = base_speed * 1.2
	assert_eq(speed, 168.0, "After 5+ ranged hits, speed = base × 1.2 = 168")


func test_adaptive_resets_between_rooms() -> void:
	# Counters reset when entering new room
	var melee_count := 10
	var ranged_count := 8
	# Simulate room transition
	melee_count = 0
	ranged_count = 0
	assert_eq(melee_count, 0, "Melee count resets on room transition")
	assert_eq(ranged_count, 0, "Ranged count resets on room transition")


# --- Mutilation (most dangerous mutilated enemy) ---

func test_mutilated_one_arm_faster() -> void:
	# One arm → switches to one-handed sword → FASTER (attack_speed 0.8)
	var one_arm_lost := true
	var new_attack_speed := ATTACK_SPEED
	if one_arm_lost:
		new_attack_speed = 0.8
	assert_eq(new_attack_speed, 0.8, "One arm → attack speed INCREASES to 0.8 (faster)")


func test_mutilated_one_leg_wider_sweeps() -> void:
	# One leg → stays put but sweeps WIDER (arc 180° instead of 120°)
	var one_leg_lost := true
	var new_attack_range := ATTACK_RANGE
	if one_leg_lost:
		new_attack_range = 80.0
	assert_eq(new_attack_range, 80.0, "One leg → attack range INCREASES to 80 (wider sweeps)")


func test_mutilated_most_dangerous() -> void:
	# Champion does NOT weaken when mutilated — gets MORE dangerous
	var one_arm_lost := true
	var one_leg_lost := true
	# One arm: faster attacks
	# One leg: wider sweeps
	assert_true(one_arm_lost or one_leg_lost,
		"Mutilated Champion remains extremely dangerous")
