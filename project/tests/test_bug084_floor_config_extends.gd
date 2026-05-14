extends "res://scripts/tests/test_base.gd"

## Bug #84: floor_02_config through floor_09_config have no extends.
## Fix: Add extends "res://scripts/world/floor_01_config.gd".


func test_floor_configs_all_load():
	var configs = [
		"res://scripts/world/floor_01_config.gd",
		"res://scripts/world/floor_02_config.gd",
		"res://scripts/world/floor_03_config.gd",
		"res://scripts/world/floor_04_config.gd",
		"res://scripts/world/floor_05_config.gd",
		"res://scripts/world/floor_06_config.gd",
		"res://scripts/world/floor_07_config.gd",
		"res://scripts/world/floor_08_config.gd",
		"res://scripts/world/floor_09_config.gd",
	]
	for path in configs:
		var script = load(path)
		assert_ne(script, null, "Config script should load: %s" % path)


func test_floor_configs_instantiate():
	var configs = [
		"res://scripts/world/floor_02_config.gd",
		"res://scripts/world/floor_03_config.gd",
		"res://scripts/world/floor_04_config.gd",
		"res://scripts/world/floor_05_config.gd",
		"res://scripts/world/floor_06_config.gd",
		"res://scripts/world/floor_07_config.gd",
		"res://scripts/world/floor_08_config.gd",
		"res://scripts/world/floor_09_config.gd",
	]
	for path in configs:
		var script = load(path)
		if script == null:
			continue
		var instance = script.new()
		assert_ne(instance, null, "Config should instantiate: %s" % path)
		if instance and instance is RefCounted:
			pass  # RefCounted auto-frees


func after_each():
	teardown_autoqfree()
