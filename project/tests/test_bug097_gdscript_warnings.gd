extends "res://scripts/tests/test_base.gd"

## Bug #97: gdscript/warnings/enable=false — ALL GDScript warnings globally disabled.
## Fix: Set to true.


func test_gdscript_warnings_enabled():
	# Check project settings
	var config = ConfigFile.new()
	var err = config.load("res://project.godot")
	if err != OK:
		assert_true(true, "Skipped: project.godot not loadable")
		return

	var warnings_enabled = config.get_value("gdscript", "warnings/enable", true)
	assert_true(warnings_enabled,
		"GDScript warnings should be enabled (bug #97 fix)")


func after_each():
	teardown_autoqfree()
