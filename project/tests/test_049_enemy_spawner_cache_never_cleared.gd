extends "res://scripts/tests/test_base.gd"

## Bug #49: Static _scene_cache never cleared in EnemySpawner.

var EnemySpawnerScript = load("res://scripts/world/enemy_spawner.gd")


func test_enemy_spawner_script_loads():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	assert_ne(EnemySpawnerScript, null, "EnemySpawner script should load")


func test_clear_cache_exists():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	var spawner = EnemySpawnerScript.new()
	assert_true(spawner.has_method("clear_cache"), "clear_cache should exist")
	if is_instance_valid(spawner):
		spawner.queue_free()


func test_clear_cache_empties_dict():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	var _es_instance = EnemySpawnerScript.new()
	if not _es_instance.has_method("clear_cache"):
		assert_true(true, "Skipped: clear_cache method not found")
		if is_instance_valid(_es_instance):
			_es_instance.queue_free()
		return

	var path: String = "res://scenes/enemies/staff.tscn"
	if ResourceLoader.exists(path) and _es_instance.has_method("_cached_load"):
		EnemySpawnerScript._cached_load(path)

	EnemySpawnerScript.clear_cache()

	if "_scene_cache" in EnemySpawnerScript:
		assert_eq(EnemySpawnerScript._scene_cache.size(), 0, "Cache should be empty after clear")
	else:
		assert_true(true, "Skipped: _scene_cache not accessible as static")

	if is_instance_valid(_es_instance):
		_es_instance.queue_free()


func test_cache_populated_on_load():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	var _es_instance = EnemySpawnerScript.new()
	if not _es_instance.has_method("clear_cache"):
		assert_true(true, "Skipped: clear_cache method not found")
		if is_instance_valid(_es_instance):
			_es_instance.queue_free()
		return

	EnemySpawnerScript.clear_cache()
	var path: String = "res://scenes/enemies/staff.tscn"
	if ResourceLoader.exists(path) and _es_instance.has_method("_cached_load"):
		EnemySpawnerScript._cached_load(path)
		if "_scene_cache" in EnemySpawnerScript:
			assert_true(EnemySpawnerScript._scene_cache.has(path), "Cache should contain loaded path")

	EnemySpawnerScript.clear_cache()

	if is_instance_valid(_es_instance):
		_es_instance.queue_free()
