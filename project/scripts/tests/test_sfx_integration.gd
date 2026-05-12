extends "res://scripts/tests/test_base.gd"

## TestSFXIntegration — Verifies SFX integration completeness.
## String-based source code checks replaced by behavioral tests in
## test_sfx_behavioral.gd.


# ============================================================
# SFX_NAMES completeness
# ============================================================

func test_sfx_names_has_all_m82_names() -> void:
	var script := load("res://scripts/audio/sfx_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	var names: Dictionary = constants["SFX_NAMES"]
	var expected := [
		# M8.1
		"weapon_swing", "weapon_hit", "weapon_throw",
		"enemy_alert", "enemy_hurt", "enemy_death", "enemy_regen", "enemy_grab",
		"limb_sever", "blood_splash",
		"player_hurt", "player_heal", "player_death",
		"door_open", "door_close", "item_pickup", "floor_transition",
		"ui_click", "ui_confirm", "ui_cancel", "ui_pause",
		# M8.2
		"weapon_shoot", "weapon_throw_impact", "weapon_shatter", "weapon_discharge",
		"boss_unlock", "ui_prompt_show", "ui_damage_edge", "ui_floor_complete",
	]
	for name in expected:
		assert_true(names.has(name), "SFX_NAMES has %s" % name)


func test_sfx_names_count() -> void:
	var script := load("res://scripts/audio/sfx_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	var names: Dictionary = constants["SFX_NAMES"]
	assert_gte(names.size(), 29, "SFX_NAMES has >= 29 entries (21 from M8.1 + 8 new)")
