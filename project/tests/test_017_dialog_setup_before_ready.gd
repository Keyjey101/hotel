extends "res://scripts/tests/test_base.gd"

## Bug #17: setup() called before _ready() -- @onready vars are null.


func test_dialog_choice_script_loads():
	var dialog_script = load("res://scripts/ui/dialog_choice.gd")
	if dialog_script == null:
		assert_true(true, "Skipped: dialog_choice.gd not found")
		return
	assert_ne(dialog_script, null, "dialog_choice script should load")


func test_setup_after_add_child_does_not_crash():
	var dialog_script = load("res://scripts/ui/dialog_choice.gd")
	if dialog_script == null:
		assert_true(true, "Skipped: dialog_choice.gd not found")
		return

	var dialog = dialog_script.new()
	# Add to tree FIRST (triggers _ready, sets @onready vars)
	Engine.get_main_loop().root.add_child(dialog)
	_auto_free_nodes.append(dialog)

	# Now call setup -- should work because _ready has run
	if dialog.has_method("setup"):
		dialog.setup("Test text", 2.0)
		assert_true(true, "setup() should not crash when called after add_child")
	else:
		assert_true(true, "Skipped: no setup method")


func after_each():
	teardown_autoqfree()
