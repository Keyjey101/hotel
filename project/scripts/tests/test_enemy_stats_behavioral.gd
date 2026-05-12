extends "res://scripts/tests/test_base.gd"

## TestEnemyStatsBehavioral — Loads real enemy scenes and verifies their stats.
## Replaces string-find assertions from test_balance_audit.gd.


func test_staff_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/staff.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 40.0, "Staff torso_hp = 40")
	assert_eq(enemy.get("move_speed"), 120.0, "Staff move_speed = 120")
	assert_eq(enemy.get("detection_range"), 200.0, "Staff detection_range = 200")
	assert_eq(enemy.get("attack_damage"), 10.0, "Staff attack_damage = 10")
	assert_eq(enemy.get("attack_speed"), 1.0, "Staff attack_speed = 1.0")
	assert_eq(enemy.get("aggression"), 3.0, "Staff aggression = 3")


func test_guard_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/guard.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 70.0, "Guard torso_hp = 70")
	assert_eq(enemy.get("move_speed"), 140.0, "Guard move_speed = 140")
	assert_eq(enemy.get("attack_damage"), 18.0, "Guard attack_damage = 18")
	assert_eq(enemy.get("grab_strength"), 7.0, "Guard grab_strength = 7")


func test_handler_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/handler.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 90.0, "Handler torso_hp = 90")
	assert_eq(enemy.get("move_speed"), 80.0, "Handler move_speed = 80")
	assert_eq(enemy.get("attack_damage"), 25.0, "Handler attack_damage = 25")
	assert_eq(enemy.get("grab_strength"), 10.0, "Handler grab_strength = 10")


func test_seductress_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/seductress.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 35.0, "Seductress torso_hp = 35")
	assert_eq(enemy.get("move_speed"), 130.0, "Seductress move_speed = 130")
	assert_eq(enemy.get("aggression"), 2.0, "Seductress aggression = 2")


func test_bodyguard_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/bodyguard.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 100.0, "Bodyguard torso_hp = 100")
	assert_eq(enemy.get("move_speed"), 110.0, "Bodyguard move_speed = 110")
	assert_eq(enemy.get("grab_strength"), 8.0, "Bodyguard grab_strength = 8")


func test_chef_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/chef.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 75.0, "Chef torso_hp = 75")
	assert_eq(enemy.get("attack_damage"), 35.0, "Chef attack_damage = 35")
	assert_eq(enemy.get("aggression"), 7.0, "Chef aggression = 7")


func test_taster_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/taster.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 45.0, "Taster torso_hp = 45")
	assert_eq(enemy.get("move_speed"), 150.0, "Taster move_speed = 150")


func test_banker_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/banker.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 50.0, "Banker torso_hp = 50")
	assert_eq(enemy.get("coordination"), 9.0, "Banker coordination = 9")


func test_vault_drone_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/vault_drone.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 60.0, "VaultDrone torso_hp = 60")
	assert_eq(enemy.get("move_speed"), 160.0, "VaultDrone move_speed = 160")


func test_attendant_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/attendant.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 55.0, "Attendant torso_hp = 55")
	assert_eq(enemy.get("move_speed"), 70.0, "Attendant move_speed = 70")


func test_drowned_one_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/drowned_one.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 65.0, "DrownedOne torso_hp = 65")
	assert_eq(enemy.get("move_speed"), 60.0, "DrownedOne move_speed = 60")


func test_gladiator_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/gladiator.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 110.0, "Gladiator torso_hp = 110")
	assert_eq(enemy.get("move_speed"), 130.0, "Gladiator move_speed = 130")
	assert_eq(enemy.get("aggression"), 8.0, "Gladiator aggression = 8")


func test_berserker_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/berserker.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 90.0, "Berserker torso_hp = 90")
	assert_eq(enemy.get("move_speed"), 140.0, "Berserker move_speed = 140")
	assert_eq(enemy.get("aggression"), 10.0, "Berserker aggression = 10")
	assert_eq(enemy.get("coordination"), 0.0, "Berserker coordination = 0")


func test_spy_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/spy.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 40.0, "Spy torso_hp = 40")
	assert_eq(enemy.get("move_speed"), 160.0, "Spy move_speed = 160")


func test_shadow_stalker_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/shadow_stalker.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 60.0, "ShadowStalker torso_hp = 60")
	assert_eq(enemy.get("move_speed"), 120.0, "ShadowStalker move_speed = 120")


func test_royal_guard_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/royal_guard.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 100.0, "RoyalGuard torso_hp = 100")
	assert_eq(enemy.get("move_speed"), 130.0, "RoyalGuard move_speed = 130")
	assert_eq(enemy.get("coordination"), 10.0, "RoyalGuard coordination = 10")


func test_champion_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/champion.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 130.0, "Champion torso_hp = 130")
	assert_eq(enemy.get("move_speed"), 140.0, "Champion move_speed = 140")
	assert_eq(enemy.get("attack_range"), 65.0, "Champion attack_range = 65")
	assert_eq(enemy.get("attack_speed"), 0.5, "Champion attack_speed = 0.5")


func test_demon_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/enemies/demon.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 120.0, "Demon torso_hp = 120")
	assert_eq(enemy.get("move_speed"), 150.0, "Demon move_speed = 150")
	assert_eq(enemy.get("grab_strength"), 0.0, "Demon grab_strength = 0")


func test_head_chef_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/bosses/boss_gourmand.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("torso_hp"), 300.0, "HeadChef torso_hp = 300")
	assert_eq(enemy.get("head_hp"), 60.0, "HeadChef head_hp = 60")
	assert_eq(enemy.get("move_speed"), 90.0, "HeadChef move_speed = 90")


func test_satan_phase1_stats() -> void:
	var enemy := _instantiate_enemy("res://scenes/bosses/boss_satan.tscn")
	if not enemy:
		return
	assert_eq(enemy.get("move_speed"), 120.0, "Satan move_speed = 120")


func test_all_enemies_have_required_props() -> void:
	var scenes := [
		"res://scenes/enemies/staff.tscn",
		"res://scenes/enemies/guard.tscn",
		"res://scenes/enemies/handler.tscn",
	]
	var required_props := ["torso_hp", "head_hp", "arm_hp", "leg_hp", "move_speed", "attack_damage", "aggression"]
	for scene_path in scenes:
		var enemy := _instantiate_enemy(scene_path)
		if not enemy:
			continue
		for prop in required_props:
			assert_ne(enemy.get(prop), null, "%s has %s" % [scene_path.get_file().replace(".tscn", ""), prop])


# ============================================================
# Helper
# ============================================================

func _instantiate_enemy(scene_path: String) -> Node:
	if not ResourceLoader.exists(scene_path):
		_test_runner.report_failure("Scene not found: %s" % scene_path)
		return null
	var scene: PackedScene = load(scene_path)
	var instance := scene.instantiate()
	return instance
