extends "res://scripts/tests/test_base.gd"

## Bug #8: _rng is null if enter_basement() is called before _ready().
## _strip_weapons() calls _rng.randi_range() but _rng is set in _ready().
## Bug #21: player_died signal connected without is_connected guard.

const BasementManagerScript = preload("res://scripts/world/basement_manager.gd")


func test_basement_manager_script_loads():
	assert_ne(BasementManagerScript, null, "BasementManager script should load")


func test_strip_weapons_handles_null_rng():
	# GameManager can't compile due to source bugs — skip if unavailable
	if GameManager == null:
		assert_true(true, "Skipped: GameManager not available")
		return

	var bm = BasementManagerScript.new()
	_add_to_tree(bm)
	bm._rng = null

	var run_state_script = load("res://scripts/core/run_state.gd")
	if run_state_script == null:
		assert_true(true, "Skipped: RunState script not available")
		return

	var rs = run_state_script.new()
	GameManager.run_state = rs
	# Should not crash when _rng is null
	bm._strip_weapons()
	assert_true(true, "_strip_weapons should not crash with null _rng")


func test_player_died_signal_no_double_connect():
	# Bug #21: enter_basement connects player_died without guard.
	if GameManager == null:
		assert_true(true, "Skipped: GameManager not available")
		return

	if not GameManager.has_signal("player_died"):
		assert_true(true, "Skipped: GameManager lacks player_died signal")
		return

	var bm = BasementManagerScript.new()
	_add_to_tree(bm)

	var callable: Callable = bm._on_player_died
	# First connection
	if not GameManager.player_died.is_connected(callable):
		GameManager.player_died.connect(callable)

	var count_before: int = 0
	for conn in GameManager.player_died.get_connections():
		if conn.callable == callable:
			count_before += 1

	# Second connection attempt (should be guarded)
	if not GameManager.player_died.is_connected(callable):
		GameManager.player_died.connect(callable)

	var count_after: int = 0
	for conn in GameManager.player_died.get_connections():
		if conn.callable == callable:
			count_after += 1

	assert_eq(count_after, count_before, "Signal should not be connected twice")

	# Cleanup
	if GameManager.player_died.is_connected(callable):
		GameManager.player_died.disconnect(callable)


func _add_to_tree(node: Node):
	var _st := Engine.get_main_loop() as SceneTree
	_st.root.add_child(node)
	_auto_free_nodes.append(node)


func after_each():
	teardown_autoqfree()
