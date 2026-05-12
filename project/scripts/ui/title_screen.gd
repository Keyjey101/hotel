extends Control

## TitleScreen — Main menu with Art Deco styling.

func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.04)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Main container — centered
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -120
	vbox.offset_top = -100
	vbox.offset_right = 120
	vbox.offset_bottom = 100
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# Ornamental top line
	var line_top := _make_line(200, Color(0.855, 0.647, 0.125))
	vbox.add_child(line_top)

	# Title
	var title := Label.new()
	title.text = "HOTEL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.855, 0.647, 0.125))
	vbox.add_child(title)

	# Ornamental bottom line
	var line_bot := _make_line(200, Color(0.855, 0.647, 0.125))
	vbox.add_child(line_bot)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(spacer)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "Satanic luxury awaits"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(subtitle)

	# Spacer
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer2)

	# NEW RUN button
	var new_run_btn := _make_button("NEW RUN")
	vbox.add_child(new_run_btn)
	new_run_btn.pressed.connect(_on_new_run_pressed)

	# Stats at bottom
	var stats := Label.new()
	stats.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	stats.offset_top = -20
	stats.offset_bottom = -4
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 8)
	stats.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if SaveManager:
		var records = SaveManager.load_records()
		stats.text = "Best: Floor %d  |  Runs: %d" % [records.get("deepest_floor", 0), records.get("total_runs", 0)]
	else:
		stats.text = ""
	add_child(stats)

	# Animated title breathing
	var tween := create_tween().set_loops()
	tween.tween_property(title, "modulate:a", 0.7, 2.0)
	tween.tween_property(title, "modulate:a", 1.0, 2.0)


func _make_line(width: float, color: Color) -> ColorRect:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(width, 2)
	line.size = Vector2(width, 2)
	line.color = color
	return line


func _make_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 32)
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
	return btn


func _on_new_run_pressed() -> void:
	AudioManager.SFXPlayer.play_sfx("ui_confirm")
	GameManager.start_new_run()
