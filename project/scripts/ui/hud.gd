extends CanvasLayer

## HUD — Heads-up display showing player status during gameplay.

# UI element references (built in _build_ui)
var hp_fill: ColorRect
var hp_low_vignette: ColorRect
var weapon_slots: Array[Panel] = []
var weapon_icons: Array[ColorRect] = []
var ammo_displays: Array[Label] = []
var floor_label: Label
var buff_container: HFlowContainer
var dmg_edges: Dictionary = {}
var interaction_prompt: Label
var timer_label: Label
var weapon_name_labels: Array[Label] = []

const HP_BAR_WIDTH := 120.0
const VIEWPORT_W := 640.0
const VIEWPORT_H := 360.0

var floor_names := {
	1: "SERVICE UNDERGROUND",
	2: "RED LIGHT DISTRICT",
	3: "BANQUET HALL",
	4: "VAULT",
	5: "SPA",
	6: "ARENA",
	7: "OBSERVATORY",
	8: "BALLROOM",
	9: "SATAN'S SANCTUM",
}

var _low_hp_tween: Tween = null
var _floor_tween: Tween = null
var _conn_damaged: Callable
var _conn_healed: Callable
var _conn_weapon_changed: Callable
var _conn_room_entered: Callable
var _conn_upgrade_collected: Callable
var _conn_artifact_collected: Callable


func _ready() -> void:
	add_to_group("hud")
	_build_ui()
	_connect_events()
	_refresh_all()


func _process(_delta: float) -> void:
	if GameManager.run_state:
		var run_time := GameManager.run_state.get_run_time()
		var minutes := int(run_time) / 60
		var seconds := int(run_time) % 60
		timer_label.text = "%d:%02d" % [minutes, seconds]


func _build_ui() -> void:
	# --- HP Bar (bottom-left) ---
	var hp_frame := _make_rect(8, 344, HP_BAR_WIDTH, 8, Color(0.102, 0.102, 0.102))
	add_child(hp_frame)
	hp_fill = _make_rect(8, 344, HP_BAR_WIDTH, 8, Color(0.8, 0.133, 0.133))
	add_child(hp_fill)

	# Low HP vignette (full screen, transparent)
	hp_low_vignette = ColorRect.new()
	hp_low_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	hp_low_vignette.color = Color(0.8, 0.0, 0.0, 0.0)
	hp_low_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hp_low_vignette)

	# --- Weapon Slots (top-left) ---
	for i in range(2):
		var slot := Panel.new()
		slot.position = Vector2(8, 8 + i * 36)
		slot.size = Vector2(56, 32)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(slot)
		weapon_slots.append(slot)

		var icon := _make_rect(4, 2, 16, 16, Color(0.15, 0.15, 0.15))
		slot.add_child(icon)
		weapon_icons.append(icon)

		var ammo := Label.new()
		ammo.position = Vector2(2, 22)
		ammo.size = Vector2(36, 8)
		ammo.add_theme_font_size_override("font_size", 6)
		slot.add_child(ammo)
		ammo_displays.append(ammo)

		var wname := Label.new()
		wname.position = Vector2(22, 4)
		wname.size = Vector2(32, 14)
		wname.add_theme_font_size_override("font_size", 6)
		wname.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		wname.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(wname)
		weapon_name_labels.append(wname)

	# --- Floor Indicator (bottom-center) ---
	floor_label = Label.new()
	floor_label.position = Vector2(200, 342)
	floor_label.size = Vector2(240, 10)
	floor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floor_label.modulate.a = 0.7
	floor_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_label)

	# --- Run Timer (top-right) ---
	timer_label = Label.new()
	timer_label.position = Vector2(580, 8)
	timer_label.size = Vector2(52, 10)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.add_theme_font_size_override("font_size", 8)
	timer_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(timer_label)

	# --- Buff Container (bottom-right) ---
	buff_container = HFlowContainer.new()
	buff_container.position = Vector2(520, 340)
	buff_container.size = Vector2(112, 16)
	buff_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(buff_container)

	# --- Damage Direction Indicators (screen edges) ---
	dmg_edges = {
		"top": _make_rect(0, 0, VIEWPORT_W, 20, Color(0.8, 0.0, 0.0, 0.0)),
		"bottom": _make_rect(0, VIEWPORT_H - 20, VIEWPORT_W, 20, Color(0.8, 0.0, 0.0, 0.0)),
		"left": _make_rect(0, 0, 20, VIEWPORT_H, Color(0.8, 0.0, 0.0, 0.0)),
		"right": _make_rect(VIEWPORT_W - 20, 0, 20, VIEWPORT_H, Color(0.8, 0.0, 0.0, 0.0)),
	}
	for edge in dmg_edges.values():
		add_child(edge)

	# --- Interaction Prompt (bottom-center area) ---
	interaction_prompt = Label.new()
	interaction_prompt.position = Vector2(200, 300)
	interaction_prompt.size = Vector2(240, 16)
	interaction_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_prompt.visible = false
	interaction_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(interaction_prompt)


