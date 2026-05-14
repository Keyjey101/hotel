extends Node

## TestRunner — Lightweight test framework for Godot 4.
## Run from command line: godot --headless --script res://scripts/tests/test_runner.gd
## Or as scene: test_runner.tscn

var _suites: Array = []
var _total_tests: int = 0
var _passed: int = 0
var _failed: int = 0
var _errors: Array = []
var _current_suite: String = ""
var _current_test: String = ""


func _ready() -> void:
	print("\n========== HOTEL TEST RUNNER ==========\n")

	_register_suites()
	await _run_all()
	_print_summary()

	# Exit with code
	if _failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)


func _register_suites() -> void:
	_suites = [
		preload("res://scripts/tests/test_run_state.gd").new(),
		preload("res://scripts/tests/test_seed_manager.gd").new(),
		preload("res://scripts/tests/test_damage_zone.gd").new(),
		preload("res://scripts/tests/test_enemy_health.gd").new(),
		preload("res://scripts/tests/test_regen_system.gd").new(),
		preload("res://scripts/tests/test_weapon_data.gd").new(),
		preload("res://scripts/tests/test_combat_flow.gd").new(),
		# Floor 8 (M7.5)
		preload("res://scripts/tests/test_royal_guard.gd").new(),
		preload("res://scripts/tests/test_champion.gd").new(),
		preload("res://scripts/tests/test_consort.gd").new(),
		preload("res://scripts/tests/test_floor08.gd").new(),
		# Floor 9 (M7.6)
		preload("res://scripts/tests/test_demon.gd").new(),
		preload("res://scripts/tests/test_sister.gd").new(),
		preload("res://scripts/tests/test_satan.gd").new(),
		preload("res://scripts/tests/test_floor09.gd").new(),
		preload("res://scripts/tests/test_endings.gd").new(),
		# M8.1: Game Feel & VFX
		preload("res://scripts/tests/test_object_pool.gd").new(),
		preload("res://scripts/tests/test_screen_effects.gd").new(),
		preload("res://scripts/tests/test_m81_integration.gd").new(),
		# M8.1: Audio Manager
		preload("res://scripts/tests/test_audio_manager.gd").new(),
		# M8.2: SFX Integration
		preload("res://scripts/tests/test_sfx_integration.gd").new(),
		# M8.4: Balance Audit
		preload("res://scripts/tests/test_balance_audit.gd").new(),
		# Behavioral replacements (M8.1/M8.2/M8.3/M8.4)
		preload("res://scripts/tests/test_enemy_stats_behavioral.gd").new(),
		preload("res://scripts/tests/test_m81_behavioral.gd").new(),
		preload("res://scripts/tests/test_sfx_behavioral.gd").new(),
		# Boot smoke test
		preload("res://scripts/tests/test_boot_smoke.gd").new(),
		# Artifact + Upgrade registry
		preload("res://scripts/tests/test_artifact_registry.gd").new(),
		# Behavioral upgrades
		preload("res://scripts/tests/test_second_wind.gd").new(),
		preload("res://scripts/tests/test_bloodlust.gd").new(),
		# Full run dry test
		preload("res://scripts/tests/test_full_run_dry.gd").new(),
		# Signature mechanics (F1-F12)
		preload("res://scripts/tests/test_signature_mechanics.gd").new(),
		# Bug regression tests (GUT-rewritten)
		preload("res://tests/test_001_hit_stop_freeze.gd").new(),
		preload("res://tests/test_002_weapon_keys_mismatch.gd").new(),
		preload("res://tests/test_005_champion_select_patterns_oob.gd").new(),
		preload("res://tests/test_007_sister_ally_targets_satan.gd").new(),
		preload("res://tests/test_008_basement_rng_null.gd").new(),
		preload("res://tests/test_009_typed_array_shuffle.gd").new(),
		preload("res://tests/test_010_signal_connect_after_emit.gd").new(),
		preload("res://tests/test_011_seeded_rng_mutation.gd").new(),
		preload("res://tests/test_012_signal_leak_pooled_objects.gd").new(),
		preload("res://tests/test_013_gore_system_droplet_limit.gd").new(),
		preload("res://tests/test_014_crossfade_volume_corruption.gd").new(),
		preload("res://tests/test_016_exit_tree_signal_leak.gd").new(),
		preload("res://tests/test_017_dialog_setup_before_ready.gd").new(),
		preload("res://tests/test_018_butcher_scene_missing.gd").new(),
		preload("res://tests/test_020_floor08_sword_weapon.gd").new(),
		preload("res://tests/test_022_arena_tree_exited_not_connected.gd").new(),
		preload("res://tests/test_026_champion_screen_shake_tween.gd").new(),
		preload("res://tests/test_027_consort_safe_position_retreat.gd").new(),
		preload("res://tests/test_029_sister_attack_pause_reset.gd").new(),
		preload("res://tests/test_032_madame_mirror_load.gd").new(),
		preload("res://tests/test_033_satan_liquidation_zones_leak.gd").new(),
		preload("res://tests/test_034_loadout_type_confusion.gd").new(),
		preload("res://tests/test_036_floor09_artifact_missing.gd").new(),
		preload("res://tests/test_037_projectile_timer_accumulation.gd").new(),
		preload("res://tests/test_039_gore_preloads_commented.gd").new(),
		preload("res://tests/test_041_hazard_slow_last_wins.gd").new(),
		preload("res://tests/test_042_player_freed_timer_callback.gd").new(),
		preload("res://tests/test_044_load_in_loop.gd").new(),
		preload("res://tests/test_047_room_instance_double_connect.gd").new(),
		preload("res://tests/test_048_corpse_race_condition.gd").new(),
		preload("res://tests/test_049_enemy_spawner_cache_never_cleared.gd").new(),
		preload("res://tests/test_080_object_pool_not_in_tree.gd").new(),
	]


