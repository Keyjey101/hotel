extends Control

## Ending A — "The Escape" (Kill Sister + Kill Satan)

const BG_COLOR := Color(0.102, 0.102, 0.102)  # #1A1A1A dark
const TITLE_COLOR := Color(0.855, 0.647, 0.125)  # #DAA520 gold
const TITLE_TEXT := "ESCAPED"
const ENDING_TEXT := "The Hotel is gone. The system is destroyed. But the memory remains. Her face, at the end. She forgave you. You're not sure you forgive yourself."


func _save_ending(ending_id: String) -> void:
	if not SaveManager:
		return
	var meta := SaveManager.get_meta()
	var endings: Array = meta.get("secret_endings_seen", []).duplicate()
	if not endings.has(ending_id):
		endings.append(ending_id)
	meta["secret_endings_seen"] = endings
	SaveManager.save_meta(meta)


func _ready() -> void:
	_save_ending("a")
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = BG_COLOR
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

	var title := Label.new()
	title.text = TITLE_TEXT
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", TITLE_COLOR)
	vbox.add_child(title)

	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(200, 2)
	line.color = TITLE_COLOR
	vbox.add_child(line)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer)

	var body := Label.new()
	body.text = ENDING_TEXT
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", 8)
	body.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(body)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer2)

	_add_stats(vbox)

	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 16)
	vbox.add_child(spacer3)

	_add_buttons(vbox)


func _add_stats(vbox: VBoxContainer) -> void:
	var stats := Label.new()
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 8)
	stats.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
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


func _add_buttons(vbox: VBoxContainer) -> void:
	var play_btn := _make_button("PLAY AGAIN")
	vbox.add_child(play_btn)
	play_btn.pressed.connect(func(): if GameManager: GameManager.restart_run())

	var menu_btn := _make_button("MAIN MENU")
	vbox.add_child(menu_btn)
	menu_btn.pressed.connect(func(): if GameManager: GameManager.go_to_title())


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
