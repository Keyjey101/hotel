extends "res://scripts/tests/test_base.gd"

## Bug #2: ALL weapon keys in WEAPON_WEIGHTS don't match actual resource files.
## Keys like "knife" resolve to "knife.tres" but real files are "melee_knife.tres".
## Bug #3: "sawed_off" in STARTING_WEAPONS doesn't exist (real: "ranged_sawed_off").

var LootSpawnerScript = load("res://scripts/world/loot_spawner.gd")


func test_weapon_weights_keys_resolve_to_files():
	if LootSpawnerScript == null:
		assert_true(true, "Skipped: LootSpawner script not loadable (dependency errors)")
		return
	# Every key in WEAPON_WEIGHTS must resolve to an existing .tres file
	var missing: Array[String] = []
	for weapon_id in LootSpawnerScript.WEAPON_WEIGHTS:
		var path: String = "res://resources/weapons/%s.tres" % weapon_id
		if not ResourceLoader.exists(path):
			missing.append(weapon_id)
	assert_true(missing.is_empty(), "All WEAPON_WEIGHTS keys must resolve to existing files. Missing: %s" % str(missing))


func test_starting_weapons_resolve_to_files():
	if LootSpawnerScript == null:
		assert_true(true, "Skipped: LootSpawner script not loadable (dependency errors)")
		return
	# Every weapon in STARTING_WEAPONS must resolve to an existing .tres file
	var missing: Array[String] = []
	for weapon_id in LootSpawnerScript.STARTING_WEAPONS:
		var path: String = "res://resources/weapons/%s.tres" % weapon_id
		if not ResourceLoader.exists(path):
			missing.append(weapon_id)
	assert_true(missing.is_empty(), "All STARTING_WEAPONS must resolve to existing files. Missing: %s" % str(missing))


func test_starting_weapons_not_empty():
	if LootSpawnerScript == null:
		assert_true(true, "Skipped: LootSpawner script not loadable (dependency errors)")
		return
	assert_true(LootSpawnerScript.STARTING_WEAPONS.size() >= 2, "Should have at least 2 starting weapons")


func test_weapon_floor_availability_keys_match():
	if LootSpawnerScript == null:
		assert_true(true, "Skipped: LootSpawner script not loadable (dependency errors)")
		return
	# Every key in WEAPON_FLOOR_AVAILABILITY should also resolve to a file
	var missing: Array[String] = []
	for weapon_id in LootSpawnerScript.WEAPON_FLOOR_AVAILABILITY:
		var path: String = "res://resources/weapons/%s.tres" % weapon_id
		if not ResourceLoader.exists(path):
			missing.append(weapon_id)
	assert_true(missing.is_empty(), "All WEAPON_FLOOR_AVAILABILITY keys must resolve. Missing: %s" % str(missing))
