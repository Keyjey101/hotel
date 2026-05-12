extends "res://scripts/tests/test_base.gd"

## TestBalanceAudit — M8.4: Verifies that code values match documentation.
## Documentation = source of truth. All tests check code values against
## 11_ENEMY_DESIGN.md, 12_WEAPON_DESIGN.md, 14_BOSS_DESIGN.md, 15_UPGRADE_DESIGN.md.


# ==========================================================================
# ENEMY STATS — 11_ENEMY_DESIGN.md
# ==========================================================================

func test_staff_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "torso_hp", 40.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "head_hp", 15.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "arm_hp", 12.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "leg_hp", 14.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "move_speed", 120.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "detection_range", 200.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "attack_damage", 10.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "attack_speed", 1.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "grab_strength", 2.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "regen_speed_mult", 1.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "aggression", 3.0)
	_assert_script_val("res://scripts/ai/enemy_staff.gd", "coordination", 2.0)


func test_guard_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "torso_hp", 70.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "head_hp", 25.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "arm_hp", 20.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "leg_hp", 22.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "move_speed", 140.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "detection_range", 280.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "attack_damage", 18.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "attack_speed", 0.8)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "grab_strength", 7.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "regen_speed_mult", 0.9)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "aggression", 6.0)
	_assert_script_val("res://scripts/ai/enemy_guard.gd", "coordination", 8.0)


func test_handler_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "torso_hp", 90.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "head_hp", 30.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "arm_hp", 30.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "leg_hp", 25.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "move_speed", 80.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "detection_range", 180.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "attack_damage", 25.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "attack_speed", 0.5)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "grab_strength", 10.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "regen_speed_mult", 0.7)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "aggression", 5.0)
	_assert_script_val("res://scripts/ai/enemy_handler.gd", "coordination", 4.0)


func test_seductress_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_seductress.gd", "torso_hp", 35.0)
	_assert_script_val("res://scripts/ai/enemy_seductress.gd", "move_speed", 130.0)
	_assert_script_val("res://scripts/ai/enemy_seductress.gd", "grab_strength", 5.0)
	_assert_script_val("res://scripts/ai/enemy_seductress.gd", "aggression", 2.0)
	_assert_script_val("res://scripts/ai/enemy_seductress.gd", "coordination", 7.0)


func test_bodyguard_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_bodyguard.gd", "torso_hp", 100.0)
	_assert_script_val("res://scripts/ai/enemy_bodyguard.gd", "move_speed", 110.0)
	_assert_script_val("res://scripts/ai/enemy_bodyguard.gd", "grab_strength", 8.0)
	_assert_script_val("res://scripts/ai/enemy_bodyguard.gd", "regen_speed_mult", 0.8)


func test_chef_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_chef.gd", "torso_hp", 75.0)
	_assert_script_val("res://scripts/ai/enemy_chef.gd", "attack_damage", 35.0)
	_assert_script_val("res://scripts/ai/enemy_chef.gd", "regen_speed_mult", 1.0)
	_assert_script_val("res://scripts/ai/enemy_chef.gd", "aggression", 7.0)


func test_taster_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_taster.gd", "torso_hp", 45.0)
	_assert_script_val("res://scripts/ai/enemy_taster.gd", "move_speed", 150.0)
	_assert_script_val("res://scripts/ai/enemy_taster.gd", "regen_speed_mult", 1.4)


func test_banker_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_banker.gd", "torso_hp", 50.0)
	_assert_script_val("res://scripts/ai/enemy_banker.gd", "coordination", 9.0)
	_assert_script_val("res://scripts/ai/enemy_banker.gd", "grab_strength", 1.0)


func test_vault_drone_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_vault_drone.gd", "torso_hp", 60.0)
	_assert_script_val("res://scripts/ai/enemy_vault_drone.gd", "move_speed", 160.0)
	_assert_script_val("res://scripts/ai/enemy_vault_drone.gd", "grab_strength", 0.0)
	_assert_script_val("res://scripts/ai/enemy_vault_drone.gd", "regen_speed_mult", 0.5)


func test_attendant_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_attendant.gd", "torso_hp", 55.0)
	_assert_script_val("res://scripts/ai/enemy_attendant.gd", "move_speed", 70.0)
	_assert_script_val("res://scripts/ai/enemy_attendant.gd", "grab_strength", 5.0)


