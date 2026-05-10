extends "res://scripts/tests/test_base.gd"

## TestWeaponData — Tests for weapon definitions integrity and damage calculations.

var machete: WeaponData
var sawed_off: WeaponData
var knife: WeaponData
var bat: WeaponData
var pistol: WeaponData


func before_all() -> void:
	machete = load("res://resources/weapons/melee_machete.tres")
	sawed_off = load("res://resources/weapons/ranged_sawed_off.tres")
	knife = load("res://resources/weapons/melee_knife.tres")
	bat = load("res://resources/weapons/melee_bat.tres")
	pistol = load("res://resources/weapons/ranged_pistol.tres")


# === Machete ===

func test_machete_is_melee() -> void:
	assert_eq(machete.weapon_type, WeaponData.WeaponType.MELEE, "Machete is melee")

func test_machete_damage() -> void:
	assert_eq(machete.damage, 20.0, "Machete base damage 20")

func test_machete_limb_mult() -> void:
	assert_eq(machete.limb_damage_multiplier, 1.5, "Machete limb mult 1.5")

func test_machete_sever_chance() -> void:
	assert_eq(machete.sever_chance, 0.25, "Machete sever 25%")

func test_machete_infinite_ammo() -> void:
	assert_eq(machete.ammo, -1, "Melee has infinite ammo")

func test_machete_throw_damage() -> void:
	assert_eq(machete.throw_damage, 18.0, "Machete throw 18 dmg")


# === Sawed-off ===

func test_sawed_off_is_ranged() -> void:
	assert_eq(sawed_off.weapon_type, WeaponData.WeaponType.RANGED, "Sawed-off is ranged")

func test_sawed_off_ammo() -> void:
	assert_eq(sawed_off.ammo, 4, "Sawed-off has 4 shots")

func test_sawed_off_pellets() -> void:
	assert_eq(sawed_off.projectile_count, 5, "Sawed-off fires 5 pellets")

func test_sawed_off_spread() -> void:
	assert_gt(sawed_off.projectile_spread, 0.0, "Sawed-off has spread")

func test_sawed_off_close_range() -> void:
	assert_lt(sawed_off.attack_range, 150.0, "Sawed-off is close range")


# === Knife ===

func test_knife_fastest_melee() -> void:
	assert_lt(knife.attack_speed, machete.attack_speed, "Knife faster than machete")
	assert_lt(knife.attack_speed, bat.attack_speed, "Knife faster than bat")

func test_knife_low_damage_high_limb() -> void:
	assert_lt(knife.damage, machete.damage, "Knife less base damage than machete")
	assert_gt(knife.limb_damage_multiplier, machete.limb_damage_multiplier, "Knife better limb mult")

func test_knife_throw_fastest() -> void:
	assert_gt(knife.throw_speed, machete.throw_speed, "Knife throw faster than machete")
	assert_gt(knife.throw_speed, bat.throw_speed, "Knife throw faster than bat")


# === Bat ===

func test_bat_highest_knockback() -> void:
	assert_gt(bat.knockback, machete.knockback, "Bat more knockback than machete")
	assert_gt(bat.knockback, knife.knockback, "Bat more knockback than knife")

func test_bat_low_sever() -> void:
	assert_lt(bat.sever_chance, 0.1, "Bat barely severs")


# === Pistol ===

func test_pistol_ammo() -> void:
	assert_eq(pistol.ammo, 12, "Pistol has 12 shots")

func test_pistol_long_range() -> void:
	assert_gt(pistol.attack_range, 300.0, "Pistol is long range")

func test_pistol_single_projectile() -> void:
	assert_eq(pistol.projectile_count, 1, "Pistol single shot")


# === Cross-weapon consistency ===

func test_all_weapons_have_throw_stats() -> void:
	var weapons := [machete, sawed_off, knife, bat, pistol]
	for w in weapons:
		assert_gt(w.throw_damage, 0.0, "%s has throw damage" % w.name)
		assert_gt(w.throw_speed, 0.0, "%s has throw speed" % w.name)

func test_all_weapons_have_names() -> void:
	var weapons := [machete, sawed_off, knife, bat, pistol]
	for w in weapons:
		assert_ne(w.name, "", "%s has a name" % w.name)
		assert_ne(w.name, "Weapon", "%s has specific name" % w.name)

func test_ranged_weapons_have_ammo() -> void:
	assert_gt(sawed_off.ammo, 0, "Sawed-off has ammo")
	assert_gt(pistol.ammo, 0, "Pistol has ammo")

func test_melee_weapons_infinite_ammo() -> void:
	assert_eq(machete.ammo, -1, "Machete infinite")
	assert_eq(knife.ammo, -1, "Knife infinite")
	assert_eq(bat.ammo, -1, "Bat infinite")


# === Damage calculation tests ===

func test_limb_damage_calculation() -> void:
	# Machete: 20 dmg × 1.5 limb mult = 30 limb damage
	var limb_dmg := machete.damage * machete.limb_damage_multiplier
	assert_eq(limb_dmg, 30.0, "Machete does 30 to limbs")

func test_torso_damage_no_mult() -> void:
	# Torso uses base damage without limb mult
	assert_eq(machete.damage, 20.0, "Torso takes base damage")

func test_sawed_off_max_potential() -> void:
	# 25 dmg × 5 pellets = 125 potential total
	var max_total := sawed_off.damage * sawed_off.projectile_count
	assert_eq(max_total, 125.0, "Sawed-off max 125 total damage")
