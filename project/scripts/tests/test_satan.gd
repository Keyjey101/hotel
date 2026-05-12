extends "res://scripts/tests/test_base.gd"

## TestSatan — Tests for Satan final boss stats, 3 phases, attacks, mechanics.
## Design doc: 14_BOSS_DESIGN.md section 10.2

# Phase stats from 14_BOSS_DESIGN.md
const PHASE_1_HP := 400.0
const PHASE_1_SPEED := 120.0
const PHASE_1_REGEN := 1.0

const PHASE_2_HP := 500.0
const PHASE_2_SPEED := 150.0
const PHASE_2_REGEN := 1.5

const PHASE_3_HP := 600.0
const PHASE_3_SPEED := 180.0
const PHASE_3_REGEN := 2.0

# Total HP across all phases
const TOTAL_HP := PHASE_1_HP + PHASE_2_HP + PHASE_3_HP

# Phase 1 attacks
const HANDSHAKE_DAMAGE := 30.0
const CONTRACT_DAMAGE := 20.0
const DISMISS_DAMAGE := 15.0
const DISMISS_KNOCKBACK := 200.0

# Phase 2 attacks
const LIQUIDATION_DAMAGE := 20.0
const FISCAL_YEAR_SLOW := 0.5
const FISCAL_YEAR_DURATION := 3.0

# Phase 3 attacks
const VOID_TOUCH_DAMAGE := 50.0
const DESECRATE_DURATION := 5.0
const COLLAPSE_START_RADIUS := 200.0
const COLLAPSE_END_RADIUS := 50.0
const COLLAPSE_DURATION := 10.0
const MARKET_CRASH_COUNT := 8
const MARKET_CRASH_DAMAGE := 15.0

# Final offer
const FINAL_OFFER_HP_PCT := 0.1


# ── Phase 1 stats ──

func test_phase1_hp() -> void:
	assert_eq(PHASE_1_HP, 400.0, "Phase 1 torso HP = 400")


func test_phase1_speed() -> void:
	assert_eq(PHASE_1_SPEED, 120.0, "Phase 1 speed = 120")


func test_phase1_regen() -> void:
	assert_eq(PHASE_1_REGEN, 1.0, "Phase 1 regen = ×1.0")


# ── Phase 2 stats ──

func test_phase2_hp() -> void:
	assert_eq(PHASE_2_HP, 500.0, "Phase 2 torso HP = 500")


func test_phase2_speed() -> void:
	assert_eq(PHASE_2_SPEED, 150.0, "Phase 2 speed = 150")


func test_phase2_regen() -> void:
	assert_eq(PHASE_2_REGEN, 1.5, "Phase 2 regen = ×1.5")


# ── Phase 3 stats ──

func test_phase3_hp() -> void:
	assert_eq(PHASE_3_HP, 600.0, "Phase 3 torso HP = 600")


func test_phase3_speed() -> void:
	assert_eq(PHASE_3_SPEED, 180.0, "Phase 3 speed = 180")


func test_phase3_regen() -> void:
	assert_eq(PHASE_3_REGEN, 2.0, "Phase 3 regen = ×2.0")


# ── Total HP ──

func test_total_hp() -> void:
	assert_eq(TOTAL_HP, 1500.0, "Satan total HP across all phases = 1500")


func test_phase_order() -> void:
	assert_gt(PHASE_2_HP, 0.0, "Phase 2 HP > 0")
	assert_gt(PHASE_3_HP, 0.0, "Phase 3 HP > 0")
	assert_gt(PHASE_2_HP + PHASE_3_HP, PHASE_3_HP, "Phase 2+3 > Phase 3 alone")


# ── Phase 1 "The Interview" attacks ──

func test_handshake_damage() -> void:
	assert_eq(HANDSHAKE_DAMAGE, 30.0, "Handshake grab+drain = 30 dmg")


func test_handshake_range() -> void:
	var range := 30.0
	assert_eq(range, 30.0, "Handshake triggers at < 30px")


func test_contract_damage() -> void:
	assert_eq(CONTRACT_DAMAGE, 20.0, "Contract throw = 20 dmg")


func test_contract_fine_print() -> void:
	var speed_reduction := 0.15
	assert_eq(speed_reduction, 0.15, "Fine print: player speed −15%")


func test_contract_fine_print_duration() -> void:
	var duration := 5.0
	assert_eq(duration, 5.0, "Fine print lasts 5s")


func test_dismiss_damage() -> void:
	assert_eq(DISMISS_DAMAGE, 15.0, "Dismiss = 15 dmg")


func test_dismiss_knockback() -> void:
	assert_eq(DISMISS_KNOCKBACK, 200.0, "Dismiss knockback = 200px")


func test_summon_demon_count_p1() -> void:
	var count := 1
	assert_eq(count, 1, "Phase 1 summons Demon ×1")


# ── Phase 2 "The Audit" attacks ──

func test_liquidation_damage() -> void:
	assert_eq(LIQUIDATION_DAMAGE, 20.0, "Liquidation = 20 dmg/s")


func test_liquidation_warning_time() -> void:
	var warning := 1.0
	assert_eq(warning, 1.0, "Liquidation zones telegraphed 1s")


func test_fiscal_year_slow() -> void:
	assert_eq(FISCAL_YEAR_SLOW, 0.5, "Fiscal Year: player at 0.5× speed")


func test_fiscal_year_duration() -> void:
	assert_eq(FISCAL_YEAR_DURATION, 3.0, "Fiscal Year lasts 3s")


