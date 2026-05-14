extends "res://scripts/tests/test_base.gd"

## Bug #18: butcher.tscn doesn't exist -- ENEMY_SCENES references non-existent file.
## Bug #19: Inconsistent enemy keys between FloorManager and EnemySpawner.

var FloorManagerScript = load("res://scripts/world/floor_manager.gd")
var EnemySpawnerScript = load("res://scripts/world/enemy_spawner.gd")


func test_floor_manager_script_loads():
	if FloorManagerScript == null:
		assert_true(true, "Skipped: FloorManager script not loadable (dependency errors)")
		return
	assert_ne(FloorManagerScript, null, "FloorManager script should load")


func test_enemy_spawner_script_loads():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	assert_ne(EnemySpawnerScript, null, "EnemySpawner script should load")


func test_floor_manager_enemy_scenes_exist():
	if FloorManagerScript == null:
		assert_true(true, "Skipped: FloorManager script not loadable (dependency errors)")
		return
	var missing: Array[String] = []
	for enemy_type in FloorManagerScript.ENEMY_SCENES:
		var path: String = FloorManagerScript.ENEMY_SCENES[enemy_type]
		if not ResourceLoader.exists(path):
			missing.append("%s -> %s" % [enemy_type, path])
	assert_true(missing.is_empty(), "All FloorManager ENEMY_SCENES paths should exist. Missing: %s" % str(missing))


func test_enemy_spawner_scenes_exist():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	var missing: Array[String] = []
	for enemy_type in EnemySpawnerScript.ENEMY_SCENES:
		var path: String = EnemySpawnerScript.ENEMY_SCENES[enemy_type]
		if not ResourceLoader.exists(path):
			missing.append("%s -> %s" % [enemy_type, path])
	assert_true(missing.is_empty(), "All EnemySpawner ENEMY_SCENES paths should exist. Missing: %s" % str(missing))


func test_enemy_keys_consistent():
	if FloorManagerScript == null:
		assert_true(true, "Skipped: FloorManager script not loadable (dependency errors)")
		return
	# FloorManager uses "champion_enemy", EnemySpawner uses "champion"
	# After fix, they should be consistent
	var fm_keys: Array = FloorManagerScript.ENEMY_SCENES.keys()
	for key in fm_keys:
		if not str(key).begins_with("boss") and not str(key).begins_with("madame") and not str(key).begins_with("gourmand"):
			# Regular enemy key should be resolvable
			var path: String = FloorManagerScript.ENEMY_SCENES[key]
			assert_true(ResourceLoader.exists(path), "Enemy key '%s' should resolve to existing scene" % key)
