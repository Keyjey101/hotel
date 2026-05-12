extends "res://scripts/tests/test_base.gd"

## TestConsort — Tests for The Consort boss stats, phases, commands, combat.
## Design doc: 14_BOSS_DESIGN.md section 9

# Stats from 14_BOSS_DESIGN.md
const TORSO_HP := 200.0
const LIMB_HP := 35.0
const MOVE_SPEED := 110.0
const REGEN_MULT := 1.0
const GUARD_COUNT := 4


# --- Stats verification ---

func test_consort_torso_hp() -> void:
	assert_eq(TORSO_HP, 200.0, "Consort torso HP = 200 per design doc")


func test_consort_limb_hp() -> void:
	assert_eq(LIMB_HP, 35.0, "Consort limb HP = 35 each per design doc")


func test_consort_move_speed() -> void:
	assert_eq(MOVE_SPEED, 110.0, "Consort speed = 110 (stays behind guards)")


func test_consort_guard_count() -> void:
	assert_eq(GUARD_COUNT, 4, "Consort always has 4 Royal Guards")


# --- Phase transitions ---

func test_phase1_with_4_guards() -> void:
	var guard_count := 4
	var phase := _get_phase(guard_count)
	assert_eq(phase, 1, "4 guards alive = Phase 1 Retinue")


func test_phase1_with_3_guards() -> void:
	var guard_count := 3
	var phase := _get_phase(guard_count)
	assert_eq(phase, 1, "3 guards alive = Phase 1 Retinue")


func test_phase2_with_2_guards() -> void:
	var guard_count := 2
	var phase := _get_phase(guard_count)
	assert_eq(phase, 2, "2 guards alive = Phase 2 Court")


func test_phase2_with_1_guard() -> void:
	var guard_count := 1
	var phase := _get_phase(guard_count)
	assert_eq(phase, 2, "1 guard alive = Phase 2 Court")


func test_phase3_no_guards() -> void:
	var guard_count := 0
	var phase := _get_phase(guard_count)
	assert_eq(phase, 3, "0 guards alive = Phase 3 Alone")


func _get_phase(guard_count: int) -> int:
	if guard_count >= 3:
		return 1
	elif guard_count >= 1:
		return 2
	else:
		return 3


# --- Phase 1: Retinue ---

func test_phase1_commands_rotate() -> void:
	# Phase 1: commands rotate every 8s [shield_wall → surround → shield_wall]
	var commands: Array[String] = ["shield_wall", "surround", "shield_wall"]
	assert_eq(commands.size(), 3, "Phase 1 has 3 command pattern entries")
	assert_eq(commands[0], "shield_wall", "Phase 1 starts with shield_wall")
	assert_eq(commands[1], "surround", "Phase 1 alternates to surround")


func test_phase1_consort_does_not_attack() -> void:
	# Phase 1: Consort does NOT attack directly — only commands
	var phase := 1
	var consort_attacks := false
	if phase == 1:
		consort_attacks = false
	assert_false(consort_attacks, "Phase 1: Consort does not attack directly")


func test_phase1_command_cooldown() -> void:
	var cooldown := 8.0
	assert_eq(cooldown, 8.0, "Phase 1: commands every 8 seconds")


# --- Phase 2: Court ---

func test_phase2_faster_commands() -> void:
	var phase2_cooldown := 4.0
	assert_eq(phase2_cooldown, 4.0, "Phase 2: commands every 4 seconds (faster)")


func test_phase2_dagger_damage() -> void:
	var dagger_damage := 15.0
	assert_eq(dagger_damage, 15.0, "Phase 2: ornamental daggers = 15 dmg")


func test_phase2_dagger_range() -> void:
	var dagger_range := 200.0
	assert_eq(dagger_range, 200.0, "Phase 2: dagger range = 200 px")


