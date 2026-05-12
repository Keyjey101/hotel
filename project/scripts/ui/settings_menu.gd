extends CanvasLayer

## SettingsMenu — Audio, video, and gameplay settings with Art Deco styling.

signal back_pressed


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_build_ui()


func _build_ui() -> void:
	# Background overlay
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.85)
	bg.size = get_viewport().get_visible_rect().size
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# Main container
	var root := VBoxContainer.new()
	root.name = "Root"
	root.position = Vector2(get_viewport().get_visible_rect().size.x * 0.5 - 100, 40)
	root.custom_minimum_size = Vector2(200, 0)
	add_child(root)

	# Title
	var title := Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.855, 0.647, 0.125))
	root.add_child(title)

	# Line
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(200, 2)
	line.color = Color(0.855, 0.647, 0.125)
	root.add_child(line)

	# Spacer
	_add_spacer(root, 12)

	# Load current settings
	var settings := SaveManager.get_settings()

	# Master Volume
	_add_slider(root, "Master Volume", "master_volume", settings, 0.0, 1.0)
	# Music Volume
	_add_slider(root, "Music Volume", "music_volume", settings, 0.0, 1.0)
	# SFX Volume
	_add_slider(root, "SFX Volume", "sfx_volume", settings, 0.0, 1.0)

	_add_spacer(root, 8)

	# Screen Shake
	_add_checkbox(root, "Screen Shake", "screen_shake", settings)
	# Screen Flash
	_add_checkbox(root, "Screen Flash", "screen_flash", settings)
	# Fullscreen
	_add_checkbox(root, "Fullscreen", "fullscreen", settings)

	_add_spacer(root, 8)

	# Blood Intensity
	_add_slider(root, "Blood Intensity", "blood_intensity", settings, 0.0, 1.0)

	_add_spacer(root, 16)

	# Buttons row
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(btn_row)

	var reset_btn := _make_button("RESET DEFAULTS")
	btn_row.add_child(reset_btn)
	reset_btn.pressed.connect(_on_reset_defaults)

	var back_btn := _make_button("BACK")
	btn_row.add_child(back_btn)
	back_btn.pressed.connect(_on_back)


func _add_slider(parent: VBoxContainer, label_text: String, key: String, settings: Dictionary, min_val: float, max_val: float) -> void:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(100, 16)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(label)

	var slider := HSlider.new()
	slider.name = "Slider_" + key
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 0.01
	slider.value = settings.get(key, 1.0)
	slider.custom_minimum_size = Vector2(80, 16)
	slider.mouse_filter = Control.MOUSE_FILTER_STOP
	hbox.add_child(slider)

	var value_label := Label.new()
	value_label.name = "ValueLabel_" + key
	value_label.text = "%d%%" % int(slider.value * 100)
	value_label.custom_minimum_size = Vector2(36, 16)
	value_label.add_theme_font_size_override("font_size", 8)
	value_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(value_label)

	slider.value_changed.connect(func(val: float):
		value_label.text = "%d%%" % int(val * 100)
		_on_setting_changed(key, val)
	)


func _add_checkbox(parent: VBoxContainer, label_text: String, key: String, settings: Dictionary) -> void:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)

	var cb := CheckBox.new()
	cb.name = "CheckBox_" + key
	cb.button_pressed = settings.get(key, true)
	cb.mouse_filter = Control.MOUSE_FILTER_STOP
	hbox.add_child(cb)

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(label)

	cb.toggled.connect(func(pressed: bool):
		_on_setting_changed(key, pressed)
	)


func _on_setting_changed(key: String, value: Variant) -> void:
	var settings := SaveManager.get_settings()
	settings[key] = value
	SaveManager.save_and_apply(settings)


func _on_reset_defaults() -> void:
	var default_settings := {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"screen_shake": true,
		"screen_flash": true,
		"blood_intensity": 1.0,
		"fullscreen": false,
		"tutorial_shown": false,
	}
	SaveManager.save_and_apply(default_settings)
	# Rebuild UI with defaults — free all children first to prevent duplicate Background nodes
	for child in get_children():
		child.queue_free()
	call_deferred("_rebuild_ui_deferred")


func _rebuild_ui_deferred() -> void:
	_build_ui()


func _on_back() -> void:
	back_pressed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		get_viewport().set_input_as_handled()
		_on_back()


func _make_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(100, 24)
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


func _add_spacer(parent: VBoxContainer, height: float) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	parent.add_child(spacer)
