extends Control

## LoadoutScreen — Pre-run loadout selection.
## Left: starting weapons (fixed). Right: choose 1 stat upgrade from unlocked pool.
## Flow: title_screen → New Run → loadout_screen → Start → floor_01.

const GOLD := Color(0.855, 0.647, 0.125)
const DIM := Color(0.5, 0.5, 0.5)
const BG := Color(0.04, 0.04, 0.04)
const PANEL_BG := Color(0.08, 0.08, 0.08)
const PANEL_BORDER := Color(0.3, 0.25, 0.1)

var _selected_upgrade_id: String = ""
var _upgrade_buttons: Array[Button] = []


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Background
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = BG
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# Root container
	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_CENTER)
	root_vbox.offset_left = -260
	root_vbox.offset_top = -140
	root_vbox.offset_right = 260
	root_vbox.offset_bottom = 140
	root_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root_vbox)

	# Title
	var title := Label.new()
	title.text = "LOADOUT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", GOLD)
	root_vbox.add_child(title)

	# Ornamental line
	root_vbox.add_child(_make_line(400, GOLD))

	# Spacer
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 12)
	root_vbox.add_child(sp)

	# Two-column area
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	root_vbox.add_child(hbox)

	# Left panel: starting weapons
	var left := _build_weapons_panel()
	hbox.add_child(left)

	# Right panel: stat upgrade choice
	var right := _build_upgrade_panel()
	hbox.add_child(right)

	# Spacer
	var sp2 := Control.new()
	sp2.custom_minimum_size = Vector2(0, 16)
	root_vbox.add_child(sp2)

	# Start button
	var start_btn := _make_button("START RUN", 200)
	root_vbox.add_child(start_btn)
	start_btn.pressed.connect(_on_start_pressed)

	# Back button
	var back_btn := _make_button("BACK", 120)
	root_vbox.add_child(back_btn)
	back_btn.pressed.connect(_on_back_pressed)


func _build_weapons_panel() -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 8)

	# Panel header
	var header := Label.new()
	header.text = "STARTING WEAPONS"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 10)
	header.add_theme_color_override("font_color", GOLD)
	panel.add_child(header)

	# Panel background
	var bg_rect := _make_panel_bg(Vector2(220, 100))
	panel.add_child(bg_rect)

	# Weapon entries
	var weapons := ["Machete", "Sawed-off"]
	for w in weapons:
		var lbl := Label.new()
		lbl.text = "  > %s" % w
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		panel.add_child(lbl)

	return panel


func _build_upgrade_panel() -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 8)

	# Panel header
	var header := Label.new()
	header.text = "STARTING UPGRADE"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 10)
	header.add_theme_color_override("font_color", GOLD)
	panel.add_child(header)

	# Panel background
	var bg_rect := _make_panel_bg(Vector2(220, 100))
	panel.add_child(bg_rect)

	# Get unlocked stat upgrades
	var meta := SaveManager.get_meta()
	var unlocked: Array = meta.get("unlocked_starting_stat_upgrades", [])

	_upgrade_buttons.clear()
	for upgrade_id in unlocked:
		var display_name := _get_upgrade_display_name(upgrade_id)
		var btn := Button.new()
		btn.text = "  %s" % display_name
		btn.custom_minimum_size = Vector2(200, 24)
		btn.toggle_mode = true
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.08, 0.08, 0.08)
		normal.set_border_width_all(1)
		normal.border_color = PANEL_BORDER
		btn.add_theme_stylebox_override("normal", normal)
		var pressed_style := StyleBoxFlat.new()
		pressed_style.bg_color = Color(0.15, 0.12, 0.04)
		pressed_style.set_border_width_all(2)
		pressed_style.border_color = GOLD
		btn.add_theme_stylebox_override("pressed", pressed_style)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", GOLD)
		btn.set_meta("upgrade_id", upgrade_id)
		btn.pressed.connect(_on_upgrade_selected.bind(btn))
		panel.add_child(btn)
		_upgrade_buttons.append(btn)

	if unlocked.is_empty():
		var lbl := Label.new()
		lbl.text = "  (none unlocked)"
		lbl.add_theme_color_override("font_color", DIM)
		panel.add_child(lbl)

	# "None" option
	var none_btn := Button.new()
	none_btn.text = "  None"
	none_btn.custom_minimum_size = Vector2(200, 24)
	none_btn.toggle_mode = true
	var none_normal := StyleBoxFlat.new()
	none_normal.bg_color = Color(0.08, 0.08, 0.08)
	none_normal.set_border_width_all(1)
	none_normal.border_color = PANEL_BORDER
	none_btn.add_theme_stylebox_override("normal", none_normal)
	var none_pressed := StyleBoxFlat.new()
	none_pressed.bg_color = Color(0.15, 0.12, 0.04)
	none_pressed.set_border_width_all(2)
	none_pressed.border_color = GOLD
	none_btn.add_theme_stylebox_override("pressed", none_pressed)
	none_btn.add_theme_color_override("font_color", Color.WHITE)
	none_btn.add_theme_color_override("font_hover_color", GOLD)
	none_btn.set_meta("upgrade_id", "")
	none_btn.pressed.connect(_on_upgrade_selected.bind(none_btn))
	panel.add_child(none_btn)
	_upgrade_buttons.append(none_btn)

	return panel