func test_drowned_one_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_drowned_one.gd", "torso_hp", 65.0)
	_assert_script_val("res://scripts/ai/enemy_drowned_one.gd", "move_speed", 60.0)
	_assert_script_val("res://scripts/ai/enemy_drowned_one.gd", "grab_strength", 8.0)


func test_gladiator_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_gladiator.gd", "torso_hp", 110.0)
	_assert_script_val("res://scripts/ai/enemy_gladiator.gd", "move_speed", 130.0)
	_assert_script_val("res://scripts/ai/enemy_gladiator.gd", "aggression", 8.0)


func test_berserker_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_berserker.gd", "torso_hp", 90.0)
	_assert_script_val("res://scripts/ai/enemy_berserker.gd", "move_speed", 140.0)
	_assert_script_val("res://scripts/ai/enemy_berserker.gd", "aggression", 10.0)
	_assert_script_val("res://scripts/ai/enemy_berserker.gd", "coordination", 0.0)


func test_spy_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_spy.gd", "torso_hp", 40.0)
	_assert_script_val("res://scripts/ai/enemy_spy.gd", "move_speed", 160.0)
	_assert_script_val("res://scripts/ai/enemy_spy.gd", "regen_speed_mult", 1.3)


func test_shadow_stalker_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_shadow_stalker.gd", "torso_hp", 60.0)
	_assert_script_val("res://scripts/ai/enemy_shadow_stalker.gd", "move_speed", 120.0)
	_assert_script_val("res://scripts/ai/enemy_shadow_stalker.gd", "grab_strength", 6.0)


func test_royal_guard_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_royal_guard.gd", "torso_hp", 100.0)
	_assert_script_val("res://scripts/ai/enemy_royal_guard.gd", "move_speed", 130.0)
	_assert_script_val("res://scripts/ai/enemy_royal_guard.gd", "coordination", 10.0)


func test_champion_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_champion.gd", "torso_hp", 130.0)
	_assert_script_val("res://scripts/ai/enemy_champion.gd", "move_speed", 140.0)
	_assert_script_val("res://scripts/ai/enemy_champion.gd", "attack_range", 65.0)
	_assert_script_val("res://scripts/ai/enemy_champion.gd", "attack_speed", 0.5)


func test_demon_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_demon.gd", "torso_hp", 120.0)
	_assert_script_val("res://scripts/ai/enemy_demon.gd", "move_speed", 150.0)
	_assert_script_val("res://scripts/ai/enemy_demon.gd", "grab_strength", 0.0)
	_assert_script_val("res://scripts/ai/enemy_demon.gd", "regen_speed_mult", 1.5)


# ==========================================================================
# BOSS STATS — 14_BOSS_DESIGN.md
# ==========================================================================

func test_head_chef_stats() -> void:
	_assert_script_val("res://scripts/ai/enemy_head_chef.gd", "torso_hp", 300.0)
	_assert_script_val("res://scripts/ai/enemy_head_chef.gd", "head_hp", 60.0)
	_assert_script_val("res://scripts/ai/enemy_head_chef.gd", "arm_hp", 80.0)
	_assert_script_val("res://scripts/ai/enemy_head_chef.gd", "leg_hp", 70.0)
	_assert_script_val("res://scripts/ai/enemy_head_chef.gd", "move_speed", 90.0)
	_assert_script_val("res://scripts/ai/enemy_head_chef.gd", "regen_speed_mult", 0.7)


func test_satan_phase1_stats() -> void:
	_assert_script_val("res://scripts/ai/boss_satan.gd", "_phase_1_hp", 400.0, "_phase_1_hp")
	_assert_script_val("res://scripts/ai/boss_satan.gd", "move_speed", 120.0)
	_assert_script_val("res://scripts/ai/boss_satan.gd", "regen_speed_mult", 1.0)


# ==========================================================================
# WEAPON DATA — 12_WEAPON_DESIGN.md
# ==========================================================================

