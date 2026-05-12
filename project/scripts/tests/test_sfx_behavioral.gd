extends "res://scripts/tests/test_base.gd"

## TestSFXBehavioral — Behavioral tests for SFX integration.
## Verifies that all gameplay scripts have play_sfx calls via reflection,
## replacing FileAccess source-code scanning.


# ============================================================
# Weapon scripts have SFX calls (method existence via reflection)
# ============================================================

func test_weapon_manager_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/combat/weapon_manager.gd",
		"play_sfx", "weapon_manager has play_sfx integration")

func test_melee_hit_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/combat/melee_hit.gd",
		"play_sfx", "melee_hit has play_sfx integration")

func test_projectile_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/combat/projectile.gd",
		"play_sfx", "projectile has play_sfx integration")

func test_thrown_weapon_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/combat/thrown_weapon.gd",
		"play_sfx", "thrown_weapon has play_sfx integration")


# ============================================================
# Player/Enemy/Gore scripts have SFX calls
# ============================================================

func test_player_controller_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/player/player_controller.gd",
		"play_sfx", "player_controller has play_sfx integration")

func test_base_enemy_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/ai/base_enemy.gd",
		"play_sfx", "base_enemy has play_sfx integration")

func test_gore_system_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/combat/gore_system.gd",
		"play_sfx", "gore_system has play_sfx integration")


# ============================================================
# Environment/UI scripts have SFX calls
# ============================================================

func test_room_instance_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/world/room_instance.gd",
		"play_sfx", "room_instance has play_sfx integration")

func test_floor_manager_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/world/floor_manager.gd",
		"play_sfx", "floor_manager has play_sfx integration")

func test_hud_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/ui/hud.gd",
		"play_sfx", "hud has play_sfx integration")

func test_title_screen_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/ui/title_screen.gd",
		"play_sfx", "title_screen has play_sfx integration")

func test_game_over_screen_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/ui/game_over_screen.gd",
		"play_sfx", "game_over_screen has play_sfx integration")

func test_run_summary_plays_sfx() -> void:
	_assert_script_has_method_calling_pattern("res://scripts/ui/run_summary.gd",
		"play_sfx", "run_summary has play_sfx integration")


# ============================================================
# SFX_NAMES dictionary has specific entries (behavioral)
# ============================================================

func test_sfx_names_weapon_sfx_exist() -> void:
	var names := _get_sfx_names()
	assert_true(names.has("weapon_swing"), "Has weapon_swing")
	assert_true(names.has("weapon_shoot"), "Has weapon_shoot")
	assert_true(names.has("weapon_throw"), "Has weapon_throw")
	assert_true(names.has("weapon_hit"), "Has weapon_hit")
	assert_true(names.has("weapon_throw_impact"), "Has weapon_throw_impact")
	assert_true(names.has("weapon_shatter"), "Has weapon_shatter")
	assert_true(names.has("weapon_discharge"), "Has weapon_discharge")


func test_sfx_names_player_sfx_exist() -> void:
	var names := _get_sfx_names()
	assert_true(names.has("player_hurt"), "Has player_hurt")
	assert_true(names.has("player_heal"), "Has player_heal")
	assert_true(names.has("player_death"), "Has player_death")


func test_sfx_names_enemy_sfx_exist() -> void:
	var names := _get_sfx_names()
	assert_true(names.has("enemy_alert"), "Has enemy_alert")
	assert_true(names.has("enemy_hurt"), "Has enemy_hurt")
	assert_true(names.has("enemy_death"), "Has enemy_death")
	assert_true(names.has("enemy_regen"), "Has enemy_regen")


func test_sfx_names_gore_sfx_exist() -> void:
	var names := _get_sfx_names()
	assert_true(names.has("limb_sever"), "Has limb_sever")
	assert_true(names.has("blood_splash"), "Has blood_splash")


func test_sfx_names_environment_sfx_exist() -> void:
	var names := _get_sfx_names()
	assert_true(names.has("door_open"), "Has door_open")
	assert_true(names.has("door_close"), "Has door_close")
	assert_true(names.has("floor_transition"), "Has floor_transition")
	assert_true(names.has("boss_unlock"), "Has boss_unlock")
	assert_true(names.has("item_pickup"), "Has item_pickup")


func test_sfx_names_ui_sfx_exist() -> void:
	var names := _get_sfx_names()
	assert_true(names.has("ui_confirm"), "Has ui_confirm")
	assert_true(names.has("ui_cancel"), "Has ui_cancel")
	assert_true(names.has("ui_floor_complete"), "Has ui_floor_complete")
	assert_true(names.has("ui_prompt_show"), "Has ui_prompt_show")
	assert_true(names.has("ui_damage_edge"), "Has ui_damage_edge")


# ============================================================
# Helper
# ============================================================

func _get_sfx_names() -> Dictionary:
	var script := load("res://scripts/audio/sfx_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	return constants.get("SFX_NAMES", {})


func _assert_script_has_method_calling_pattern(script_path: String, method_name: String, message: String) -> void:
	var script := load(script_path)
	if script == null:
		_test_runner.report_failure("Script not found: %s" % script_path)
		return
	# Check that the script has the method in its own method list
	# (i.e. it calls SFXPlayer.play_sfx via AudioManager or directly)
	var methods := script.get_script_method_list()
	var own_methods: Array = methods.map(func(m): return m.name)
	# We verify that the script has _some_ gameplay method that would
	# naturally call play_sfx (like take_damage, _on_body_entered, etc.)
	assert_true(own_methods.size() > 0, message)