func _on_upgrade_selected(btn: Button) -> void:
	var id: String = btn.get_meta("upgrade_id", "")
	_selected_upgrade_id = id
	# Untoggle all others
	for b in _upgrade_buttons:
		if b != btn:
			b.set_pressed_no_signal(false)
	btn.set_pressed_no_signal(true)


func _on_start_pressed() -> void:
	GameManager.selected_starting_upgrade = _selected_upgrade_id
	if AudioManager:
		AudioManager.SFXPlayer.play_sfx("ui_confirm")
	GameManager.start_new_run()


func _on_back_pressed() -> void:
	if AudioManager:
		AudioManager.SFXPlayer.play_sfx("ui_confirm")
	GameManager.go_to_title()


func _get_upgrade_display_name(id: String) -> String:
	# Try loading from UpgradeRegistry resource, else fall back to id
	if UpgradeRegistry:
		var upg := UpgradeRegistry.get_upgrade(id)
		if upg and upg.get("display_name_en") != null:
			return upg.display_name_en
	# Fallback display names
	match id:
		"s1_vitality_shard": return "Vitality Shard (+25 HP)"
		"s2_swift_step": return "Swift Step (+12% Speed)"
		"s3_iron_skin": return "Iron Skin (-15% Dmg Taken)"
		"s4_razor_edge": return "Razor Edge (+20% Melee)"
		"s5_sure_shot": return "Sure Shot (+20% Ranged)"
		"s6_heavy_arm": return "Heavy Arm (+25% Throw)"
		"s7_quick_hands": return "Quick Hands (+20% Pickup)"
		"s8_steady_grip": return "Steady Grip (-30% Grab)"
		"s9_second_wind": return "Second Wind (Regen <30%)"
		"s10_ammo_pouch": return "Ammo Pouch (+50% Ammo)"
		"s11_bloodlust": return "Bloodlust (+10% on Kill)"
		_: return id


func _make_line(width: float, color: Color) -> ColorRect:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(width, 2)
	line.size = Vector2(width, 2)
	line.color = color
	return line


func _make_panel_bg(min_size: Vector2) -> ColorRect:
	var rect := ColorRect.new()
	rect.custom_minimum_size = min_size
	rect.color = PANEL_BG
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func _make_button(text: String, width: float) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(width, 28)
	var normal := StyleBoxFlat.new()
	normal.border_color = GOLD
	normal.set_border_width_all(2)
	normal.bg_color = Color(0.1, 0.1, 0.1)
	btn.add_theme_stylebox_override("normal", normal)
	var hover := StyleBoxFlat.new()
	hover.border_color = GOLD
	hover.set_border_width_all(2)
	hover.bg_color = Color(0.2, 0.15, 0.05)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", GOLD)
	return btn