func test_machete_data() -> void:
	var w: WeaponData = load("res://resources/weapons/melee_machete.tres")
	assert_eq(w.damage, 20.0, "Machete damage 20")
	assert_eq(w.limb_damage_multiplier, 1.5, "Machete limb_mult 1.5")
	assert_eq(w.sever_chance, 0.25, "Machete sever 25%")

func test_knife_data() -> void:
	var w: WeaponData = load("res://resources/weapons/melee_knife.tres")
	assert_eq(w.damage, 10.0, "Knife damage 10")
	assert_eq(w.limb_damage_multiplier, 2.0, "Knife limb_mult 2.0")
	assert_eq(w.attack_speed, 0.1, "Knife attack_speed fastest melee")

func test_axe_data() -> void:
	var w: WeaponData = load("res://resources/weapons/melee_axe.tres")
	assert_eq(w.damage, 35.0, "Axe damage 35 (highest melee)")
	assert_eq(w.sever_chance, 0.5, "Axe sever 50%")

func test_sawed_off_data() -> void:
	var w: WeaponData = load("res://resources/weapons/ranged_sawed_off.tres")
	assert_eq(w.ammo, 4, "Sawed-off ammo 4")
	assert_eq(w.projectile_count, 5, "Sawed-off 5 pellets")

func test_shotgun_data() -> void:
	var w: WeaponData = load("res://resources/weapons/ranged_shotgun.tres")
	assert_eq(w.ammo, 6, "Shotgun ammo 6")
	assert_eq(w.projectile_count, 8, "Shotgun 8 pellets")
	assert_eq(w.knockback, 70.0, "Shotgun knockback 70 (highest ranged)")

func test_cult_relic_data() -> void:
	var w: WeaponData = load("res://resources/weapons/improvised_cult_relic.tres")
	assert_eq(w.damage, 40.0, "Cult Relic damage 40")
	assert_eq(w.limb_damage_multiplier, 3.0, "Cult Relic limb_mult 3.0")
	assert_eq(w.sever_chance, 0.8, "Cult Relic sever 80%")
	assert_eq(w.ammo, 1, "Cult Relic single use")

func test_cult_pistol_piercing() -> void:
	var w: WeaponData = load("res://resources/weapons/ranged_cult_pistol.tres")
	assert_eq(w.piercing, true, "Cult Pistol piercing true")
	assert_eq(w.ammo, 8, "Cult Pistol ammo 8")

func test_wire_data() -> void:
	var w: WeaponData = load("res://resources/weapons/improvised_wire.tres")
	assert_eq(w.damage, 5.0, "Wire damage 5 (initial)")
	assert_eq(w.knockback, 0.0, "Wire knockback 0")

func test_bottle_data() -> void:
	var w: WeaponData = load("res://resources/weapons/improvised_bottle.tres")
	assert_eq(w.sever_chance, 0.0, "Bottle sever 0%")
	assert_eq(w.throw_effect, "shatter", "Bottle throw shatter")

func test_chair_data() -> void:
	var w: WeaponData = load("res://resources/weapons/improvised_chair.tres")
	assert_eq(w.knockback, 45.0, "Chair knockback 45")
	assert_eq(w.throw_effect, "barricade", "Chair throw barricade")


# ==========================================================================
# LOOT WEIGHTS — 12_WEAPON_DESIGN.md §7.2
# ==========================================================================

func test_loot_weights_common() -> void:
	var weights = LootSpawner.WEAPON_WEIGHTS
	assert_eq(weights.get("knife", 0), 10, "Knife weight 10 (common)")
	assert_eq(weights.get("pistol", 0), 10, "Pistol weight 10 (common)")
	assert_eq(weights.get("bottle", 0), 10, "Bottle weight 10 (common)")

func test_loot_weights_uncommon() -> void:
	var weights = LootSpawner.WEAPON_WEIGHTS
	assert_eq(weights.get("machete", 0), 5, "Machete weight 5 (uncommon)")
	assert_eq(weights.get("bat", 0), 5, "Bat weight 5 (uncommon)")
	assert_eq(weights.get("smg", 0), 5, "SMG weight 5 (uncommon)")
	assert_eq(weights.get("wire", 0), 5, "Wire weight 5 (uncommon)")

