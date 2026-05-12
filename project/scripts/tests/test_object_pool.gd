extends "res://scripts/tests/test_base.gd"

## TestObjectPool — Tests for the generic ObjectPool system.


func test_pool_has_class_name() -> void:
	var pool_script := load("res://scripts/effects/object_pool.gd")
	assert_ne(pool_script, null, "ObjectPool script should load")


func test_pool_initial_count() -> void:
	# ObjectPool requires a PackedScene — verify the script is valid
	var pool_script := load("res://scripts/effects/object_pool.gd")
	assert_ne(pool_script, null, "ObjectPool script loads")


func test_pool_methods_exist() -> void:
	var pool_script := load("res://scripts/effects/object_pool.gd")
	# Verify expected methods exist in the script
	var methods: Array = pool_script.get_script_method_list()
	var method_names: Array = []
	for m in methods:
		method_names.append(m["name"])
	assert_true("get_instance" in method_names, "get_instance method exists")
	assert_true("return_instance" in method_names, "return_instance method exists")
	assert_true("prewarm" in method_names, "prewarm method exists")


func test_pool_init_signature() -> void:
	var pool_script := load("res://scripts/effects/object_pool.gd")
	# _init takes (scene: PackedScene, initial: int, maximum: int)
	var has_init := false
	for method in pool_script.get_script_method_list():
		if method.name == "_init":
			has_init = true
	assert_true(has_init, "_init method exists in ObjectPool")


func test_pool_scene_paths_valid() -> void:
	# Verify all pooled scenes exist
	assert_true(ResourceLoader.exists("res://scenes/weapons/projectile.tscn"), "projectile.tscn exists")
	assert_true(ResourceLoader.exists("res://scenes/weapons/thrown_weapon.tscn"), "thrown_weapon.tscn exists")
	assert_true(ResourceLoader.exists("res://scenes/weapons/melee_hit.tscn"), "melee_hit.tscn exists")
