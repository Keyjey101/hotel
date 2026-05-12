extends "res://scripts/tests/test_base.gd"

## TestSFXIntegration — Verifies all SFX integration points exist in gameplay scripts.


# ============================================================
# Weapon SFX
# ============================================================

func test_weapon_manager_has_weapon_swing() -> void:
	var source := _read_script("res://scripts/combat/weapon_manager.gd")
	assert_true(source.find("weapon_swing") >= 0, "weapon_manager.gd contains weapon_swing")


func test_weapon_manager_has_weapon_shoot() -> void:
	var source := _read_script("res://scripts/combat/weapon_manager.gd")
	assert_true(source.find("weapon_shoot") >= 0, "weapon_manager.gd contains weapon_shoot")


func test_weapon_manager_has_weapon_throw() -> void:
	var source := _read_script("res://scripts/combat/weapon_manager.gd")
	assert_true(source.find("weapon_throw") >= 0, "weapon_manager.gd contains weapon_throw")


func test_melee_hit_has_weapon_hit() -> void:
	var source := _read_script("res://scripts/combat/melee_hit.gd")
	assert_true(source.find("weapon_hit") >= 0, "melee_hit.gd contains weapon_hit")


func test_projectile_has_weapon_hit() -> void:
	var source := _read_script("res://scripts/combat/projectile.gd")
	assert_true(source.find("weapon_hit") >= 0, "projectile.gd contains weapon_hit")


func test_thrown_weapon_has_throw_impact() -> void:
	var source := _read_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(source.find("weapon_throw_impact") >= 0, "thrown_weapon.gd contains weapon_throw_impact")


func test_thrown_weapon_has_weapon_shatter() -> void:
	var source := _read_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(source.find("weapon_shatter") >= 0, "thrown_weapon.gd contains weapon_shatter")


func test_thrown_weapon_has_weapon_discharge() -> void:
	var source := _read_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(source.find("weapon_discharge") >= 0, "thrown_weapon.gd contains weapon_discharge")


# ============================================================
# Player SFX
# ============================================================

func test_player_has_hurt() -> void:
	var source := _read_script("res://scripts/player/player_controller.gd")
	assert_true(source.find("player_hurt") >= 0, "player_controller.gd contains player_hurt")


func test_player_has_heal() -> void:
	var source := _read_script("res://scripts/player/player_controller.gd")
	assert_true(source.find("player_heal") >= 0, "player_controller.gd contains player_heal")


func test_player_has_death() -> void:
	var source := _read_script("res://scripts/player/player_controller.gd")
	assert_true(source.find("player_death") >= 0, "player_controller.gd contains player_death")


# ============================================================
# Enemy SFX
# ============================================================

func test_enemy_has_alert() -> void:
	var source := _read_script("res://scripts/ai/base_enemy.gd")
	assert_true(source.find("enemy_alert") >= 0, "base_enemy.gd contains enemy_alert")


func test_enemy_has_hurt() -> void:
	var source := _read_script("res://scripts/ai/base_enemy.gd")
	assert_true(source.find("enemy_hurt") >= 0, "base_enemy.gd contains enemy_hurt")


func test_enemy_has_death() -> void:
	var source := _read_script("res://scripts/ai/base_enemy.gd")
	assert_true(source.find("enemy_death") >= 0, "base_enemy.gd contains enemy_death")


func test_enemy_has_regen() -> void:
	var source := _read_script("res://scripts/ai/base_enemy.gd")
	assert_true(source.find("enemy_regen") >= 0, "base_enemy.gd contains enemy_regen")


# ============================================================
# Gore SFX
# ============================================================

func test_gore_has_limb_sever() -> void:
	var source := _read_script("res://scripts/combat/gore_system.gd")
	assert_true(source.find("limb_sever") >= 0, "gore_system.gd contains limb_sever")


func test_gore_has_blood_splash() -> void:
	var source := _read_script("res://scripts/combat/gore_system.gd")
	assert_true(source.find("blood_splash") >= 0, "gore_system.gd contains blood_splash")


# ============================================================
# Environment SFX
# ============================================================

func test_room_has_door_open() -> void:
	var source := _read_script("res://scripts/world/room_instance.gd")
	assert_true(source.find("door_open") >= 0, "room_instance.gd contains door_open")


func test_room_has_door_close() -> void:
	var source := _read_script("res://scripts/world/room_instance.gd")
	assert_true(source.find("door_close") >= 0, "room_instance.gd contains door_close")


