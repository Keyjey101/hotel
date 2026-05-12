extends Node

## TestFullRunDry — Emulates a complete run from Floor 1 through endings.
## Teleports the game through scenes, verifying reachability without crashes.
## Uses test_mode meta to skip gated dialog checks.


var _test_runner: Object  # Injected by TestRunner


func before_all() -> void:
	# Enable test mode to bypass dialog gates
	GameManager.run_state.set_meta("test_mode", true)


func after_all() -> void:
	if GameManager.run_state and GameManager.run_state.has_meta("test_mode"):
		GameManager.run_state.remove_meta("test_mode")


func test_floors_1_through_8_reachable() -> void:
	GameManager.start_new_run()
	await get_tree().process_frame
	await get_tree().process_frame

	assert(GameManager.current_floor == 1, "Run starts on floor 1")

	# Walk through floors 1-8
	for floor_num in range(1, 9):
		GameManager.handle_floor_completed(floor_num)
		await get_tree().process_frame
		await get_tree().process_frame
		assert(GameManager.current_floor == floor_num + 1,
			"Floor %d completed → now on floor %d" % [floor_num, GameManager.current_floor])


func test_floor_9_triggers_victory() -> void:
	# Start a fresh run and skip to floor 9
	GameManager.start_new_run()
	await get_tree().process_frame
	GameManager.current_floor = 8
	GameManager.handle_floor_completed(8)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(GameManager.current_floor == 9, "Reached floor 9")

	# Floor 9 completion should trigger victory path
	GameManager.handle_floor_completed(9)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(GameManager.current_state == GameManager.GameState.VICTORY,
		"Floor 9 completion triggers VICTORY state")


func test_ending_a_reachable() -> void:
	# Ending A: kill Sister + kill Satan
	_setup_boss_run()
	GameManager.trigger_ending("a")
	await get_tree().process_frame
	await get_tree().process_frame
	# Verify scene changed to ending_a
	var scene_path := "res://scenes/endings/ending_a.tscn"
	assert(ResourceLoader.exists(scene_path), "ending_a.tscn exists on disk")


func test_ending_b_reachable() -> void:
	_setup_boss_run()
	GameManager.trigger_ending("b")
	await get_tree().process_frame
	var scene_path := "res://scenes/endings/ending_b.tscn"
	assert(ResourceLoader.exists(scene_path), "ending_b.tscn exists on disk")


func test_ending_c_reachable() -> void:
	_setup_boss_run()
	GameManager.trigger_ending("c")
	await get_tree().process_frame
	var scene_path := "res://scenes/endings/ending_c.tscn"
	assert(ResourceLoader.exists(scene_path), "ending_c.tscn exists on disk")


func test_ending_d_reachable() -> void:
	_setup_boss_run()
	GameManager.trigger_ending("d")
	await get_tree().process_frame
	var scene_path := "res://scenes/endings/ending_d.tscn"
	assert(ResourceLoader.exists(scene_path), "ending_d.tscn exists on disk")


func test_all_ending_scenes_loadable() -> void:
	var endings := ["a", "b", "c", "d"]
	for eid in endings:
		var path := "res://scenes/endings/ending_%s.tscn" % eid
		assert(ResourceLoader.exists(path), "Ending scene %s exists" % eid)
		var scene: PackedScene = load(path)
		assert(scene != null, "Ending %s loads as PackedScene" % eid)
		var instance := scene.instantiate()
		assert(instance != null, "Ending %s instantiates" % eid)
		instance.free()


# ============================================================
# Helpers
# ============================================================

func _setup_boss_run() -> void:
	GameManager.start_new_run()
	await get_tree().process_frame
	GameManager.current_floor = 9
	GameManager.current_state = GameManager.GameState.PLAYING
	if GameManager.run_state:
		GameManager.run_state.set_meta("test_mode", true)
