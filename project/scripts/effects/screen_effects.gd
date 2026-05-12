extends CanvasLayer

## ScreenEffects — Centralized screen-level effects autoload.
## Manages shake, flash, hit stop, blood vignette, chromatic aberration, camera zoom.

var _camera: Camera2D
var _shake_tween: Tween
var _flash_tween: Tween
var _zoom_tween: Tween
var _vignette_tween: Tween

var _flash_overlay: ColorRect
var _vignette_overlay: ColorRect
var _vignette_base_alpha: float = 0.0
var _vignette_target_alpha: float = 0.0


func _ready() -> void:
	layer = 100

	# Flash overlay — full screen white
	_flash_overlay = ColorRect.new()
	_flash_overlay.name = "FlashOverlay"
	_flash_overlay.color = Color.WHITE
	_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_overlay.z_index = 100
	add_child(_flash_overlay)

	# Blood vignette overlay — full screen dark red
	_vignette_overlay = ColorRect.new()
	_vignette_overlay.name = "VignetteOverlay"
	_vignette_overlay.color = Color(0.545, 0.0, 0.0)  # #8B0000
	_vignette_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette_overlay.z_index = 99
	_vignette_overlay.modulate.a = 0.0
	add_child(_vignette_overlay)

	# Make overlays full-screen
	_resize_overlays()
	get_viewport().size_changed.connect(_resize_overlays)

	# Find camera
	_refresh_camera()


func _resize_overlays() -> void:
	var size := get_viewport().get_visible_rect().size
	_flash_overlay.size = size
	_flash_overlay.position = Vector2.ZERO
	_flash_overlay.color.a = 0.0
	_vignette_overlay.size = size
	_vignette_overlay.position = Vector2.ZERO


func _refresh_camera() -> void:
	_camera = get_tree().get_first_node_in_group("camera") as Camera2D


func _process(_delta: float) -> void:
	# Pulse vignette if active
	if _vignette_target_alpha > 0.0:
		_vignette_base_alpha = _vignette_target_alpha + sin(Time.get_ticks_msec() / 400.0) * 0.1
		_vignette_overlay.modulate.a = clampf(_vignette_base_alpha, 0.0, 0.6)


# ============================================================
# Screen Shake
# ============================================================

func shake(amplitude: float = 4.0, duration: float = 0.15, _decay: float = 0.9) -> void:
	if has_meta("shake_enabled") and not get_meta("shake_enabled", true):
		return
	if not is_instance_valid(_camera):
		_refresh_camera()
	if not _camera:
		return

	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()

	_shake_tween = create_tween()
	_shake_tween.set_speed_scale(Engine.time_scale)
	var steps := 4
	var step_time := duration / float(steps)
	for i in range(steps):
		var amp := amplitude * (1.0 - float(i) / float(steps))
		_shake_tween.tween_property(_camera, "offset",
			Vector2(randf_range(-amp, amp), randf_range(-amp, amp)), step_time)
	_shake_tween.tween_property(_camera, "offset", Vector2.ZERO, step_time)


# ============================================================
# Flash
# ============================================================

func flash(color: Color = Color.WHITE, duration: float = 0.05, max_alpha: float = 0.6) -> void:
	if has_meta("flash_enabled") and not get_meta("flash_enabled", true):
		return
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()

	_flash_overlay.color = Color(color.r, color.g, color.b, 0.0)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_flash_overlay, "color:a", max_alpha, duration * 0.3)
	_flash_tween.tween_property(_flash_overlay, "color:a", 0.0, duration * 0.7)


# ============================================================
# Hit Stop
# ============================================================

func hit_stop(duration: float = 0.05) -> void:
	if Engine.time_scale < 1.0:
		return  # Already in slow-mo, don't stack
	Engine.time_scale = 0.01
	# Use a scene tree timer that respects time scale so it fires correctly
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


# ============================================================
# Blood Vignette
# ============================================================

func update_vignette(player_hp_percent: float) -> void:
	if not is_instance_valid(_camera):
		_refresh_camera()
	if player_hp_percent < 0.3:
		_vignette_target_alpha = (0.3 - player_hp_percent) / 0.3 * 0.5
		_vignette_overlay.visible = true
	else:
		_vignette_target_alpha = 0.0
		if _vignette_tween and _vignette_tween.is_valid():
			_vignette_tween.kill()
		_vignette_tween = create_tween()
		_vignette_tween.tween_property(_vignette_overlay, "modulate:a", 0.0, 0.5)
		_vignette_tween.tween_callback(func(): _vignette_overlay.visible = false)


# ============================================================
# Chromatic Aberration (R/B channel offset)
# ============================================================

var _chromatic_r: ColorRect
var _chromatic_b: ColorRect
var _chromatic_tween: Tween


func chromatic_aberration(duration: float = 0.3, intensity: float = 3.0) -> void:
	# Ensure R/B overlay ColorRects exist
	if not _chromatic_r:
		_chromatic_r = ColorRect.new()
		_chromatic_r.name = "ChromaticR"
		_chromatic_r.color = Color(1.0, 0.0, 0.0, 0.0)
		_chromatic_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_chromatic_r.z_index = 98
		add_child(_chromatic_r)
	if not _chromatic_b:
		_chromatic_b = ColorRect.new()
		_chromatic_b.name = "ChromaticB"
		_chromatic_b.color = Color(0.0, 0.0, 1.0, 0.0)
		_chromatic_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_chromatic_b.z_index = 98
		add_child(_chromatic_b)

	# Resize to fullscreen
	var size := get_viewport().get_visible_rect().size
	_chromatic_r.size = size
	_chromatic_r.position = Vector2(-intensity, 0)
	_chromatic_b.size = size
	_chromatic_b.position = Vector2(intensity, 0)

	# Set alpha based on intensity
	var alpha := clampf(0.1 * intensity, 0.0, 0.4)
	_chromatic_r.color.a = alpha
	_chromatic_b.color.a = alpha
	_chromatic_r.visible = true
	_chromatic_b.visible = true

	# Tween to zero over duration
	if _chromatic_tween and _chromatic_tween.is_valid():
		_chromatic_tween.kill()
	_chromatic_tween = create_tween()
	_chromatic_tween.set_parallel(true)
	_chromatic_tween.tween_property(_chromatic_r, "color:a", 0.0, duration)
	_chromatic_tween.tween_property(_chromatic_b, "color:a", 0.0, duration)
	_chromatic_tween.tween_property(_chromatic_r, "position:x", 0.0, duration)
	_chromatic_tween.tween_property(_chromatic_b, "position:x", 0.0, duration)
	_chromatic_tween.set_parallel(false)
	_chromatic_tween.tween_callback(func():
		_chromatic_r.visible = false
		_chromatic_b.visible = false
	)


# ============================================================
# Camera Zoom
# ============================================================

func zoom(target_zoom: float = 1.2, duration: float = 0.1, hold: float = 0.05, return_duration: float = 0.2) -> void:
	if not is_instance_valid(_camera):
		_refresh_camera()
	if not _camera:
		return

	if _zoom_tween and _zoom_tween.is_valid():
		_zoom_tween.kill()

	_zoom_tween = create_tween()
	_zoom_tween.tween_property(_camera, "zoom", Vector2(target_zoom, target_zoom), duration)
	_zoom_tween.tween_interval(hold)
	_zoom_tween.tween_property(_camera, "zoom", Vector2.ONE, return_duration)
