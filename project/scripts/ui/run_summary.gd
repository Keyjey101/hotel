extends Control

## RunSummary — Brief floor completion overlay with run stats.

signal continue_pressed()

var _floor_label: Label
var _stats_label: Label
var _personal_best_label: Label


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
	vbox.offset_left = -140
	vbox.offset_top = -100
	vbox.offset_right = 140
	vbox.offset_bottom = 100
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
	line.custom_minimum_size = Vector2(200, 2)
	line.color = Color(0.855, 0.647, 0.125)
	vbox.add_child(line)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	# Stats
	_stats_label = Label.new()
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_label.add_theme_font_size_override("font_size", 8)
	_stats_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(_stats_label)

	# Spacer
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer2)

	# Personal best
	_personal_best_label = Label.new()
	_personal_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_personal_best_label.add_theme_font_size_override("font_size", 7)
	_personal_best_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.3))
	vbox.add_child(_personal_best_label)

	# Spacer
	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 12)
	vbox.add_child(spacer3)

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

	_refresh_stats()


func show_summary(floor_number: int) -> void:
	_floor_label.text = "FLOOR %d COMPLETE" % floor_number
	_refresh_stats()
	AudioManager.SFXPlayer.play_sfx("ui_floor_complete")
	# Auto-continue after 3 seconds
	get_tree().create_timer(3.0).timeout.connect(func():
		continue_pressed.emit()
	)


func _refresh_stats() -> void:
	if not GameManager.run_state:
		_stats_label.text = ""
		_personal_best_label.text = ""
		return

	var rs = GameManager.run_state
	var run_time := rs.get_run_time()
	var minutes := int(run_time) / 60
	var seconds := int(run_time) % 60

	# Weapons collected
	var weapons: Array = []
	for w in rs.weapon_slots:
		if w != null:
			weapons.append(w.resource_name if w.resource_name else "???")

	# Artifacts
	var artifact_count := rs.cult_artifacts.size()

	_stats_label.text = (
		"Deepest Floor: %d\n" % rs.current_floor +
		"Rooms Cleared: %d\n" % rs.rooms_cleared.size() +
		"Enemies Mutilated: %d\n" % rs.enemies_mutilated +
		"Limbs Severed: %d\n" % rs.limbs_severed +
		"Weapons: %s\n" % ("None" if weapons.is_empty() else ", ".join(weapons)) +
		"Artifacts: %d\n" % artifact_count +
		"Time: %d:%02d" % [minutes, seconds]
	)

	# Personal best comparison
	var records := SaveManager.load_records()
	var best_floor: int = records.get("deepest_floor", 0)
	var best_time: float = records.get("fastest_time", INF)
	if best_floor > 0:
		var pb_text := "Best: Floor %d" % best_floor
		if best_time < INF:
			var bm := int(best_time) / 60
			var bs := int(best_time) % 60
			pb_text += "  |  Fastest: %d:%02d" % [bm, bs]
		_personal_best_label.text = pb_text
	else:
		_personal_best_label.text = ""
