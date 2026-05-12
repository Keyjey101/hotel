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


func _ready() -> void:
	add_to_group("hud")
	_build_ui()
	_connect_events()
	_refresh_all()


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
		slot.position = Vector2(8, 8 + i * 32)
		slot.size = Vector2(40, 28)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(slot)
		weapon_slots.append(slot)

		var icon := _make_rect(12, 2, 16, 16, Color(0.15, 0.15, 0.15))
		slot.add_child(icon)
		weapon_icons.append(icon)

		var ammo := Label.new()
		ammo.position = Vector2(2, 20)
		ammo.size = Vector2(36, 8)
		slot.add_child(ammo)
		ammo_displays.append(ammo)

	# --- Floor Indicator (bottom-center) ---
	floor_label = Label.new()
	floor_label.position = Vector2(200, 348)
	floor_label.size = Vector2(240, 10)
	floor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floor_label.modulate.a = 0.7
	floor_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_label)

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
	EventBus.player_damaged.connect(func(_a): _update_hp_bar())
	EventBus.player_healed.connect(func(_a): _update_hp_bar())
	EventBus.player_weapon_changed.connect(func(_s, _w): _update_weapon_slots())
	EventBus.room_entered.connect(func(_f, _r): _update_floor_indicator())
	EventBus.upgrade_collected.connect(func(_u): _update_buffs())
	EventBus.artifact_collected.connect(func(_a): _update_buffs())


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
			continue

		# Color by weapon type
		match weapon.weapon_type:
			WeaponData.WeaponType.MELEE, WeaponData.WeaponType.IMPROVISED:
				weapon_icons[i].color = Color(0.3, 0.5, 0.3)
			WeaponData.WeaponType.RANGED:
				weapon_icons[i].color = Color(0.3, 0.3, 0.6)
			_:
				weapon_icons[i].color = Color(0.5, 0.5, 0.5)

		# Ammo dots for ranged weapons
		if weapon.weapon_type == WeaponData.WeaponType.RANGED and weapon.max_ammo > 0:
			var dots := ""
			for j in range(weapon.max_ammo):
				dots += "●" if j < weapon.current_ammo else "○"
			ammo_displays[i].text = dots
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
	floor_label.text = "FLOOR %d · %s" % [floor_num, floor_names.get(floor_num, "UNKNOWN")]
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
