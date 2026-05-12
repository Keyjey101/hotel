extends Node

## Boot smoke test — verifies basic game loop starts correctly.
## Extended with state checks, pause/unpause, and floor transition.
## Run via test_runner.gd.


var _test_runner: Object  # Injected by TestRunner


func test_start_new_run_spawns_player() -> void:
	GameManager.start_new_run()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var player := get_tree().get_first_node_in_group("player")
	assert(player != null, "Player should exist after start_new_run")


func test_start_new_run_state_is_playing() -> void:
	assert(GameManager.current_state == GameManager.GameState.PLAYING,
		"Game state should be PLAYING after start_new_run, got %s" % str(GameManager.current_state))


func test_start_new_run_has_floor_manager() -> void:
	var fm: FloorManager = null
	for child in get_tree().current_scene.get_children():
		if child is FloorManager:
			fm = child
			break
	assert(fm != null, "FloorManager should exist in scene")
	if fm:
		assert(fm.rooms.size() > 5, "Floor should have more than 5 rooms, got %d" % fm.rooms.size())


func test_start_new_run_has_enemies() -> void:
	await get_tree().process_frame
	var enemies := get_tree().get_nodes_in_group("enemy")
	assert(enemies.size() >= 1, "Active room should have at least 1 enemy, got %d" % enemies.size())


func test_pause_unpause() -> void:
	GameManager.current_state = GameManager.GameState.PLAYING
	GameManager.pause_game()
	assert(GameManager.current_state == GameManager.GameState.PAUSED, "Game should be paused")
	assert(get_tree().paused, "SceneTree should be paused")
	GameManager.unpause_game()
	assert(GameManager.current_state == GameManager.GameState.PLAYING, "Game should be playing")
	assert(not get_tree().paused, "SceneTree should be unpaused")


func test_floor_transition() -> void:
	var initial_floor := GameManager.current_floor
	EventBus.floor_completed.emit(initial_floor)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(GameManager.current_floor == initial_floor + 1,
		"Floor should advance from %d to %d, got %d" % [initial_floor, initial_floor + 1, GameManager.current_floor])
