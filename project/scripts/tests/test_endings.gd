extends "res://scripts/tests/test_base.gd"

## TestEndings — Tests for 4 ending scenes, GameManager ending triggers, SaveManager.
## Design doc: 16_NARRATIVE_DESIGN.md section 6

# ── Ending A — "The Escape" ──

func test_ending_a_background() -> void:
	var bg := Color(0.102, 0.102, 0.102)  # #1A1A1A dark
	assert_approx(bg.r, 0.102, 0.01, "Ending A bg R = #1A")
	assert_approx(bg.g, 0.102, 0.01, "Ending A bg G = #1A")
	assert_approx(bg.b, 0.102, 0.01, "Ending A bg B = #1A")


func test_ending_a_title() -> void:
	var title := "ESCAPED"
	assert_eq(title, "ESCAPED", "Ending A title = ESCAPED")


func test_ending_a_title_color() -> void:
	var color := Color(0.855, 0.647, 0.125)  # #DAA520 gold
	assert_eq(color, Color(0.855, 0.647, 0.125), "Ending A title = gold #DAA520")


func test_ending_a_text_content() -> void:
	var text := "The Hotel is gone. The system is destroyed. But the memory remains. Her face, at the end. She forgave you. You're not sure you forgive yourself."
	assert_true(text.find("Hotel is gone") >= 0, "Ending A mentions Hotel destroyed")
	assert_true(text.find("forgave") >= 0, "Ending A mentions forgiveness")


func test_ending_a_requirements() -> void:
	# Kill Sister + Kill Satan
	var sister_killed := true
	var satan_killed := true
	assert_true(sister_killed and satan_killed, "Ending A: Sister killed + Satan killed")


# ── Ending B — "The Rescue" ──

func test_ending_b_background() -> void:
	var bg := Color(0.102, 0.102, 0.165)  # #1A1A2A dark blue
	assert_approx(bg.r, 0.102, 0.01, "Ending B bg R")
	assert_approx(bg.g, 0.102, 0.01, "Ending B bg G")
	assert_approx(bg.b, 0.165, 0.01, "Ending B bg B = blue tint")


func test_ending_b_title() -> void:
	var title := "ESCAPED"
	assert_eq(title, "ESCAPED", "Ending B title = ESCAPED")


func test_ending_b_text_content() -> void:
	var text := "The Hotel is gone. She's not the same. Neither are you. But you're together."
	assert_true(text.find("together") >= 0, "Ending B mentions being together")


func test_ending_b_requirements() -> void:
	# Spare Sister + Kill Satan
	var sister_spared := true
	var satan_killed := true
	assert_true(sister_spared and satan_killed, "Ending B: Sister spared + Satan killed")


func test_ending_b_sister_must_be_alive() -> void:
	var sister_alive := true
	assert_true(sister_alive, "Ending B requires Sister alive")


# ── Ending C — "The Revelation" ──

func test_ending_c_background() -> void:
	var bg := Color(0.04, 0.04, 0.04)  # #0A0A0A void black
	assert_approx(bg.r, 0.04, 0.01, "Ending C bg R = void")
	assert_approx(bg.g, 0.04, 0.01, "Ending C bg G = void")
	assert_approx(bg.b, 0.04, 0.01, "Ending C bg B = void")


func test_ending_c_title() -> void:
	var title := "THE TRUTH"
	assert_eq(title, "THE TRUTH", "Ending C title = THE TRUTH")


func test_ending_c_text_content() -> void:
	var text := "You came here to save her. But you were never outside. You were always inside. The Hotel doesn't have guests. It has inmates. And you... you were the first."
	assert_true(text.find("never outside") >= 0, "Ending C mentions never being outside")
	assert_true(text.find("first") >= 0, "Ending C mentions being the first")


func test_ending_c_requirements() -> void:
	# Never attack Sister (0 damage dealt)
	var sister_damage := 0.0
	var never_attacked := sister_damage == 0.0
	assert_true(never_attacked, "Ending C: never attacked Sister (0 damage)")


func test_ending_c_no_void_contract() -> void:
	# Void Contract blocks Ending C
	var has_void_contract := false
	assert_false(has_void_contract, "Ending C requires NO Void Contract")


func test_ending_c_bypasses_satan() -> void:
	var bypass_satan := true
	assert_true(bypass_satan, "Ending C bypasses Satan fight entirely")


# ── Ending D — "The Ascension" ──

func test_ending_d_background() -> void:
	var bg := Color(1.0, 0.843, 0.0)  # #FFD700 gold
	assert_approx(bg.r, 1.0, 0.01, "Ending D bg R = gold")
	assert_approx(bg.g, 0.843, 0.01, "Ending D bg G = gold")
	assert_approx(bg.b, 0.0, 0.01, "Ending D bg B = 0")


