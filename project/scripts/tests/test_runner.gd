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
	_run_all()
	_print_summary()

	# Exit with code
	if _failed > 0:
		get_tree().quit(1 if _failed > 0 else 0)


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
		# M8.3: Stubs Completion
		preload("res://scripts/tests/test_stubs_completion.gd").new(),
		# M8.4: Balance Audit
		preload("res://scripts/tests/test_balance_audit.gd").new(),
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
			var result := _safe_call(suite, method.name)
			if result != OK:
				error_msg = "Script error during execution"

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


func _safe_call(instance: Object, method: String) -> int:
	if not instance.has_method(method):
		return ERR_UNAVAILABLE
	instance.call(method)
	return OK


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
	print("Total: %d | Passed: %d | Failed: %d" % [_total_tests, _passed, _failed])

	if not _errors.is_empty():
		print("\n── FAILURES ──")
		for e in _errors:
			print("  • %s" % e)

	print("=============================\n")
