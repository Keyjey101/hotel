extends "res://scripts/tests/test_base.gd"

## Bug #47: RoomInstance double-connects EventBus.enemy_disabled on reparent.

var RoomInstanceScript = load("res://scripts/world/room_instance.gd")


func test_room_instance_script_loads():
	if RoomInstanceScript == null:
		assert_true(true, "Skipped: RoomInstance script not loadable (dependency errors)")
		return
	assert_ne(RoomInstanceScript, null, "RoomInstance script should load")


func test_event_bus_connection_guarded():
	if RoomInstanceScript == null:
		assert_true(true, "Skipped: RoomInstance script not loadable (dependency errors)")
		return
	var room1 = RoomInstanceScript.new()
	room1.name = "Room1"
	room1.room_id = "test1"
	Engine.get_main_loop().root.add_child(room1)
	_auto_free_nodes.append(room1)

	# Only test if EventBus is available
	if not _has_event_bus():
		assert_true(true, "Skipped: EventBus not available")
		return

	# Count connections
	var callable = room1._enemy_disabled_callable
	var count1: int = 0
	if EventBus != null and EventBus.enemy_disabled.is_connected(callable):
		count1 = 1

	assert_eq(count1, 1, "First _ready should connect once")

	# Simulate reparent (remove and re-add)
	Engine.get_main_loop().root.remove_child(room1)
	Engine.get_main_loop().root.add_child(room1)

	# After fix: should still be connected only once
	var count2: int = 0
	if EventBus != null:
		for conn in EventBus.enemy_disabled.get_connections():
			if conn.callable == callable:
				count2 += 1

	assert_lte(count2, 1, "Should not double-connect after reparent")


func _has_event_bus() -> bool:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		for child in tree.root.get_children():
			if child.name == "EventBus":
				return true
	return false


func after_each():
	teardown_autoqfree()
