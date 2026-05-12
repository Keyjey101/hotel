extends Control

## GameOverScreen — Run summary on death with Art Deco styling.

func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Background (dark red tint)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.02, 0.02)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Red vignette overlay
	var vignette := ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.3, 0.0, 0.0, 0.15)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	# Main container
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -140
	vbox.offset_top = -120
	vbox.offset_right = 140
	vbox.offset_bottom = 120
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# "CONSUMED" title
	var title := Label.new()
	title.text = "CONSUMED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
	vbox.add_child(title)

	# Ornamental line
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(180, 2)
	line.color = Color(0.855, 0.647, 0.125)
	vbox.add_child(line)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer)

	# Stats
	var stats_label := Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 8)
	stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	if GameManager.run_state:
		var run_time := GameManager.run_state.get_run_time()
		var minutes := int(run_time) / 60
		var seconds := int(run_time) % 60
		stats_label.text = (
			"Floor Reached: %d\n" % GameManager.current_floor +
			"Rooms Cleared: %d\n" % GameManager.run_state.rooms_cleared.size() +
			"Enemies Mutilated: %d\n" % GameManager.run_state.enemies_mutilated +
			"Limbs Severed: %d\n" % GameManager.run_state.limbs_severed +
			"Time: %d:%02d" % [minutes, seconds]
		)
	else:
		stats_label.text = "No run data"
	vbox.add_child(stats_label)

	# Spacer
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer2)

	# TRY AGAIN button
	var restart_btn := _make_button("TRY AGAIN")
	vbox.add_child(restart_btn)
	restart_btn.pressed.connect(_on_restart_pressed)

	# MAIN MENU button
	var quit_btn := _make_button("MAIN MENU")
	vbox.add_child(quit_btn)
	quit_btn.pressed.connect(_on_quit_pressed)


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


func _on_restart_pressed() -> void:
	AudioManager.SFXPlayer.play_sfx("ui_confirm")
	GameManager.restart_run()


func _on_quit_pressed() -> void:
	AudioManager.SFXPlayer.play_sfx("ui_cancel")
	get_tree().quit()
