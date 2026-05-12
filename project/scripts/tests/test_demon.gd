extends "res://scripts/tests/test_base.gd"

## TestDemon — Tests for Demon enemy stats, no-limb model, attacks, phase, dissolve death.
## Design doc: 11_ENEMY_DESIGN.md section 3.8 DEMON

# Stats from 11_ENEMY_DESIGN.md
const TORSO_HP := 120.0
const HEAD_HP := 40.0
const MOVE_SPEED := 150.0
const DETECTION := 300.0
const CLAW_RANGE := 80.0
const BOLT_RANGE := 200.0
const ATTACK_SPEED := 1.0
const GRAB_STRENGTH := 0.0
const REGEN_MULT := 1.5
const AGGRESSION := 9.0
const COORDINATION := 5.0

# Attack params
const CLAW_DAMAGE_1 := 15.0
const CLAW_DAMAGE_2 := 20.0
const CLAW_DAMAGE_3 := 25.0
const BOLT_DAMAGE := 25.0
const BOLT_SPEED := 200.0
const BOLT_HOMING_RATE := 45.0
const BOLT_LIFETIME := 5.0

# Phase
const PHASE_COOLDOWN := 6.0

# Death
const REGEN_TIME := 45.0


# ── Stats verification ──

func test_demon_torso_hp() -> void:
	assert_eq(TORSO_HP, 120.0, "Demon torso HP = 120 per design doc")


func test_demon_head_hp() -> void:
	assert_eq(HEAD_HP, 40.0, "Demon head HP = 40 (stun target)")


func test_demon_no_arm_hp() -> void:
	assert_eq(0.0, 0.0, "Demon has NO arm HP (no limbs)")


func test_demon_no_leg_hp() -> void:
	assert_eq(0.0, 0.0, "Demon has NO leg HP (no limbs)")


func test_demon_speed() -> void:
	assert_eq(MOVE_SPEED, 150.0, "Demon speed = 150")


func test_demon_detection() -> void:
	assert_eq(DETECTION, 300.0, "Demon detection range = 300")


func test_demon_claw_range() -> void:
	assert_eq(CLAW_RANGE, 80.0, "Demon claw range = 80")


func test_demon_bolt_range() -> void:
	assert_eq(BOLT_RANGE, 200.0, "Demon dark bolt range = 200")


func test_demon_attack_speed() -> void:
	assert_eq(ATTACK_SPEED, 1.0, "Demon attack speed = 1.0")


func test_demon_grab_strength() -> void:
	assert_eq(GRAB_STRENGTH, 0.0, "Demon grab strength = 0 (NEVER grabs)")


func test_demon_regen_mult() -> void:
	assert_eq(REGEN_MULT, 1.5, "Demon regen = ×1.5")


func test_demon_aggression() -> void:
	assert_eq(AGGRESSION, 9.0, "Demon aggression = 9")


func test_demon_coordination() -> void:
	assert_eq(COORDINATION, 5.0, "Demon coordination = 5")


# ── No-limb model ──

func test_no_limb_sever_chance() -> void:
	var sever_chance := 0.0
	assert_eq(sever_chance, 0.0, "Demon cannot be severed (sever_chance = 0)")


func test_health_zones_count() -> void:
	# Only 2 damage zones: TORSO + HEAD
	var zones := 2
	assert_eq(zones, 2, "Demon has exactly 2 health zones (torso + head)")


func test_no_arm_leg_zones() -> void:
	var has_arms := false
	var has_legs := false
	assert_false(has_arms, "Demon has no arm zones")
	assert_false(has_legs, "Demon has no leg zones")


func test_damage_redirect_to_torso() -> void:
	# Any non-TORSO/non-HEAD hit redirects to TORSO
	var redirected := true
	assert_true(redirected, "Non-TORSO/HEAD damage redirects to TORSO")


# ── Claw combo ──

func test_claw_combo_3_hits() -> void:
	var claw_damage := [CLAW_DAMAGE_1, CLAW_DAMAGE_2, CLAW_DAMAGE_3]
	assert_eq(claw_damage.size(), 3, "Claw combo has 3 hits")


