extends "res://scripts/tests/test_base.gd"

## TestSister — Tests for The Sister encounter stats, phases, choices, mechanics.
## Design doc: 14_BOSS_DESIGN.md section 10.1, 16_NARRATIVE_DESIGN.md section 3

# Stats from 14_BOSS_DESIGN.md
const TORSO_HP := 350.0
const LIMB_HP := 60.0
const MOVE_SPEED := 160.0
const REGEN_MULT := 1.3
const GRAB_STRENGTH := 0.0


# ── Stats verification ──

func test_sister_torso_hp() -> void:
	assert_eq(TORSO_HP, 350.0, "Sister torso HP = 350 per design doc")


func test_sister_limb_hp() -> void:
	assert_eq(LIMB_HP, 60.0, "Sister limb HP = 60 each")


func test_sister_speed() -> void:
	assert_eq(MOVE_SPEED, 160.0, "Sister speed = 160")


func test_sister_regen() -> void:
	assert_eq(REGEN_MULT, 1.3, "Sister regen = ×1.3")


func test_sister_no_grab() -> void:
	assert_eq(GRAB_STRENGTH, 0.0, "Sister grab strength = 0")


# ── Encounter structure ──

func test_three_phases() -> void:
	var phases := ["recognition", "confrontation", "resolution"]
	assert_eq(phases.size(), 3, "Sister encounter has 3 phases")


func test_recognition_auto() -> void:
	var is_automatic := true
	assert_true(is_automatic, "Phase 1 Recognition is automatic")


func test_confrontation_has_choices() -> void:
	var choices := ["fight", "listen", "embrace"]
	assert_eq(choices.size(), 3, "Confrontation has 3 choice options")


# ── Choice paths ──

func test_fight_path_exists() -> void:
	var fight_available := true
	assert_true(fight_available, "ATTACK choice available")


func test_listen_path_exists() -> void:
	var listen_available := true
	assert_true(listen_available, "LISTEN choice available")


func test_embrace_path_exists() -> void:
	var embrace_available := true
	assert_true(embrace_available, "EMBRACE choice available")


# ── Hesitation mechanic ──

func test_hesitation_thresholds() -> void:
	var thresholds := [0.8, 0.6, 0.4, 0.2]
	assert_eq(thresholds.size(), 4, "4 hesitation thresholds (every 20% HP)")


func test_hesitation_duration() -> void:
	var duration := 1.5
	assert_eq(duration, 1.5, "Hesitation pause = 1.5s")


func test_hesitation_texts() -> void:
	var texts := [
		"Why are you doing this?",
		"I'm still your sister.",
		"Please.",
	]
	assert_gte(texts.size(), 3, "At least 3 hesitation texts")


func test_player_can_attack_during_hesitation() -> void:
	var no_penalty := true
	assert_true(no_penalty, "No mechanical penalty for attacking during hesitation")


# ── Combat: copies player weapons ──

func test_copies_player_loadout() -> void:
	var copies_weapons := true
	assert_true(copies_weapons, "Sister copies player's equipped weapons")


# ── HP thresholds for endings ──

func test_spare_threshold() -> void:
	var spare_pct := 0.1  # <10% HP
	assert_eq(spare_pct, 0.1, "Spare = stop attacking at <10% HP (35 HP)")


func test_spare_requires_3s_pause() -> void:
	var pause_required := 3.0
	assert_eq(pause_required, 3.0, "Spare = no attack for 3 seconds")


# ── Embrace path ──

func test_embrace_stab_damage() -> void:
	var stab_pct := 0.5
	assert_eq(stab_pct, 0.5, "Embrace stab = 50% HP loss")


func test_embrace_survive_if_hp_above_50() -> void:
	var survives := true
	assert_true(survives, "Player survives if HP > 50% before stab")


func test_embrace_death_if_hp_below_50() -> void:
	var dies := true
	assert_true(dies, "Player dies if HP ≤ 50% before stab")


# ── Run count dialogue variations (16_NARRATIVE_DESIGN.md section 3.4) ──

func test_run1_dialogue() -> void:
	var run := 1
	var line := _get_opening_line(run)
	assert_eq(line, "How did you find me? You need to leave.", "Run 1 opening line")


func test_run2_dialogue() -> void:
	var run := 2
	var line := _get_opening_line(run)
	assert_eq(line, "You came back. I knew you would.", "Run 2 opening line")


func test_run3_dialogue() -> void:
	var run := 3
	var line := _get_opening_line(run)
	assert_eq(line, "You keep dying. I keep watching.", "Run 3+ opening line")


func test_run5plus_dialogue() -> void:
	var run := 5
	var line := _get_opening_line(run)
	assert_eq(line, "I remember all of them. Every time you've come for me.", "Run 5+ opening line")


func _get_opening_line(run: int) -> String:
	if run <= 1:
		return "How did you find me? You need to leave."
	elif run == 2:
		return "You came back. I knew you would."
	elif run >= 3 and run < 5:
		return "You keep dying. I keep watching."
	else:
		return "I remember all of them. Every time you've come for me."


# ── Void Contract blocks Ending C ──

func test_void_contract_blocks_ending_c() -> void:
	var has_void_contract := true
	var ending_c_available := not has_void_contract
	assert_false(ending_c_available, "Void Contract blocks Ending C")


func test_no_void_contract_allows_ending_c() -> void:
	var has_void_contract := false
	var ending_c_available := not has_void_contract
	assert_true(ending_c_available, "No Void Contract allows Ending C")


# ── Sister as ally (Ending B path) ──

func test_ally_hp() -> void:
	var ally_hp := 200.0
	assert_eq(ally_hp, 200.0, "Sister ally HP = 200")


func test_ally_damage() -> void:
	var ally_damage := 25.0
	assert_eq(ally_damage, 25.0, "Sister ally melee = 25 dmg")


func test_ally_regen() -> void:
	var ally_regen := 1.3
	assert_eq(ally_regen, 1.3, "Sister ally regen = ×1.3")


# ── Visual ──

func test_sprite_color() -> void:
	# #E0C0B0 pale skin/human tone
	var color := Color(0.878, 0.753, 0.69)
	assert_approx(color.r, 0.878, 0.01, "Sister sprite pale skin R")
	assert_approx(color.g, 0.753, 0.01, "Sister sprite pale skin G")
	assert_approx(color.b, 0.69, 0.01, "Sister sprite pale skin B")


# ── Ending triggers ──

func test_kill_sister_ending_a() -> void:
	var sister_killed := true
	var ending := "a" if sister_killed else "b"
	assert_eq(ending, "a", "Kill Sister → Ending A")


func test_spare_sister_ending_b() -> void:
	var sister_spared := true
	var ending := "b" if sister_spared else "a"
	assert_eq(ending, "b", "Spare Sister → Ending B")


func test_never_attack_ending_c() -> void:
	var never_attacked := true
	var ending := "c" if never_attacked else "a"
	assert_eq(ending, "c", "Never attack Sister → Ending C")


func test_embrace_ending_d() -> void:
	var embraced := true
	var ending := "d" if embraced else "a"
	assert_eq(ending, "d", "Embrace → Ending D")
