extends CanvasLayer

## TutorialOverlay — One-time onboarding hints for Floor 1.


func _ready() -> void:
	layer = 120
	_build_ui()


func _build_ui() -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	# Semi-transparent background
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.size = viewport_size
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# Center container
	var vbox := VBoxContainer.new()
	vbox.position = Vector2(viewport_size.x * 0.5 - 80, 60)
	vbox.custom_minimum_size = Vector2(160, 0)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "HOW TO SURVIVE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.855, 0.647, 0.125))
	vbox.add_child(title)

	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(160, 2)
	line.color = Color(0.855, 0.647, 0.125)
	vbox.add_child(line)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	# Hint entries
	var hints := [
		{"keys": "WASD", "desc": "Move"},
		{"keys": "LMB", "desc": "Attack"},
		{"keys": "RMB", "desc": "Throw weapon"},
		{"keys": "E", "desc": "Pick up / Interact"},
		{"keys": "Q", "desc": "Switch weapon"},
		{"keys": "ESC", "desc": "Pause"},
	]

	for hint in hints:
		var hbox := HBoxContainer.new()
		vbox.add_child(hbox)

		var key_label := Label.new()
		key_label.text = hint["keys"]
		key_label.custom_minimum_size = Vector2(50, 14)
		key_label.add_theme_font_size_override("font_size", 10)
		key_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		hbox.add_child(key_label)

		var desc_label := Label.new()
		desc_label.text = hint["desc"]
		desc_label.add_theme_font_size_override("font_size", 8)
		desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		hbox.add_child(desc_label)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer2)

	# Dismiss hint
	var dismiss := Label.new()
	dismiss.text = "Press any key to continue"
	dismiss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dismiss.add_theme_font_size_override("font_size", 7)
	dismiss.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	vbox.add_child(dismiss)

	# Animate dismiss text
	var tween := create_tween().set_loops()
	tween.tween_property(dismiss, "modulate:a", 0.3, 1.0)
	tween.tween_property(dismiss, "modulate:a", 1.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_dismiss()
	elif event is InputEventMouseButton and event.pressed:
		_dismiss()


func _dismiss() -> void:
	# Mark tutorial as shown
	var settings := SaveManager.get_settings()
	settings["tutorial_shown"] = true
	SaveManager.save_and_apply(settings)
	queue_free()