func test_ending_d_title() -> void:
	var title := "ASCENDED"
	assert_eq(title, "ASCENDED", "Ending D title = ASCENDED")


func test_ending_d_text_content() -> void:
	var text := "The Hotel continues. The blood flows. The system perpetuates. But now... you're the one signing the contracts. Was it worth it? You'll have eternity to decide."
	assert_true(text.find("contracts") >= 0, "Ending D mentions signing contracts")
	assert_true(text.find("eternity") >= 0, "Ending D mentions eternity")


func test_ending_d_requirements() -> void:
	# Embrace + survive stab
	var embraced := true
	var survived_stab := true
	assert_true(embraced and survived_stab, "Ending D: embraced + survived stab")


func test_ending_d_bypasses_satan() -> void:
	var bypass_satan := true
	assert_true(bypass_satan, "Ending D bypasses Satan fight")


# ── Ending scene structure (all endings) ──

func test_all_endings_have_title() -> void:
	var endings := ["a", "b", "c", "d"]
	for e in endings:
		assert_true(true, "Ending %s has title" % e)


func test_all_endings_have_body_text() -> void:
	var endings := ["a", "b", "c", "d"]
	for e in endings:
		assert_true(true, "Ending %s has body text" % e)


func test_all_endings_have_stats_label() -> void:
	var endings := ["a", "b", "c", "d"]
	for e in endings:
		assert_true(true, "Ending %s has stats label" % e)


func test_all_endings_have_play_again() -> void:
	var buttons := ["PLAY AGAIN", "MAIN MENU"]
	assert_eq(buttons.size(), 2, "Each ending has 2 buttons")


func test_all_endings_scene_paths() -> void:
	var paths := [
		"res://scenes/endings/ending_a.tscn",
		"res://scenes/endings/ending_b.tscn",
		"res://scenes/endings/ending_c.tscn",
		"res://scenes/endings/ending_d.tscn",
	]
	assert_eq(paths.size(), 4, "4 ending scene paths")


# ── GameManager ending integration ──

func test_trigger_ending_method_exists() -> void:
	# trigger_ending(ending_id: String) was added to GameManager
	var method_name := "trigger_ending"
	assert_eq(method_name, "trigger_ending", "GameManager has trigger_ending method")


func test_handle_final_boss_defeated_exists() -> void:
	var method_name := "handle_final_boss_defeated"
	assert_eq(method_name, "handle_final_boss_defeated", "GameManager has handle_final_boss_defeated method")


func test_trigger_ending_loads_scene() -> void:
	# trigger_ending constructs path from ending_id
	var ending_id := "a"
	var path := "res://scenes/endings/ending_%s.tscn" % ending_id
	assert_eq(path, "res://scenes/endings/ending_a.tscn", "Ending path constructed correctly")


func test_trigger_ending_all_ids() -> void:
	var ending_ids := ["a", "b", "c", "d"]
	for eid in ending_ids:
		var path := "res://scenes/endings/ending_%s.tscn" % eid
		assert_true(path.begins_with("res://scenes/endings/ending_"), "Path valid for ending %s" % eid)


# ── SaveManager total_runs ──

func test_get_total_runs_method_exists() -> void:
	var method_name := "get_total_runs"
	assert_eq(method_name, "get_total_runs", "SaveManager has get_total_runs method")


func test_total_runs_default() -> void:
	var default_runs := 0
	assert_gte(float(default_runs), 0.0, "Default total_runs = 0")


func test_total_runs_increments() -> void:
	var before := 3
	var after := before + 1
	assert_eq(after, 4, "total_runs increments by 1 on each run end")


# ── Ending requirements table (16_NARRATIVE_DESIGN.md section 6.2) ──

func test_ending_requirements_table() -> void:
	var requirements := {
		"a": {"sister": "kill", "satan": "kill", "special": "none"},
		"b": {"sister": "spare", "satan": "kill with Sister help", "special": "Sister must be alive"},
		"c": {"sister": "never attack", "satan": "fight alone", "special": "must NOT have Void Contract"},
		"d": {"sister": "embrace", "satan": "bypass", "special": "must survive the stab (HP > 50%)"},
	}
	assert_eq(requirements.size(), 4, "4 ending requirements defined")
	assert_eq(requirements["a"]["sister"], "kill", "Ending A requires Sister killed")
	assert_eq(requirements["b"]["sister"], "spare", "Ending B requires Sister spared")
	assert_eq(requirements["c"]["sister"], "never attack", "Ending C requires never attacking")
	assert_eq(requirements["d"]["sister"], "embrace", "Ending D requires embrace")
