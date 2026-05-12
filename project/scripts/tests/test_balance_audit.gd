extends "res://scripts/tests/test_base.gd"

## TestBalanceAudit — M8.4: Verifies that code values match documentation.
## Documentation = source of truth. All tests check code values against
## 12_WEAPON_DESIGN.md and 15_UPGRADE_DESIGN.md.
## Enemy stat tests moved to test_enemy_stats_behavioral.gd.


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
# Helper
# ==========================================================================

func _make_run_state() -> Object:
	var script = load("res://scripts/core/run_state.gd")
	var instance = script.new()
	return instance
