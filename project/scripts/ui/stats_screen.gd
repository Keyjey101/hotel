extends Control

## StatsScreen — Meta-progression statistics overlay.
## Shows overall stats from SaveManager.get_meta() + records.

const GOLD := Color(0.855, 0.647, 0.125)
const DIM := Color(0.5, 0.5, 0.5)
const BG := Color(0.04, 0.04, 0.04)


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Background overlay
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_CENTER)
	root.offset_left = -200
	root.offset_top = -150
	root.offset_right = 200
	root.offset_bottom = 150
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)

	# Title
	var title := Label.new()
	title.text = "STATISTICS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", GOLD)
	root.add_child(title)

	# Line
	root.add_child(_make_line(300, GOLD))

	# Spacer
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 8)
	root.add_child(sp)

	# Stats content
	var meta := SaveManager.get_meta()
	var records := SaveManager.load_records()

	_add_stat(root, "Runs Completed", str(int(meta.get("runs_completed", 0))))
	_add_stat(root, "Deepest Floor", str(int(meta.get("deepest_floor_ever", 0))))
	_add_stat(root, "Best Floor (Records)", str(int(records.get("deepest_floor", 0))))
	var fastest: float = records.get("fastest_time", INF)
	_add_stat(root, "Fastest Run", "%.1fs" % fastest if fastest < INF else "---")
	_add_stat(root, "Artifacts Unlocked", "%d / 12" % (meta.get("unlocked_artifacts", []) as Array).size())
	_add_stat(root, "Upgrades Unlocked", "%d / 11" % (meta.get("unlocked_starting_stat_upgrades", []) as Array).size())
	_add_stat(root, "Total Limbs Severed", str(int(meta.get("total_limbs_severed", 0))))
	_add_stat(root, "Total Weapons Thrown", str(int(meta.get("total_weapons_thrown", 0))))

	var endings: Array = meta.get("secret_endings_seen", [])
	_add_stat(root, "Endings Seen", "%d / 4" % endings.size())

	var bosses: Dictionary = meta.get("bosses_defeated", {})
	var total_bosses := 0
	for key in bosses:
		total_bosses += int(bosses[key])
	_add_stat(root, "Bosses Defeated", str(total_bosses))

	# Spacer
	var sp2 := Control.new()
	sp2.custom_minimum_size = Vector2(0, 12)
	root.add_child(sp2)

	# Back button
	var back_btn := Button.new()
	back_btn.text = "BACK"
	back_btn.custom_minimum_size = Vector2(120, 28)
	var normal := StyleBoxFlat.new()
	normal.border_color = GOLD
	normal.set_border_width_all(2)
	normal.bg_color = Color(0.1, 0.1, 0.1)
	back_btn.add_theme_stylebox_override("normal", normal)
	var hover := StyleBoxFlat.new()
	hover.border_color = GOLD
	hover.set_border_width_all(2)
	hover.bg_color = Color(0.2, 0.15, 0.05)
	back_btn.add_theme_stylebox_override("hover", hover)
	back_btn.add_theme_color_override("font_color", Color.WHITE)
	back_btn.add_theme_color_override("font_hover_color", GOLD)
	back_btn.pressed.connect(_on_back)
	root.add_child(back_btn)


func _add_stat(parent: VBoxContainer, label: String, value: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var lbl := Label.new()
	lbl.text = label
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", DIM)
	lbl.custom_minimum_size = Vector2(160, 0)
	hbox.add_child(lbl)

	var val := Label.new()
	val.text = value
	val.add_theme_font_size_override("font_size", 10)
	val.add_theme_color_override("font_color", Color.WHITE)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(val)

	parent.add_child(hbox)


func _on_back() -> void:
	if AudioManager and AudioManager.SFXPlayer:
		AudioManager.SFXPlayer.play_sfx("ui_confirm")
	queue_free()


func _make_line(width: float, color: Color) -> ColorRect:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(width, 2)
	line.size = Vector2(width, 2)
	line.color = color
	return line
