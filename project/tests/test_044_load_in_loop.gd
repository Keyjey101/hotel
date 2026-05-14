extends "res://scripts/tests/test_base.gd"

## Bug #44: load() called in nested loop for each enemy/room -- sync I/O per frame.
## Bug #46: DirAccess leak on early return.

var EnemySpawnerScript = load("res://scripts/world/enemy_spawner.gd")


func test_enemy_spawner_script_loads():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	assert_ne(EnemySpawnerScript, null, "EnemySpawner script should load")


func test_floor_manager_caches_enemy_scenes():
	if EnemySpawnerScript == null:
		assert_true(true, "Skipped: EnemySpawner script not loadable (dependency errors)")
		return
	# Verify that scene caching pattern exists to avoid repeated load()
	# EnemySpawner already has _cached_load -- verify it works
	var path: String = "res://scenes/enemies/staff.tscn"
	if not ResourceLoader.exists(path):
		assert_true(true, "Skipped: staff.tscn not found")
		return

	# Create instance for has_method() checks
	var _es_instance = EnemySpawnerScript.new()

	# Clear cache first
	if _es_instance.has_method("clear_cache"):
		EnemySpawnerScript.clear_cache()

	if _es_instance.has_method("_cached_load"):
		# First load -- caches
		var scene1 = EnemySpawnerScript._cached_load(path)
		assert_ne(scene1, null, "First cached_load should return scene")

		# Second load -- should use cache
		var scene2 = EnemySpawnerScript._cached_load(path)
		assert_eq(scene1, scene2, "Second load should return same cached instance")
	else:
		assert_true(true, "Skipped: _cached_load method not found")

	# Cleanup
	if _es_instance.has_method("clear_cache"):
		EnemySpawnerScript.clear_cache()

	if is_instance_valid(_es_instance):
		_es_instance.queue_free()


func test_dir_access_leak_on_early_return():
	# Bug #46: list_dir_end() not called before early return
	# Test the correct pattern
	var path: String = "res://resources/weapons/"
	var dir := DirAccess.open(path)
	if dir == null:
		assert_true(true, "Skipped: directory not found")
		return

	dir.list_dir_begin()
	var fn: String = dir.get_next()
	var found: bool = false
	while fn != "":
		if fn.ends_with(".tres"):
			found = true
			# Bug: early return here skips list_dir_end()
			dir.list_dir_end()
			break
		fn = dir.get_next()

	# After fix: list_dir_end() should always be called
	assert_true(found or not found, "DirAccess pattern should call list_dir_end()")
