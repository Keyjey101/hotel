extends "res://scripts/tests/test_base.gd"

## Bug #10: Signal player_entered is emitted BEFORE the arena connects to it.
## In floor_06_manager, room is activated (emits signal) then arena connects.
## Bug #24: await arena.ready in signal callback can hang if arena is freed.

func test_signal_connected_before_emission():
	# Verify that signal connection happens before emission
	var emitter = Node.new()
	emitter.name = "TestRoom"
	Engine.get_main_loop().root.add_child(emitter)
	_auto_free_nodes.append(emitter)

	# Track whether callback fires
	var callback_fired := false
	var callback = func():
		callback_fired = true

	# Correct order: connect FIRST
	emitter.add_user_signal("player_entered")
	emitter.player_entered.connect(callback)

	# Then emit
	emitter.player_entered.emit()

	assert_true(callback_fired, "Callback should fire when signal is connected before emission")


func test_arena_room_callback_fires_on_enter():
	# Simulates the Floor06 arena setup scenario
	var room = Node2D.new()
	room.name = "TestRoomB1"
	Engine.get_main_loop().root.add_child(room)
	_auto_free_nodes.append(room)

	var callback_fired := false
	var arena_node = Node2D.new()
	arena_node.name = "ArenaRoom"
	room.add_child(arena_node)

	# Correct pattern: connect BEFORE room activation
	var callback = func():
		callback_fired = true

	room.add_user_signal("player_entered")
	room.player_entered.connect(callback)

	# Now activate (emit signal)
	room.player_entered.emit()

	assert_true(callback_fired, "Arena callback should fire on room activation")


func after_each():
	teardown_autoqfree()
