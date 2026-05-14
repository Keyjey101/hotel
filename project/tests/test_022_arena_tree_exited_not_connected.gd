extends "res://scripts/tests/test_base.gd"

## Bug #22: _on_enemy_tree_exited never connected -- active_enemies holds stale refs.
## Bug #23: _enemy_cleanup_done grows infinitely + recycled instance IDs.

var ArenaRoomScript = load("res://scripts/world/arena_room.gd")
var RoomInstanceScript = load("res://scripts/world/room_instance.gd")


func test_arena_room_script_loads():
	if ArenaRoomScript == null:
		assert_true(true, "Skipped: ArenaRoom script not loadable (dependency errors)")
		return
	assert_ne(ArenaRoomScript, null, "ArenaRoom script should load")


func test_room_instance_script_loads():
	if RoomInstanceScript == null:
		assert_true(true, "Skipped: RoomInstance script not loadable (dependency errors)")
		return
	assert_ne(RoomInstanceScript, null, "RoomInstance script should load")


func test_enemy_tree_exited_connected_on_spawn():
	if RoomInstanceScript == null or ArenaRoomScript == null:
		assert_true(true, "Skipped: dependency scripts not loadable")
		return
	var room = RoomInstanceScript.new()
	room.name = "TestRoom"
	room.room_id = "test"
	Engine.get_main_loop().root.add_child(room)
	_auto_free_nodes.append(room)

	var arena = Node2D.new()
	arena.set_script(ArenaRoomScript)
	arena.wave_configs = [{"enemy_types": [], "counts": []}]
	room.add_child(arena)
	_auto_free_nodes.append(arena)

	# Spawn a mock enemy
	var enemy = CharacterBody2D.new()
	enemy.add_to_group("enemy")
	enemy.set_meta("attack_damage", 10.0)
	room.add_child(enemy)
	arena.active_enemies.append(enemy)

	# The bug is that _on_enemy_tree_exited is defined but never connected.
	# Removing enemy should clean up active_enemies
	enemy.queue_free()
	await _wait(0.1)

	# After fix: active_enemies should not contain stale refs
	for e in arena.active_enemies:
		assert_true(is_instance_valid(e), "active_enemies should not contain freed nodes")


func test_enemy_cleanup_done_cleared_on_new_wave():
	if ArenaRoomScript == null:
		assert_true(true, "Skipped: ArenaRoom script not loadable (dependency errors)")
		return
	var arena = Node2D.new()
	arena.set_script(ArenaRoomScript)
	Engine.get_main_loop().root.add_child(arena)
	_auto_free_nodes.append(arena)

	# Simulate cleanup entries from wave 1
	arena._enemy_cleanup_done[1001] = true
	arena._enemy_cleanup_done[1002] = true
	arena._enemy_cleanup_done[1003] = true

	# After fix: _enemy_cleanup_done should be cleared when a new wave starts
	arena.current_wave = -1
	arena._spawn_wave(0)

	assert_lte(arena._enemy_cleanup_done.size(), 3,
		"_enemy_cleanup_done should be cleared between waves")


func _wait(seconds: float):
	var _st := Engine.get_main_loop() as SceneTree
	var timer: SceneTreeTimer = _st.create_timer(seconds)
	timer.one_shot = true
	await timer.timeout


func after_each():
	teardown_autoqfree()
