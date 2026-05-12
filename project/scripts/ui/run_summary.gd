extends Control

## RunSummary — Brief floor completion overlay.

signal continue_pressed()

var _floor_label: Label


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Semi-transparent dark overlay
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.0, 0.0, 0.0, 0.7)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -120
	vbox.offset_top = -60
	vbox.offset_right = 120
	vbox.offset_bottom = 60
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# Floor complete label
	_floor_label = Label.new()
	_floor_label.text = "FLOOR 1 COMPLETE"
	_floor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_floor_label.add_theme_font_size_override("font_size", 16)
	_floor_label.add_theme_color_override("font_color", Color(0.855, 0.647, 0.125))
	vbox.add_child(_floor_label)

	# Ornamental line
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(160, 2)
	line.color = Color(0.855, 0.647, 0.125)
	vbox.add_child(line)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer)

	# Stats
	var stats := Label.new()
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 8)
	stats.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	if GameManager.run_state:
		stats.text = "Rooms: %d  |  Mutilated: %d  |  Limbs: %d" % [
			GameManager.run_state.rooms_cleared.size(),
			GameManager.run_state.enemies_mutilated,
			GameManager.run_state.limbs_severed,
		]
	else:
		stats.text = ""
	vbox.add_child(stats)

	# Spacer
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer2)

	# CONTINUE button
	var btn := Button.new()
	btn.text = "CONTINUE"
	btn.custom_minimum_size = Vector2(120, 28)
	var normal := StyleBoxFlat.new()
	normal.border_color = Color(0.855, 0.647, 0.125)
	normal.set_border_width_all(2)
	normal.bg_color = Color(0.1, 0.1, 0.1)
	normal.set_corner_radius_all(0)
	btn.add_theme_stylebox_override("normal", normal)
	var hover := StyleBoxFlat.new()
	hover.border_color = Color(0.855, 0.647, 0.125)
	hover.set_border_width_all(2)
	hover.bg_color = Color(0.2, 0.15, 0.05)
	hover.set_corner_radius_all(0)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color(0.855, 0.647, 0.125))
	vbox.add_child(btn)

	btn.pressed.connect(func():
		AudioManager.SFXPlayer.play_sfx("ui_confirm")
		continue_pressed.emit()
	)


func show_summary(floor_number: int) -> void:
	_floor_label.text = "FLOOR %d COMPLETE" % floor_number
	AudioManager.SFXPlayer.play_sfx("ui_floor_complete")
	# Auto-continue after 3 seconds
	get_tree().create_timer(3.0).timeout.connect(func():
		continue_pressed.emit()
	)