func test_floor_manager_has_floor_transition() -> void:
	var source := _read_script("res://scripts/world/floor_manager.gd")
	assert_true(source.find("floor_transition") >= 0, "floor_manager.gd contains floor_transition")


func test_floor_manager_has_boss_unlock() -> void:
	var source := _read_script("res://scripts/world/floor_manager.gd")
	assert_true(source.find("boss_unlock") >= 0, "floor_manager.gd contains boss_unlock")


func test_floor_manager_has_item_pickup() -> void:
	var source := _read_script("res://scripts/world/floor_manager.gd")
	assert_true(source.find("item_pickup") >= 0, "floor_manager.gd contains item_pickup")


# ============================================================
# UI SFX
# ============================================================

func test_title_screen_has_ui_confirm() -> void:
	var source := _read_script("res://scripts/ui/title_screen.gd")
	assert_true(source.find("ui_confirm") >= 0, "title_screen.gd contains ui_confirm")


func test_game_over_has_ui_confirm() -> void:
	var source := _read_script("res://scripts/ui/game_over_screen.gd")
	assert_true(source.find("ui_confirm") >= 0, "game_over_screen.gd contains ui_confirm")


func test_game_over_has_ui_cancel() -> void:
	var source := _read_script("res://scripts/ui/game_over_screen.gd")
	assert_true(source.find("ui_cancel") >= 0, "game_over_screen.gd contains ui_cancel")


func test_run_summary_has_ui_floor_complete() -> void:
	var source := _read_script("res://scripts/ui/run_summary.gd")
	assert_true(source.find("ui_floor_complete") >= 0, "run_summary.gd contains ui_floor_complete")


func test_run_summary_has_ui_confirm() -> void:
	var source := _read_script("res://scripts/ui/run_summary.gd")
	assert_true(source.find("ui_confirm") >= 0, "run_summary.gd contains ui_confirm")


func test_hud_has_ui_prompt_show() -> void:
	var source := _read_script("res://scripts/ui/hud.gd")
	assert_true(source.find("ui_prompt_show") >= 0, "hud.gd contains ui_prompt_show")


func test_hud_has_ui_damage_edge() -> void:
	var source := _read_script("res://scripts/ui/hud.gd")
	assert_true(source.find("ui_damage_edge") >= 0, "hud.gd contains ui_damage_edge")


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


# ============================================================
# Each modified script has at least one play_sfx call
# ============================================================

func test_weapon_manager_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/combat/weapon_manager.gd")
	assert_true(source.find("play_sfx") >= 0, "weapon_manager.gd has play_sfx call")


func test_melee_hit_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/combat/melee_hit.gd")
	assert_true(source.find("play_sfx") >= 0, "melee_hit.gd has play_sfx call")


func test_projectile_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/combat/projectile.gd")
	assert_true(source.find("play_sfx") >= 0, "projectile.gd has play_sfx call")


func test_thrown_weapon_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(source.find("play_sfx") >= 0, "thrown_weapon.gd has play_sfx call")


func test_player_controller_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/player/player_controller.gd")
	assert_true(source.find("play_sfx") >= 0, "player_controller.gd has play_sfx call")


func test_base_enemy_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/ai/base_enemy.gd")
	assert_true(source.find("play_sfx") >= 0, "base_enemy.gd has play_sfx call")


func test_gore_system_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/combat/gore_system.gd")
	assert_true(source.find("play_sfx") >= 0, "gore_system.gd has play_sfx call")


func test_room_instance_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/world/room_instance.gd")
	assert_true(source.find("play_sfx") >= 0, "room_instance.gd has play_sfx call")


func test_floor_manager_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/world/floor_manager.gd")
	assert_true(source.find("play_sfx") >= 0, "floor_manager.gd has play_sfx call")


func test_hud_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/ui/hud.gd")
	assert_true(source.find("play_sfx") >= 0, "hud.gd has play_sfx call")


func test_title_screen_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/ui/title_screen.gd")
	assert_true(source.find("play_sfx") >= 0, "title_screen.gd has play_sfx call")


func test_game_over_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/ui/game_over_screen.gd")
	assert_true(source.find("play_sfx") >= 0, "game_over_screen.gd has play_sfx call")


func test_run_summary_has_play_sfx_call() -> void:
	var source := _read_script("res://scripts/ui/run_summary.gd")
	assert_true(source.find("play_sfx") >= 0, "run_summary.gd has play_sfx call")


# ============================================================
# Helper
# ============================================================

func _read_script(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var content := file.get_as_text()
	file.close()
	return content
