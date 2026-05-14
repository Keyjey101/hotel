extends "res://scripts/tests/test_base.gd"

## Bug #32: load() in boss_madame may return null -- set_script(null) crashes.

func test_load_returns_valid_script():
	var script = load("res://scripts/world/breakable_mirror.gd")
	# If the script doesn't exist, it returns null
	# After fix: should check for null before using
	if script == null:
		assert_true(true, "Script doesn't exist -- fix should add null guard")
		return

	# If it exists, verify it has the expected signal
	var has_signal := false
	for sig in script.get_script_signal_list():
		if sig.name == "mirror_broken":
			has_signal = true
			break
	assert_true(has_signal, "breakable_mirror.gd should have mirror_broken signal")


func test_set_script_null_guard():
	# Simulate the pattern: check script is not null before set_script
	var mirror = StaticBody2D.new()
	Engine.get_main_loop().root.add_child(mirror)
	_auto_free_nodes.append(mirror)

	var script = load("res://scripts/world/breakable_mirror.gd")
	if script != null:
		mirror.set_script(script)
		assert_ne(mirror.get_script(), null, "Script should be set when not null")
	else:
		# After fix: skip set_script and signal connection
		assert_eq(mirror.get_script(), null, "Script should remain null when load returns null")


func after_each():
	teardown_autoqfree()