func _connect_events() -> void:
	_conn_damaged = func(_a): _update_hp_bar()
	_conn_healed = func(_a): _update_hp_bar()
	_conn_weapon_changed = func(_s, _w): _update_weapon_slots()
	_conn_room_entered = func(_f, _r): _update_floor_indicator()
	_conn_upgrade_collected = func(_u): _update_buffs()
	_conn_artifact_collected = func(_a): _update_buffs()
	EventBus.player_damaged.connect(_conn_damaged)
	EventBus.player_healed.connect(_conn_healed)
	EventBus.player_weapon_changed.connect(_conn_weapon_changed)
	EventBus.room_entered.connect(_conn_room_entered)
	EventBus.upgrade_collected.connect(_conn_upgrade_collected)
	EventBus.artifact_collected.connect(_conn_artifact_collected)


func _exit_tree() -> void:
	if EventBus.player_damaged.is_connected(_conn_damaged):
		EventBus.player_damaged.disconnect(_conn_damaged)
	if EventBus.player_healed.is_connected(_conn_healed):
		EventBus.player_healed.disconnect(_conn_healed)
	if EventBus.player_weapon_changed.is_connected(_conn_weapon_changed):
		EventBus.player_weapon_changed.disconnect(_conn_weapon_changed)
	if EventBus.room_entered.is_connected(_conn_room_entered):
		EventBus.room_entered.disconnect(_conn_room_entered)
	if EventBus.upgrade_collected.is_connected(_conn_upgrade_collected):
		EventBus.upgrade_collected.disconnect(_conn_upgrade_collected)
	if EventBus.artifact_collected.is_connected(_conn_artifact_collected):
		EventBus.artifact_collected.disconnect(_conn_artifact_collected)


func _refresh_all() -> void:
	_update_hp_bar()
	_update_weapon_slots()
	_update_floor_indicator()


# ============================================================
# HP Bar
# ============================================================

func _update_hp_bar() -> void:
	if not GameManager.run_state:
		return
	var ratio := clampf(GameManager.run_state.player_hp / GameManager.run_state.player_max_hp, 0.0, 1.0)
	hp_fill.size.x = HP_BAR_WIDTH * ratio
	if ratio < 0.3:
		_start_low_hp_pulse()
	else:
		_stop_low_hp_pulse()


func _start_low_hp_pulse() -> void:
	if _low_hp_tween and _low_hp_tween.is_valid():
		return
	_low_hp_tween = create_tween().set_loops()
	_low_hp_tween.tween_property(hp_low_vignette, "color:a", 0.3, 0.5)
	_low_hp_tween.tween_property(hp_low_vignette, "color:a", 0.0, 0.5)


func _stop_low_hp_pulse() -> void:
	if _low_hp_tween and _low_hp_tween.is_valid():
		_low_hp_tween.kill()
		_low_hp_tween = null
	hp_low_vignette.color.a = 0.0


# ============================================================
# Weapon Slots
# ============================================================

