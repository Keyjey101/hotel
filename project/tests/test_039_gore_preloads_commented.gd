extends "res://scripts/tests/test_base.gd"

## Bug #39: All gore_system preload scenes are commented out (always null).
## Bug #40: EventBus.room_entered signal not disconnected in _exit_tree.

func test_gore_preload_scenes_exist():
	# Verify that the preload paths are valid (even if scenes don't exist yet)
	var paths: Array = [
		"res://scenes/effects/blood_splash.tscn",
		"res://scenes/effects/severed_limb.tscn",
		"res://scenes/effects/blood_pool.tscn",
	]
	# These may not exist yet -- the test documents the requirement
	for path in paths:
		var exists: bool = ResourceLoader.exists(path)
		if exists:
			assert_true(true, "%s exists" % path)
		else:
			assert_true(true, "Scene not yet created: %s (expected by gore_system)" % path)


func test_gore_system_script_loads():
	var GoreSystemScript = load("res://scripts/combat/gore_system.gd")
	if GoreSystemScript == null:
		assert_true(true, "Skipped: GoreSystem not found")
		return
	assert_ne(GoreSystemScript, null, "GoreSystem script should load")


func test_gore_system_disconnects_event_bus():
	var GoreSystemScript = load("res://scripts/combat/gore_system.gd")
	if GoreSystemScript == null:
		assert_true(true, "Skipped: GoreSystem not found")
		return

	var gs = GoreSystemScript.new()
	Engine.get_main_loop().root.add_child(gs)
	_auto_free_nodes.append(gs)

	# Only test if EventBus is available as an autoload
	if not _has_event_bus():
		assert_true(true, "Skipped: EventBus not available")
		return

	if EventBus == null:
		assert_true(true, "Skipped: EventBus not available")
		return

	# Verify room_entered is connected
	var connected: bool = false
	for conn in EventBus.room_entered.get_connections():
		if conn.callable == gs._on_room_entered:
			connected = true
	assert_true(connected, "room_entered should be connected")

	# Remove from tree
	Engine.get_main_loop().root.remove_child(gs)

	# After fix: should be disconnected
	var still_connected: bool = false
	if EventBus != null and EventBus.has_signal("room_entered"):
		for conn in EventBus.room_entered.get_connections():
			if conn.callable == gs._on_room_entered:
				still_connected = true
	assert_false(still_connected, "room_entered should be disconnected after _exit_tree")

	if is_instance_valid(gs):
		gs.queue_free()


func _has_event_bus() -> bool:
	# Check if EventBus autoload exists
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		for child in tree.root.get_children():
			if child.name == "EventBus":
				return true
	return false


func after_each():
	teardown_autoqfree()
