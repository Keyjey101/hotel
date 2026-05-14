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


func assert_lte(actual: float, expected: float, message: String = "") -> void:
	if actual > expected:
		var msg := "Expected %s <= %s" % [str(actual), str(expected)]
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_null(value: Variant, message: String = "") -> void:
	if value != null:
		var msg := "Expected null, got %s" % str(value)
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_not_null(value: Variant, message: String = "") -> void:
	if value == null:
		var msg := "Expected non-null value, got null"
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func assert_node_exists(group_name: String, message: String = "") -> void:
	var _ml := Engine.get_main_loop() as SceneTree
	var node: Node = _ml.get_first_node_in_group(group_name) if _ml else null
	if node == null:
		var msg := "Expected node in group '%s' to exist" % group_name
		if message != "":
			msg = message
		_test_runner.report_failure(msg)


func async_wait_for_signal(sig: Signal, timeout: float = 2.0) -> bool:
	var result: bool = false
	var done := func():
		result = true
	sig.connect(done, Object.CONNECT_ONE_SHOT)
	# Wait with timeout
	var timer: SceneTreeTimer = (Engine.get_main_loop() as SceneTree).create_timer(timeout)
	timer.one_shot = true
	await timer.timeout
	if sig.is_connected(done):
		sig.disconnect(done)
	return result


var _auto_free_nodes: Array[Node] = []


func add_child_autoqfree(parent: Node, child: Node) -> void:
	parent.add_child(child)
	_auto_free_nodes.append(child)


func teardown_autoqfree() -> void:
	for node in _auto_free_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_auto_free_nodes.clear()