func _update_weapon_slots() -> void:
	if not GameManager.run_state:
		return
	var slots = GameManager.run_state.weapon_slots
	var active = GameManager.run_state.active_slot

	for i in range(2):
		_apply_slot_border(weapon_slots[i], i == active)
		var weapon = slots[i]
		if weapon == null:
			weapon_icons[i].color = Color(0.15, 0.15, 0.15)
			ammo_displays[i].text = ""
			weapon_name_labels[i].text = ""
			continue

		# Weapon name
		var wname: String = weapon.resource_name if weapon.resource_name else ""
		weapon_name_labels[i].text = wname

		# Color by weapon type
		match weapon.weapon_type:
			WeaponData.WeaponType.MELEE, WeaponData.WeaponType.IMPROVISED:
				weapon_icons[i].color = Color(0.3, 0.5, 0.3)
			WeaponData.WeaponType.RANGED:
				weapon_icons[i].color = Color(0.3, 0.3, 0.6)
			_:
				weapon_icons[i].color = Color(0.5, 0.5, 0.5)

		# Ammo display for ranged weapons
		if weapon.weapon_type == WeaponData.WeaponType.RANGED and weapon.ammo > 0:
			ammo_displays[i].text = "ammo"
		else:
			ammo_displays[i].text = ""


func _apply_slot_border(panel: Panel, active: bool) -> void:
	var style := StyleBoxFlat.new()
	style.border_color = Color(0.855, 0.647, 0.125) if active else Color(0.29, 0.29, 0.29)
	style.set_border_width_all(2)
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8) if active else Color(0.1, 0.1, 0.1, 0.5)
	style.set_corner_radius_all(0)
	panel.add_theme_stylebox_override("panel", style)


# ============================================================
# Floor Indicator
# ============================================================

func _update_floor_indicator() -> void:
	var floor_num := 1
	if GameManager.run_state:
		floor_num = GameManager.run_state.current_floor
	var room_text := ""
	# Try to get current room id from current scene (FloorManager)
	var scene_root := get_tree().current_scene
	if scene_root and scene_root.get("active_room_id") != null:
		var rid: String = str(scene_root.active_room_id)
		if not rid.is_empty():
			room_text = " · %s" % rid.to_upper()
	floor_label.text = "FLOOR %d · %s%s" % [floor_num, floor_names.get(floor_num, "UNKNOWN"), room_text]
	floor_label.modulate.a = 0.7

	if _floor_tween and _floor_tween.is_valid():
		_floor_tween.kill()
	_floor_tween = create_tween()
	_floor_tween.tween_interval(3.0)
	_floor_tween.tween_property(floor_label, "modulate:a", 0.0, 1.0)


# ============================================================
# Buffs
# ============================================================

func _update_buffs() -> void:
	for child in buff_container.get_children():
		child.queue_free()
	if not GameManager.run_state:
		return
	for _artifact in GameManager.run_state.cult_artifacts:
		var icon := ColorRect.new()
		icon.custom_minimum_size = Vector2(16, 16)
		icon.color = Color(0.6, 0.4, 0.0)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		buff_container.add_child(icon)


# ============================================================
# Damage Direction
# ============================================================

func flash_damage_direction(knockback_dir: Vector2) -> void:
	if knockback_dir == Vector2.ZERO:
		return
	AudioManager.SFXPlayer.play_sfx("ui_damage_edge")
	# Source is opposite of knockback direction
	var source_dir := -knockback_dir
	var abs_x := absf(source_dir.x)
	var abs_y := absf(source_dir.y)
	var edge: ColorRect
	if abs_x > abs_y:
		edge = dmg_edges["right"] if source_dir.x > 0 else dmg_edges["left"]
	else:
		edge = dmg_edges["bottom"] if source_dir.y > 0 else dmg_edges["top"]
	var tween := create_tween()
	tween.tween_property(edge, "color:a", 0.6, 0.0)
	tween.tween_property(edge, "color:a", 0.0, 0.15)


# ============================================================
# Interaction Prompt
# ============================================================

func show_interaction_prompt(text: String) -> void:
	interaction_prompt.text = "[E] %s" % text
	interaction_prompt.visible = true
	interaction_prompt.modulate.a = 0.0
	AudioManager.SFXPlayer.play_sfx("ui_prompt_show", -5.0)
	var tween := create_tween()
	tween.tween_property(interaction_prompt, "modulate:a", 1.0, 0.15)


func hide_interaction_prompt() -> void:
	if not interaction_prompt.visible:
		return
	var tween := create_tween()
	tween.tween_property(interaction_prompt, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): interaction_prompt.visible = false)


# ============================================================
# Helpers
# ============================================================

func _make_rect(x: float, y: float, w: float, h: float, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = Vector2(x, y)
	rect.size = Vector2(w, h)
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect
