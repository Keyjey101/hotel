extends Control

## DemoComplete — Screen shown after beating Floor 1 demo.

func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.04)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -160
	vbox.offset_top = -120
	vbox.offset_right = 160
	vbox.offset_bottom = 120
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# DEMO COMPLETE title
	var title := Label.new()
	title.text = "DEMO COMPLETE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.855, 0.647, 0.125))
	vbox.add_child(title)

	# Ornamental line
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(200, 2)
	line.color = Color(0.855, 0.647, 0.125)
	vbox.add_child(line)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "You survived the Service Underground"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(subtitle)

	# Spacer
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer2)

	# Stats
	var stats := Label.new()
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 8)
	stats.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	if GameManager.run_state:
		var run_time := GameManager.run_state.get_run_time()
		var minutes := int(run_time) / 60
		var seconds := int(run_time) % 60
		stats.text = (
			"Rooms Cleared: %d\n" % GameManager.run_state.rooms_cleared.size() +
			"Enemies Mutilated: %d\n" % GameManager.run_state.enemies_mutilated +
			"Limbs Severed: %d\n" % GameManager.run_state.limbs_severed +
			"Time: %d:%02d" % [minutes, seconds]
		)
	else:
		stats.text = ""
	vbox.add_child(stats)

	# Spacer
	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer3)

	# PLAY AGAIN button
	var play_btn := _make_button("PLAY AGAIN")
	vbox.add_child(play_btn)
	play_btn.pressed.connect(func(): GameManager.restart_run())

	# QUIT button
	var quit_btn := _make_button("QUIT")
	vbox.add_child(quit_btn)
	quit_btn.pressed.connect(func(): GameManager.restart_run())


func _make_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 28)
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