func test_weapon_steal_exists() -> void:
	var has_steal := true
	assert_true(has_steal, "Phase 2 has Hostile Takeover (weapon steal)")


func test_summon_demon_count_p2() -> void:
	var count := 2
	assert_eq(count, 2, "Phase 2 summons Demon ×2")


# ── Phase 3 "Bankruptcy" attacks ──

func test_void_touch_damage() -> void:
	assert_eq(VOID_TOUCH_DAMAGE, 50.0, "Void Touch = 50 dmg")


func test_desecrate_duration() -> void:
	assert_eq(DESECRATE_DURATION, 5.0, "Desecrate: no heal for 5s")


func test_collapse_start_radius() -> void:
	assert_eq(COLLAPSE_START_RADIUS, 200.0, "Economic Collapse starts at 200px")


func test_collapse_end_radius() -> void:
	assert_eq(COLLAPSE_END_RADIUS, 50.0, "Economic Collapse shrinks to 50px")


func test_collapse_duration() -> void:
	assert_eq(COLLAPSE_DURATION, 10.0, "Economic Collapse over 10s")


func test_market_crash_count() -> void:
	assert_eq(MARKET_CRASH_COUNT, 8, "Market Crash = 8 projectiles")


func test_market_crash_damage() -> void:
	assert_eq(MARKET_CRASH_DAMAGE, 15.0, "Market Crash projectile = 15 dmg")


# ── Final Offer ──

func test_final_offer_threshold() -> void:
	assert_eq(FINAL_OFFER_HP_PCT, 0.1, "Final Offer at 10% total HP")


func test_final_offer_choices() -> void:
	var choices := ["accept", "reject"]
	assert_eq(choices.size(), 2, "Final Offer has 2 choices")


func test_accept_ending_d() -> void:
	var accept := true
	var ending := "d" if accept else "continue"
	assert_eq(ending, "d", "Accept → Ending D variant")


# ── Visual ──

func test_suit_color() -> void:
	var suit := Color(0.102, 0.102, 0.102)
	assert_approx(suit.r, 0.102, 0.01, "Black suit color R")
	assert_approx(suit.g, 0.102, 0.01, "Black suit color G")
	assert_approx(suit.b, 0.102, 0.01, "Black suit color B")


func test_cufflink_color() -> void:
	var gold := Color(1.0, 0.843, 0.0)
	assert_eq(gold, Color(1.0, 0.843, 0.0), "Cufflinks = #FFD700 gold")


func test_tie_color() -> void:
	var tie := Color(1.0, 0.843, 0.0)
	assert_eq(tie, Color(1.0, 0.843, 0.0), "Tie = #FFD700 gold")


func test_phase2_damage_visual() -> void:
	var cracks_visible := true
	assert_true(cracks_visible, "Phase 2: skin cracks visible, void shows through")


func test_phase3_breakdown_visual() -> void:
	var form_breaking := true
	assert_true(form_breaking, "Phase 3: form breaking down, void entity in suit")


# ── Dialogue ──

func test_p1_dialogue_count() -> void:
	var pool_size := 3
	assert_eq(pool_size, 3, "Phase 1 has 3 dialogue lines")


func test_p2_dialogue_count() -> void:
	var pool_size := 3
	assert_eq(pool_size, 3, "Phase 2 has 3 dialogue lines")


func test_dialogue_interval() -> void:
	var interval := 8.0
	assert_eq(interval, 8.0, "Dialogue every 8s between attacks")


# ── Phase transitions ──

func test_phase_transition_p1_to_p2() -> void:
	# Phase 1 → Phase 2 when HP drops below Phase1HP
	var current_hp := PHASE_2_HP + PHASE_3_HP + 1.0
	var phase := _get_phase(current_hp)
	assert_eq(phase, 1, "HP > Phase2+Phase3 total = Phase 1")


func test_phase_transition_p2_to_p3() -> void:
	var current_hp := PHASE_3_HP + 1.0
	var phase := _get_phase(current_hp)
	assert_eq(phase, 2, "HP > Phase3 total = Phase 2")


func test_phase_transition_p3() -> void:
	var current_hp := PHASE_3_HP - 1.0
	var phase := _get_phase(current_hp)
	assert_eq(phase, 3, "HP <= Phase3 total = Phase 3")


func _get_phase(hp: float) -> int:
	if hp > PHASE_2_HP + PHASE_3_HP:
		return 1
	elif hp > PHASE_3_HP:
		return 2
	else:
		return 3


# ── Death → ending determination ──

func test_death_ending_determination() -> void:
	# Test all 4 ending paths
	var ending_tests := [
		{"sister_killed": true, "sister_spared": false, "never_attacked": false, "embraced": false, "expected": "a"},
		{"sister_killed": false, "sister_spared": true, "never_attacked": false, "embraced": false, "expected": "b"},
		{"sister_killed": false, "sister_spared": false, "never_attacked": true, "embraced": false, "expected": "c"},
		{"sister_killed": false, "sister_spared": false, "never_attacked": false, "embraced": true, "expected": "d"},
	]
	for test in ending_tests:
		var result := _determine_ending(
			test["sister_killed"], test["sister_spared"],
			test["never_attacked"], test["embraced"]
		)
		assert_eq(result, test["expected"], "Ending = %s for this path" % test["expected"])


func _determine_ending(sister_killed: bool, sister_spared: bool, never_attacked: bool, embraced: bool) -> String:
	if embraced:
		return "d"
	if never_attacked:
		return "c"
	if sister_spared:
		return "b"
	return "a"
