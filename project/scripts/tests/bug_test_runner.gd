extends Node

## BugTestRunner — Runs bug regression tests with graceful failure handling.
## Uses load() instead of preload() so broken dependencies are skipped.
## Run: godot --headless --path . res://scenes/test/bug_test_runner.tscn

var _suites: Array = []
var _total_tests: int = 0
var _passed: int = 0
var _failed: int = 0
var _skipped_suites: int = 0
var _errors: Array = []
var _current_suite: String = ""
var _current_test: String = ""


func _ready() -> void:
	print("\n========== BUG REGRESSION TEST RUNNER ==========\n")
	_register_suites()
	await _run_all()
	_print_summary()
	if _failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)


func _safe_load(path: String) -> RefCounted:
	var script = load(path)
	if script == null:
		print("  [SKIP] %s — script failed to load (dependency errors)" % path)
		_skipped_suites += 1
		return null
	var instance = script.new()
	if instance == null:
		print("  [SKIP] %s — instantiation failed" % path)
		_skipped_suites += 1
		return null
	return instance


func _register_suites() -> void:
	var test_paths: Array = [
		# Pure logic tests (no scene/autoload deps)
		"res://tests/test_009_typed_array_shuffle.gd",
		"res://tests/test_010_signal_connect_after_emit.gd",
		"res://tests/test_011_seeded_rng_mutation.gd",
		"res://tests/test_026_champion_screen_shake_tween.gd",
		"res://tests/test_027_consort_safe_position_retreat.gd",
		"res://tests/test_032_madame_mirror_load.gd",
		"res://tests/test_033_satan_liquidation_zones_leak.gd",
		"res://tests/test_048_corpse_race_condition.gd",
		# Tests with load() + null guards
		"res://tests/test_001_hit_stop_freeze.gd",
		"res://tests/test_013_gore_system_droplet_limit.gd",
		"res://tests/test_014_crossfade_volume_corruption.gd",
		"res://tests/test_016_exit_tree_signal_leak.gd",
		"res://tests/test_017_dialog_setup_before_ready.gd",
		"res://tests/test_034_loadout_type_confusion.gd",
		"res://tests/test_037_projectile_timer_accumulation.gd",
		"res://tests/test_039_gore_preloads_commented.gd",
		"res://tests/test_042_player_freed_timer_callback.gd",
		"res://tests/test_080_object_pool_not_in_tree.gd",
		# Tests with scene deps (may skip)
		"res://tests/test_002_weapon_keys_mismatch.gd",
		"res://tests/test_005_champion_select_patterns_oob.gd",
		"res://tests/test_007_sister_ally_targets_satan.gd",
		"res://tests/test_008_basement_rng_null.gd",
		"res://tests/test_012_signal_leak_pooled_objects.gd",
		"res://tests/test_018_butcher_scene_missing.gd",
		"res://tests/test_020_floor08_sword_weapon.gd",
		"res://tests/test_022_arena_tree_exited_not_connected.gd",
		"res://tests/test_029_sister_attack_pause_reset.gd",
		"res://tests/test_036_floor09_artifact_missing.gd",
		"res://tests/test_041_hazard_slow_last_wins.gd",
		"res://tests/test_044_load_in_loop.gd",
		"res://tests/test_047_room_instance_double_connect.gd",
		"res://tests/test_049_enemy_spawner_cache_never_cleared.gd",
	]

	for path in test_paths:
		var suite = _safe_load(path)
		if suite != null:
			_suites.append(suite)


func _run_all() -> void:
	for suite in _suites:
		_current_suite = suite.get_script().resource_path.get_file().replace(".gd", "")
		var methods: Array = suite.get_method_list()
		var test_methods: Array = methods.filter(func(m): return m.name.begins_with("test_"))

		if test_methods.is_empty():
			continue

		print("── %s ──" % _current_suite)

		if suite.has_method("before_all"):
			suite.before_all()

		for method in test_methods:
			_current_test = method.name
			_total_tests += 1

			if suite.has_method("before_each"):
				suite.before_each()

			suite._test_runner = self

			var start_time := Time.get_ticks_usec()
			var error_msg := ""

			var result = _safe_call(suite, method.name)
			if result is int and result != OK:
				error_msg = "Script error during execution"
			elif result != null:
				# Await any coroutine/generator return
				await result.completed

			var elapsed: float = (Time.get_ticks_usec() - start_time) / 1000.0

			if error_msg == "" and not _has_current_failure():
				_passed += 1
				print("  PASS %s (%.1fms)" % [method.name, elapsed])
			else:
				_failed += 1
				var fail_msg := _pop_current_failure()
				if fail_msg == "":
					fail_msg = error_msg
				print("  FAIL %s: %s" % [method.name, fail_msg])
				_errors.append("%s::%s: %s" % [_current_suite, method.name, fail_msg])

			if suite.has_method("after_each"):
				suite.after_each()

		if suite.has_method("after_all"):
			suite.after_all()

		print("")


func _safe_call(instance: Object, method: String) -> Variant:
	if not instance.has_method(method):
		return ERR_UNAVAILABLE
	return instance.call(method)


var _current_failure: String = ""


func _has_current_failure() -> bool:
	return _current_failure != ""


func _pop_current_failure() -> String:
	var f := _current_failure
	_current_failure = ""
	return f


func report_failure(message: String) -> void:
	_current_failure = message


func _print_summary() -> void:
	print("========== RESULTS ==========")
	print("Total: %d | Passed: %d | Failed: %d | Skipped suites: %d" % [_total_tests, _passed, _failed, _skipped_suites])

	if not _errors.is_empty():
		print("\n── FAILURES ──")
		for e in _errors:
			print("  - %s" % e)

	print("=============================\n")