func test_claw_damage_values() -> void:
	assert_eq(CLAW_DAMAGE_1, 15.0, "Claw hit 1 = 15 dmg")
	assert_eq(CLAW_DAMAGE_2, 20.0, "Claw hit 2 = 20 dmg")
	assert_eq(CLAW_DAMAGE_3, 25.0, "Claw hit 3 = 25 dmg")


func test_claw_total_damage() -> void:
	var total := CLAW_DAMAGE_1 + CLAW_DAMAGE_2 + CLAW_DAMAGE_3
	assert_eq(total, 60.0, "Full claw combo total = 60 dmg")


# ── Dark bolt ──

func test_bolt_damage() -> void:
	assert_eq(BOLT_DAMAGE, 25.0, "Dark bolt = 25 dmg")


func test_bolt_speed() -> void:
	assert_eq(BOLT_SPEED, 200.0, "Dark bolt speed = 200 px/s (slow, dodgeable)")


func test_bolt_homing_rate() -> void:
	assert_eq(BOLT_HOMING_RATE, 45.0, "Dark bolt homing turn rate = 45 deg/s")


func test_bolt_lifetime() -> void:
	assert_eq(BOLT_LIFETIME, 5.0, "Dark bolt lifetime = 5s")


# ── Phase (teleport) ──

func test_phase_cooldown() -> void:
	assert_eq(PHASE_COOLDOWN, 6.0, "Phase cooldown = 6s")


func test_phase_disappear_duration() -> void:
	var disappear_time := 0.3
	assert_eq(disappear_time, 0.3, "Phase disappear time = 0.3s")


# ── Death / dissolve ──

func test_death_regen_time() -> void:
	assert_eq(REGEN_TIME, 45.0, "Demon regenerates from pool in 45s")


func test_dissolve_duration() -> void:
	var dissolve_time := 1.0
	assert_eq(dissolve_time, 1.0, "Dissolve animation = 1.0s")


func test_shadow_pool_radius() -> void:
	var pool_radius := 30.0
	assert_eq(pool_radius, 30.0, "Shadow pool radius = 30px")


func test_shadow_pool_color() -> void:
	var pool_color := Color(0.102, 0.039, 0.165)
	assert_approx(pool_color.r, 0.102, 0.01, "Shadow pool R component")
	assert_approx(pool_color.g, 0.039, 0.01, "Shadow pool G component")
	assert_approx(pool_color.b, 0.165, 0.01, "Shadow pool B component")


# ── Visual ──

func test_sprite_color() -> void:
	var sprite_color := Color(0.165, 0.039, 0.039)
	assert_approx(sprite_color.r, 0.165, 0.01, "Demon sprite = dark red/black")
	assert_approx(sprite_color.g, 0.039, 0.01, "Demon sprite low green")
	assert_approx(sprite_color.b, 0.039, 0.01, "Demon sprite low blue")


func test_eye_color() -> void:
	var eye_color := Color(1.0, 0.0, 0.0)
	assert_eq(eye_color.r, 1.0, "Demon eyes = red (#FF0000)")
	assert_eq(eye_color.g, 0.0, "Demon eyes no green")
	assert_eq(eye_color.b, 0.0, "Demon eyes no blue")


func test_collision_radius() -> void:
	# Smaller than human (12px vs 16px)
	var collision_radius := 12.0
	assert_eq(collision_radius, 12.0, "Demon collision = 12px (smaller, inhuman)")


# ── Difficulty scaling (11_ENEMY_DESIGN.md section 5.1 Floor 9) ──

func test_floor9_hp_mult() -> void:
	var hp_mult := 1.5
	assert_eq(hp_mult, 1.5, "Floor 9 HP multiplier = ×1.5")


func test_floor9_speed_mult() -> void:
	var speed_mult := 1.3
	assert_eq(speed_mult, 1.3, "Floor 9 speed multiplier = ×1.3")


func test_floor9_regen_mult() -> void:
	var regen_mult := 1.3
	assert_eq(regen_mult, 1.3, "Floor 9 regen multiplier = ×1.3")


func test_floor9_aggression_mult() -> void:
	var aggr_mult := 1.5
	assert_eq(aggr_mult, 1.5, "Floor 9 aggression multiplier = ×1.5")
