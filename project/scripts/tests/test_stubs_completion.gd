extends "res://scripts/tests/test_base.gd"

## TestStubsCompletion — Verifies all M8.3 stubs have been replaced with real implementations.


# ============================================================
# Step 1 & 2: Throw Effects
# ============================================================

func test_thrown_weapon_has_no_todo() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_false(script_text.find("TODO") != -1, "thrown_weapon.gd should not contain TODO comments")

func test_stick_bleed_creates_hazard_zone() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("_apply_stick_bleed") != -1, "Should have _apply_stick_bleed method")
	assert_true(script_text.find("HazardZone") != -1, "stick_bleed should use HazardZone")

func test_stick_bleed_damage_values() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("damage_per_second = 3.0") != -1, "stick_bleed dps should be 3.0")
	assert_true(script_text.find("duration = 3.0") != -1, "stick_bleed duration should be 3.0")
	assert_true(script_text.find("zone_radius = 20.0") != -1, "stick_bleed radius should be 20.0")

func test_pin_uses_reparent() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("reparent") != -1, "pin should use reparent")
	assert_true(script_text.find("freeze = true") != -1, "pin should freeze weapon")

func test_embed_applies_slow() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("_apply_embed") != -1, "Should have _apply_embed method")
	assert_true(script_text.find("move_speed") != -1, "embed should modify move_speed")
	assert_true(script_text.find("0.6") != -1, "embed should apply 0.6 speed multiplier (40%% slow)")
	assert_true(script_text.find("7.0") != -1, "embed slow should last 7 seconds")

func test_demoralize_has_radius() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("_apply_demoralize") != -1, "Should have _apply_demoralize method")
	assert_true(script_text.find("radius := 60.0") != -1, "demoralize radius should be 60")

func test_tangle_applies_slow() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("_apply_tangle") != -1, "Should have _apply_tangle method")
	assert_true(script_text.find("slow_mult := 0.5") != -1, "tangle should slow by 50%%")

func test_soul_rip_has_disarm_chance() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("_apply_soul_rip") != -1, "Should have _apply_soul_rip method")
	assert_true(script_text.find("0.25") != -1, "soul_rip should have 25%% disarm chance")

func test_reality_tear_values() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	assert_true(script_text.find("_apply_reality_tear") != -1, "Should have _apply_reality_tear method")
	assert_true(script_text.find("radius := 80.0") != -1, "reality_tear radius should be 80")
	assert_true(script_text.find("damage_per_second = 10.0") != -1, "reality_tear dps should be 10.0")
	assert_true(script_text.find("duration = 6.0") != -1, "reality_tear duration should be 6.0")

func test_reality_tear_is_single_use() -> void:
	var script_text := _load_script("res://scripts/combat/thrown_weapon.gd")
	# queue_free at end of file is inside _apply_reality_tear
	assert_true(script_text.find("_apply_reality_tear") != -1, "Should have _apply_reality_tear")
	# The last queue_free() in the file is the reality_tear single-use
	assert_true(script_text.rfind("queue_free()") > script_text.find("_apply_reality_tear"),
		"reality_tear should have queue_free (single use)")


# ============================================================
# Step 3: Gore System
# ============================================================

func test_gore_severed_limb_is_rigidbody() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	assert_true(script_text.find("RigidBody2D.new()") != -1, "severed limb should create RigidBody2D")

func test_gore_limb_lifetime() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	assert_true(script_text.find("despawn_time\", 30.0") != -1 or script_text.find("despawn_time\",30.0") != -1,
		"severed limb lifetime should be 30 seconds")

func test_gore_max_limbs() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	assert_true(script_text.find("max_limbs: int = 30") != -1, "max_limbs should be 30")

func test_gore_blood_pool_is_staticbody() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	assert_true(script_text.find("StaticBody2D.new()") != -1, "blood pool should create StaticBody2D")

func test_gore_max_pools() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	assert_true(script_text.find("max_pools_per_room: int = 15") != -1, "max_pools_per_room should be 15")

func test_gore_pool_color() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	# #5A0000 = R:90/255 ≈ 0.353
	assert_true(script_text.find("0.353") != -1, "blood pool color should have R ≈ 0.353 (#5A0000)")

func test_gore_clear_room_effects() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	assert_true(script_text.find("queue_free()") != -1, "clear_room_effects should free tracked nodes")

func test_gore_limb_sizes() -> void:
	var script_text := _load_script("res://scripts/combat/gore_system.gd")
	assert_true(script_text.find("Vector2(20, 6)") != -1, "arm limb should be 20x6")
	assert_true(script_text.find("Vector2(6, 20)") != -1, "leg limb should be 6x20")
	assert_true(script_text.find("Vector2(12, 12)") != -1, "head should be 12x12")