func test_loot_weights_rare() -> void:
	var weights = LootSpawner.WEAPON_WEIGHTS
	assert_eq(weights.get("axe", 0), 3, "Axe weight 3 (rare)")
	assert_eq(weights.get("shotgun", 0), 3, "Shotgun weight 3 (rare)")
	assert_eq(weights.get("chair", 0), 3, "Chair weight 3 (rare)")

func test_loot_weights_very_rare() -> void:
	var weights = LootSpawner.WEAPON_WEIGHTS
	assert_eq(weights.get("cult_blade", 0), 1, "Cult Blade weight 1 (very rare)")
	assert_eq(weights.get("cult_pistol", 0), 1, "Cult Pistol weight 1 (very rare)")

func test_loot_weights_ultra_rare() -> void:
	var weights = LootSpawner.WEAPON_WEIGHTS
	assert_eq(weights.get("cult_relic", 0), 0.5, "Cult Relic weight 0.5 (ultra rare)")


# ==========================================================================
# STAT UPGRADES — 15_UPGRADE_DESIGN.md §2.1
# ==========================================================================

func test_stat_upgrade_vitality() -> void:
	var rs = _make_run_state()
	var old_hp = rs.player_max_hp
	rs.apply_stat_upgrade("max_hp", 25.0)
	assert_eq(rs.player_max_hp, old_hp + 25.0, "S1 Vitality +25 HP")

func test_stat_upgrade_speed() -> void:
	var rs = _make_run_state()
	var old_speed = rs.player_speed
	rs.apply_stat_upgrade("speed", 0.12)
	assert_eq(rs.player_speed, old_speed * 1.12, "S2 Swift Step +12% speed")

func test_stat_upgrade_stacking() -> void:
	var rs = _make_run_state()
	var base_hp = rs.player_max_hp
	rs.apply_stat_upgrade("max_hp", 25.0)
	rs.apply_stat_upgrade("max_hp", 25.0)
	rs.apply_stat_upgrade("max_hp", 25.0)
	assert_eq(rs.player_max_hp, base_hp + 62.5, "S1 3-stack: 25+25+12.5=62.5")


# ==========================================================================
# ARTIFACTS — 15_UPGRADE_DESIGN.md §3.2
# ==========================================================================

func test_artifact_base_weapon_slots() -> void:
	var rs = _make_run_state()
	assert_eq(rs.weapon_slots.size(), 2, "Base weapon slots = 2")


# ==========================================================================
# Helper — parse script source to extract numeric values
# ==========================================================================

var _script_cache: Dictionary = {}

func _get_script_source(path: String) -> String:
	if not _script_cache.has(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file == null:
			return ""
		_script_cache[path] = file.get_as_text()
		file.close()
	return _script_cache[path]


func _assert_script_val(path: String, prop: String, expected: float, var_name: String = "") -> void:
	var source = _get_script_source(path)
	if source == "":
		_test_runner.report_failure("Cannot read script: " + path)
		return

	var search_name = var_name if var_name != "" else prop
	# Match: prop_name = value  or  var prop_name: type = value
	# Look for the assignment pattern
	var pattern = search_name + " = "
	var idx = source.find(pattern)
	if idx == -1:
		# Try with typed declaration: var_name: type = value
		var typed_pattern = search_name + ":"
		idx = source.find(typed_pattern)
		if idx == -1:
			_test_runner.report_failure("%s: property '%s' not found in %s" % [path.get_file(), prop, path])
			return
		# Find the '=' after the type
		var rest = source.substr(idx)
		var eq_idx = rest.find(" = ")
		if eq_idx == -1:
			_test_runner.report_failure("%s: property '%s' has no assignment" % [path.get_file(), prop])
			return
		pattern = rest.substr(eq_idx, 3)
		idx += eq_idx

	# Extract the numeric value after '='
	var after = source.substr(idx + pattern.length())
	var val_str = ""
	for c in after:
		if c == '.' or c == '-' or (c >= '0' and c <= '9'):
			val_str += c
		else:
			break

	var actual = float(val_str)
	var label = "%s %s" % [path.get_file().replace(".gd", ""), prop]
	assert_eq(actual, expected, label)


func _make_run_state() -> Object:
	var script = load("res://scripts/core/run_state.gd")
	var instance = script.new()
	return instance