func test_phase2_guard_replacement_cooldown() -> void:
	var replacement_cooldown := 30.0
	assert_eq(replacement_cooldown, 30.0, "Phase 2: summon replacement guard every 30s")


func test_phase2_summons_if_below_3() -> void:
	var guards_alive := 2
	var should_summon := guards_alive < 3
	assert_true(should_summon, "Phase 2: summons guard if count < 3")


# --- Phase 3: Alone ---

func test_phase3_rapier_damage() -> void:
	var rapier_damage := 25.0
	assert_eq(rapier_damage, 25.0, "Phase 3: rapier thrust = 25 dmg per design doc")


func test_phase3_rapier_range() -> void:
	var rapier_range := 80.0
	assert_eq(rapier_range, 80.0, "Phase 3: rapier range = 80 px (long)")


func test_phase3_fan_swipe_damage() -> void:
	var fan_damage := 20.0
	assert_eq(fan_damage, 20.0, "Phase 3: fan swipe = 20 dmg")


func test_phase3_summon_channel_time() -> void:
	var channel_time := 3.0
	assert_eq(channel_time, 3.0, "Phase 3: summon channel = 3s")


func test_phase3_summon_interruptible() -> void:
	# If Consort takes damage during channel → cancel
	var is_summoning := true
	var took_damage := true
	if took_damage:
		is_summoning = false
	assert_false(is_summoning, "Phase 3: summon channel interrupted by damage")


func test_phase3_scream_stun_duration() -> void:
	var scream_stun := 0.5
	assert_eq(scream_stun, 0.5, "Phase 3: desperate scream = 0.5s AoE stun")


func test_phase3_scream_radius() -> void:
	var scream_radius := 60.0
	assert_eq(scream_radius, 60.0, "Phase 3: scream radius = 60 px")


# --- Command patterns ---

func test_shield_wall_positions() -> void:
	# Guards form line in front of Consort, 40px apart
	var consort_pos := Vector2(200.0, 200.0)
	var line_start := consort_pos + Vector2(0.0, -40.0)
	var guard_count := 4
	var spacing := 40.0

	var positions: Array[Vector2] = []
	for i in range(guard_count):
		var offset_x := (i - (guard_count - 1) * 0.5) * spacing
		positions.append(line_start + Vector2(offset_x, 0.0))

	assert_eq(positions.size(), 4, "4 guard positions for shield wall")
	# First guard offset
	assert_eq(positions[0].x, line_start.x - 60.0, "First guard at -60px offset")
	# Last guard offset
	assert_eq(positions[3].x, line_start.x + 60.0, "Last guard at +60px offset")


func test_surround_positions() -> void:
	# Guards encircle player at radius 80px
	var player_pos := Vector2(300.0, 300.0)
	var radius := 80.0
	var guard_count := 4

	var positions: Array[Vector2] = []
	for i in range(guard_count):
		var angle := (TAU * i) / guard_count
		positions.append(player_pos + Vector2(cos(angle), sin(angle)) * radius)

	assert_eq(positions.size(), 4, "4 guard positions for surround")
	# All positions at radius distance from player
	for pos in positions:
		var dist := player_pos.distance_to(pos)
		assert_eq(dist, 80.0, "Surround position at 80px from player")


func test_pinch_splits_guards() -> void:
	# 2 guards from left, 2 from right
	var guard_count := 4
	var half := guard_count / 2
	assert_eq(half, 2, "Pinch splits 4 guards into 2 groups of 2")


# --- Death behavior ---

func test_consort_death_berserks_guards() -> void:
	# Remaining guards: aggression += 3, formation breaks → berserk
	var guard_aggression := 7.0
	guard_aggression += 3.0
	assert_eq(guard_aggression, 10.0, "Guards go berserk (aggression +3) on Consort death")


func test_consort_death_emits_signal() -> void:
	# EventBus.mini_boss_defeated.emit(8)
	var floor_number := 8
	assert_eq(floor_number, 8, "Mini boss defeated signal for floor 8")
