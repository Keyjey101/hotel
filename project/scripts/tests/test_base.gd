extends RefCounted

## BaseTest — Base class for all test suites. Provides assertion methods.

var _test_runner: Object  # Injected by TestRunner


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		var msg := "Expected true, got false"
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		var msg := "Expected false, got true"
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		var msg := "Expected %s, got %s" % [str(expected), str(actual)]
		if message != "":
			msg = "%s (expected %s, got %s)" % [message, str(expected), str(actual)]
		_test_runner.report_failure(msg)


func assert_ne(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual == expected:
		var msg := "Expected not equal to %s, but got exactly that" % str(expected)
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_gt(actual: float, expected: float, message: String = "") -> void:
	if actual <= expected:
		var msg := "Expected %s > %s" % [str(actual), str(expected)]
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_gte(actual: float, expected: float, message: String = "") -> void:
	if actual < expected:
		var msg := "Expected %s >= %s" % [str(actual), str(expected)]
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_lt(actual: float, expected: float, message: String = "") -> void:
	if actual >= expected:
		var msg := "Expected %s < %s" % [str(actual), str(expected)]
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_approx(actual: float, expected: float, tolerance: float = 0.01, message: String = "") -> void:
	if absf(actual - expected) > tolerance:
		var msg := "Expected ~%s, got %s (tolerance %s)" % [str(expected), str(actual), str(tolerance)]
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_has(dict: Dictionary, key: Variant, message: String = "") -> void:
	if not dict.has(key):
		var msg := "Expected dictionary to have key %s" % str(key)
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_between(value: float, low: float, high: float, message: String = "") -> void:
	if value < low or value > high:
		var msg := "Expected %s to be between %s and %s" % [str(value), str(low), str(high)]
		if message != "":
			msg = message
		_test_runner.report_failure(msg)