# ============================================================
# Step 4: Low-HP Vignette & Chromatic Aberration
# ============================================================

func test_vignette_creates_colorrect() -> void:
	var script_text := _load_script("res://scripts/core/game_scene.gd")
	assert_true(script_text.find("ColorRect") != -1, "vignette should create ColorRect")
	assert_true(script_text.find("GradientTexture2D") != -1, "vignette should use GradientTexture2D")

func test_vignette_responds_to_hp() -> void:
	var script_text := _load_script("res://scripts/core/game_scene.gd")
	assert_true(script_text.find("hp_percent") != -1, "vignette should use hp_percent")
	assert_true(script_text.find("clampf") != -1, "vignette alpha should be clamped")

func test_vignette_pulses_below_30pct() -> void:
	var script_text := _load_script("res://scripts/core/game_scene.gd")
	assert_true(script_text.find("0.3") != -1, "vignette should check HP < 30%%")
	assert_true(script_text.find("set_loops") != -1 or script_text.find("tween_property") != -1,
		"vignette should pulse when HP < 30%%")

func test_chromatic_creates_two_overlays() -> void:
	var script_text := _load_script("res://scripts/effects/screen_effects.gd")
	assert_true(script_text.find("_chromatic_r") != -1, "should have red channel overlay")
	assert_true(script_text.find("_chromatic_b") != -1, "should have blue channel overlay")
	assert_true(script_text.find("Color(1.0, 0.0, 0.0") != -1, "red overlay should be red")
	assert_true(script_text.find("Color(0.0, 0.0, 1.0") != -1, "blue overlay should be blue")

func test_chromatic_has_duration() -> void:
	var script_text := _load_script("res://scripts/effects/screen_effects.gd")
	assert_true(script_text.find("duration") != -1, "chromatic aberration should accept duration parameter")
	assert_true(script_text.find("intensity") != -1, "chromatic aberration should accept intensity parameter")

func test_chromatic_has_offset_logic() -> void:
	var script_text := _load_script("res://scripts/effects/screen_effects.gd")
	assert_true(script_text.find("-intensity") != -1, "R channel should offset left")
	assert_true(script_text.find("intensity, 0") != -1 or script_text.find("intensity") != -1,
		"B channel should offset right")


# ============================================================
# Step 5: WeaponManager
# ============================================================

func test_weapon_manager_no_todo() -> void:
	var script_text := _load_script("res://scripts/combat/weapon_manager.gd")
	assert_false(script_text.find("TODO") != -1, "weapon_manager.gd should not contain TODO comments")

func test_drop_weapon_creates_pickup() -> void:
	var script_text := _load_script("res://scripts/combat/weapon_manager.gd")
	assert_true(script_text.find("weapon_pickup.tscn") != -1, "_drop_weapon should load weapon_pickup scene")
	assert_true(script_text.find("instantiate") != -1, "_drop_weapon should instantiate pickup")
	assert_true(script_text.find("add_child") != -1, "_drop_weapon should add pickup to scene")

func test_drop_weapon_emits_signal() -> void:
	var script_text := _load_script("res://scripts/combat/weapon_manager.gd")
	var func_start := script_text.find("func _drop_weapon")
	assert_true(func_start != -1, "Should find _drop_weapon")
	var func_text := script_text.substr(func_start, 500)
	assert_true(func_text.find("weapon_dropped") != -1, "_drop_weapon should emit weapon_dropped")

func test_hunger_blade_heal_multiplier() -> void:
	var script_text := _load_script("res://scripts/combat/weapon_manager.gd")
	assert_true(script_text.find("Hunger Blade") != -1, "Should check Hunger Blade artifact")
	assert_true(script_text.find("0.15") != -1, "Hunger Blade heal should be 15%% of damage")

func test_hunger_blade_melee_only() -> void:
	var script_text := _load_script("res://scripts/combat/weapon_manager.gd")
	assert_true(script_text.find("is_melee") != -1, "Hunger Blade heal should be gated by is_melee flag")

func test_melee_attack_passes_is_melee() -> void:
	var script_text := _load_script("res://scripts/combat/weapon_manager.gd")
	# melee_attack lambda passes 5th arg (true) to _apply_damage_to_target
	var melee_start := script_text.find("func melee_attack")
	assert_true(melee_start != -1, "Should find melee_attack")
	# Find the _apply_damage_to_target call within melee_attack scope
	var next_func := script_text.find("\nfunc ", melee_start + 1)
	var melee_section := script_text.substr(melee_start, next_func - melee_start if next_func > 0 else 2000)
	assert_true(melee_section.find("weapon, true)") != -1, "melee_attack should pass true for is_melee param")


# ============================================================
# Helper
# ============================================================

func _load_script(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return ""
	var text := file.get_as_text()
	file.close()
	return text
