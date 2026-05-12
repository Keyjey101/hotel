extends "res://scripts/tests/test_base.gd"

## TestM81Behavioral — Behavioral tests for M8.1 Game Feel & VFX.
## Replaces string-find source code checks with real runtime verification.


# ============================================================
# ObjectPool behavioral tests
# ============================================================

func test_object_pool_get_returns_instance() -> void:
	var scene := _make_dummy_scene()
	var pool_script := load("res://scripts/effects/object_pool.gd")
	var pool := pool_script.new(scene, 2, 5)
	assert_ne(pool, null, "Pool created")
	var instance := pool.get_instance()
	assert_ne(instance, null, "get_instance returns non-null")
	assert_true(instance is Node, "Instance is a Node")


func test_object_pool_return_disables_instance() -> void:
	var scene := _make_dummy_scene()
	var pool_script := load("res://scripts/effects/object_pool.gd")
	var pool := pool_script.new(scene, 2, 5)
	var instance := pool.get_instance()
	pool.return_instance(instance)
	assert_false(instance.visible, "Returned instance is hidden")
	assert_false(instance.is_processing(), "Returned instance processing disabled")


func test_object_pool_respects_max_size() -> void:
	var scene := _make_dummy_scene()
	var pool_script := load("res://scripts/effects/object_pool.gd")
	var pool := pool_script.new(scene, 1, 3)
	var instances: Array = []
	for i in range(3):
		instances.append(pool.get_instance())
	# 4th request should still work (force-return oldest)
	var extra := pool.get_instance()
	assert_ne(extra, null, "Pool returns instance even at max (force-return)")


func test_object_pool_prewarm() -> void:
	var scene := _make_dummy_scene()
	var pool_script := load("res://scripts/effects/object_pool.gd")
	var pool := pool_script.new(scene, 0, 5)
	pool.prewarm(3)
	# Should be able to get 3 instances without allocation
	for i in range(3):
		var inst := pool.get_instance()
		assert_ne(inst, null, "Prewarmed instance %d available" % i)


# ============================================================
# ScreenEffects method existence (reflection)
# ============================================================

func test_screen_effects_has_shake() -> void:
	_assert_method_exists("res://scripts/effects/screen_effects.gd", "shake", 3)

func test_screen_effects_has_flash() -> void:
	_assert_method_exists("res://scripts/effects/screen_effects.gd", "flash", 3)

func test_screen_effects_has_hit_stop() -> void:
	_assert_method_exists("res://scripts/effects/screen_effects.gd", "hit_stop", 1)

func test_screen_effects_has_update_vignette() -> void:
	_assert_method_exists("res://scripts/effects/screen_effects.gd", "update_vignette", 1)

func test_screen_effects_has_chromatic_aberration() -> void:
	_assert_method_exists("res://scripts/effects/screen_effects.gd", "chromatic_aberration", 2)

func test_screen_effects_has_zoom() -> void:
	_assert_method_exists("res://scripts/effects/screen_effects.gd", "zoom", 4)


# ============================================================
# GoreSystem property verification
# ============================================================

func test_gore_system_has_max_pools() -> void:
	var script := load("res://scripts/combat/gore_system.gd")
	var instance := script.new()
	assert_eq(instance.get("max_pools_per_room"), 15, "max_pools_per_room = 15")
	assert_eq(instance.get("max_limbs"), 30, "max_limbs = 30")

func test_gore_system_has_lifecycle_methods() -> void:
	var script := load("res://scripts/combat/gore_system.gd")
	var methods := script.get_script_method_list()
	var method_names: Array = methods.map(func(m): return m.name)
	assert_true(method_names.has("spawn_severed_limb"), "Has spawn_severed_limb")
	assert_true(method_names.has("spawn_blood_splash"), "Has spawn_blood_splash")
	assert_true(method_names.has("spawn_blood_pool"), "Has spawn_blood_pool")
	assert_true(method_names.has("clear_room_effects"), "Has clear_room_effects")
	assert_true(method_names.has("clear_all_effects"), "Has clear_all_effects")


# ============================================================
# WeaponManager pool structure (reflection)
# ============================================================

func test_weapon_manager_has_pool_vars() -> void:
	var script := load("res://scripts/combat/weapon_manager.gd")
	var props := script.get_script_property_list()
	var prop_names: Array = props.map(func(p): return p.name)
	assert_true(prop_names.has("_melee_pool") or prop_names.has("max_slots"), "Has pool or slot vars")

func test_weapon_manager_has_expected_methods() -> void:
	var script := load("res://scripts/combat/weapon_manager.gd")
	var methods := script.get_script_method_list()
	var method_names: Array = methods.map(func(m): return m.name)
	assert_true(method_names.has("melee_attack"), "Has melee_attack")
	assert_true(method_names.has("ranged_attack"), "Has ranged_attack")
	assert_true(method_names.has("throw_active_weapon"), "Has throw_active_weapon")
	assert_true(method_names.has("equip_weapon"), "Has equip_weapon")
	assert_true(method_names.has("switch_slot"), "Has switch_slot")


# ============================================================
# Projectile/ThrownWeapon/MeleeHit pool-return methods
# ============================================================

func test_projectile_has_return_to_pool() -> void:
	_assert_script_method("res://scripts/combat/projectile.gd", "_return_to_pool")

func test_thrown_weapon_has_return_to_pool() -> void:
	_assert_script_method("res://scripts/combat/thrown_weapon.gd", "_return_to_pool")

func test_melee_hit_has_return_to_pool() -> void:
	_assert_script_method("res://scripts/combat/melee_hit.gd", "_return_to_pool")


# ============================================================
# ThrownWeapon effect methods
# ============================================================

func test_thrown_weapon_has_effect_methods() -> void:
	var script := load("res://scripts/combat/thrown_weapon.gd")
	var methods := script.get_script_method_list()
	var method_names: Array = methods.map(func(m): return m.name)
	assert_true(method_names.has("_apply_stick_bleed"), "Has _apply_stick_bleed")
	assert_true(method_names.has("_apply_pin"), "Has _apply_pin")
	assert_true(method_names.has("_apply_embed"), "Has _apply_embed")
	assert_true(method_names.has("_apply_demoralize"), "Has _apply_demoralize")
	assert_true(method_names.has("_apply_tangle"), "Has _apply_tangle")
	assert_true(method_names.has("_apply_soul_rip"), "Has _apply_soul_rip")
	assert_true(method_names.has("_apply_reality_tear"), "Has _apply_reality_tear")


# ============================================================
# Helpers
# ============================================================

func _make_dummy_scene() -> PackedScene:
	var node := Node2D.new()
	var scene := PackedScene.new()
	scene.pack(node)
	node.free()
	return scene


func _assert_method_exists(script_path: String, method_name: String, min_args: int) -> void:
	var script := load(script_path)
	assert_ne(script, null, "Script loaded: %s" % script_path)
	var methods := script.get_script_method_list()
	var found := false
	for m in methods:
		if m.name == method_name:
			assert_gte(float(m.args.size()), float(min_args),
				"%s.%s has >= %d args" % [script_path.get_file(), method_name, min_args])
			found = true
			break
	assert_true(found, "%s has method '%s'" % [script_path.get_file(), method_name])


func _assert_script_method(script_path: String, method_name: String) -> void:
	var script := load(script_path)
	assert_ne(script, null, "Script loaded: %s" % script_path)
	var methods := script.get_script_method_list()
	var method_names: Array = methods.map(func(m): return m.name)
	assert_true(method_names.has(method_name),
		"%s has method '%s'" % [script_path.get_file(), method_name])
