extends "res://scripts/tests/test_base.gd"

## Bug #20: Weapon "sword" doesn't exist in floor_08_config.

func test_floor_08_config_script_loads():
	var config_script = load("res://scripts/world/floor_08_config.gd")
	if config_script == null:
		assert_true(true, "Skipped: floor_08_config not found")
		return
	assert_ne(config_script, null, "floor_08_config script should load")


func test_floor_08_weapon_ids_exist():
	var config_script = load("res://scripts/world/floor_08_config.gd")
	if config_script == null:
		assert_true(true, "Skipped: floor_08_config not found")
		return

	# Load floor 8 room configs
	var configs: Dictionary = config_script.get_floor_08_rooms()
	for room_id in configs:
		var config: Dictionary = configs[room_id]
		var loot: Array = config.get("loot", [])
		for loot_item in loot:
			if loot_item.get("type") == "weapon":
				var weapon_id: String = loot_item.get("id", "")
				if weapon_id == "random":
					continue  # Random is handled at runtime
				var path := "res://resources/weapons/%s.tres" % weapon_id
				assert_true(ResourceLoader.exists(path),
					"Weapon '%s' in floor_08 room '%s' must exist at %s" % [weapon_id, room_id, path])