func _run_all() -> void:
	for suite in _suites:
		_current_suite = suite.get_script().resource_path.get_file().replace(".gd", "")
		var methods: Array = suite.get_method_list()
		var test_methods: Array = methods.filter(func(m): return m.name.begins_with("test_"))

		if test_methods.is_empty():
			continue

		print("── %s ──" % _current_suite)

		# Setup
		if suite.has_method("before_all"):
			suite.before_all()

		for method in test_methods:
			_current_test = method.name
			_total_tests += 1

			if suite.has_method("before_each"):
				suite.before_each()

			suite._test_runner = self  # Inject runner for assertions

			var start_time := Time.get_ticks_usec()
			var error_msg := ""

			# Run test
			var result = _safe_call(suite, method.name)
			if result is int and result != OK:
				error_msg = "Script error during execution"
			elif result is Variant:
				await result.completed

			var elapsed := (Time.get_ticks_usec() - start_time) / 1000.0

			if error_msg == "" and not _has_current_failure():
				_passed += 1
				print("  ✅ %s (%.1fms)" % [method.name, elapsed])
			else:
				_failed += 1
				var fail_msg := _pop_current_failure()
				print("  ❌ %s: %s" % [method.name, fail_msg])
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
	# Count behavioral vs smoke suites
	var behavioral_suites := [
		"test_run_state", "test_seed_manager", "test_damage_zone",
		"test_enemy_health", "test_regen_system", "test_weapon_data",
		"test_combat_flow", "test_royal_guard", "test_champion",
		"test_consort", "test_floor08", "test_demon", "test_sister",
		"test_satan", "test_floor09", "test_endings", "test_object_pool",
		"test_screen_effects", "test_audio_manager", "test_balance_audit",
		"test_enemy_stats_behavioral", "test_m81_behavioral",
		"test_sfx_behavioral", "test_m81_integration", "test_sfx_integration",
	]
	var smoke_suites := ["test_boot_smoke", "test_artifact_registry", "test_second_wind", "test_bloodlust"]
	var run_suites := ["test_full_run_dry"]

	var n_behavioral := 0
	var n_smoke := 0
	var n_run := 0
	for suite in _suites:
		var name: String = suite.get_script().resource_path.get_file().replace(".gd", "")
		if name in behavioral_suites:
			n_behavioral += 1
		elif name in smoke_suites:
			n_smoke += 1
		elif name in run_suites:
			n_run += 1

	print("========== RESULTS ==========")
	print("Total: %d | Passed: %d | Failed: %d" % [_total_tests, _passed, _failed])
	print("Behavioral suites: %d | Smoke suites: %d | Run-through suites: %d" % [n_behavioral, n_smoke, n_run])

	if not _errors.is_empty():
		print("\n── FAILURES ──")
		for e in _errors:
			print("  • %s" % e)

	print("=============================\n")
