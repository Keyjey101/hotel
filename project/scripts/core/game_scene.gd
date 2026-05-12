extends Node2D

## Game — Main game scene. Orchestrates game loop.

@onready var gore_system: Node = %GoreSystem
var _vignette_pulse_tween: Tween = null


func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.enemy_disabled.connect(_on_enemy_disabled)
	GameManager.run_started.connect(_on_run_started)
	EventBus.floor_completed.connect(_on_floor_completed)
	EventBus.player_captured.connect(_on_player_captured)


func _exit_tree() -> void:
	if EventBus.player_damaged.is_connected(_on_player_damaged):
		EventBus.player_damaged.disconnect(_on_player_damaged)
	if EventBus.enemy_disabled.is_connected(_on_enemy_disabled):
		EventBus.enemy_disabled.disconnect(_on_enemy_disabled)
	if GameManager.run_started.is_connected(_on_run_started):
		GameManager.run_started.disconnect(_on_run_started)
	if EventBus.floor_completed.is_connected(_on_floor_completed):
		EventBus.floor_completed.disconnect(_on_floor_completed)
	if EventBus.player_captured.is_connected(_on_player_captured):
		EventBus.player_captured.disconnect(_on_player_captured)


func _on_run_started(_seed: int) -> void:
	# Initialize run
	gore_system.clear_room_effects()
	# TODO: Load Floor 1


func _on_player_damaged(amount: float) -> void:
	# Screen shake
	_screen_shake(minf(amount * 0.5, 4.0))
	# Low HP vignette
	if GameManager.run_state and GameManager.run_state.player_hp < GameManager.run_state.player_max_hp * 0.3:
		_show_low_hp_vignette()


func _on_enemy_disabled(_enemy: CharacterBody2D) -> void:
	if GameManager.run_state:
		GameManager.run_state.enemies_mutilated += 1


func _on_floor_completed(floor_num: int) -> void:
	GameManager.handle_floor_completed(floor_num)


func _on_player_captured() -> void:
	pass  # GameManager.transition_to_basement() handles scene switch


func _screen_shake(intensity: float) -> void:
	var camera := get_tree().get_first_node_in_group("camera")
	if camera and camera is Camera2D:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		camera.offset = offset
		var tween := camera.create_tween()
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)


func _show_low_hp_vignette() -> void:
	var hp_percent := 1.0
	if GameManager.run_state:
		hp_percent = GameManager.run_state.player_hp / GameManager.run_state.player_max_hp

	# Ensure vignette overlay exists
	var vignette_layer: CanvasLayer = get_node_or_null("LowHPVignetteLayer")
	if not vignette_layer:
		vignette_layer = CanvasLayer.new()
		vignette_layer.name = "LowHPVignetteLayer"
		vignette_layer.layer = 50
		add_child(vignette_layer)

	var vignette: ColorRect = vignette_layer.get_node_or_null("Vignette")
	if not vignette:
		vignette = ColorRect.new()
		vignette.name = "Vignette"
		vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Gradient vignette: transparent center, red edges
		var grad := Gradient.new()
		grad.colors = PackedColorArray([Color(0.5, 0.0, 0.0, 0.0), Color(0.5, 0.0, 0.0, 1.0)])
		var tex := GradientTexture2D.new()
		tex.gradient = grad
		tex.fill = GradientTexture2D.FILL_RADIAL
		tex.fill_from = Vector2(0.5, 0.5)
		tex.fill_to = Vector2(1.0, 0.5)
		vignette.texture = tex
		vignette_layer.add_child(vignette)

	# Resize to fullscreen
	var vp_size := get_viewport().get_visible_rect().size
	vignette.size = vp_size
	vignette.position = Vector2.ZERO

	# Alpha based on HP: stronger at lower HP
	var alpha := clampf(0.3 - hp_percent, 0.0, 0.3)
	vignette.modulate.a = alpha

	# Pulse when HP < 30%
	if hp_percent < 0.3:
		if _vignette_pulse_tween and _vignette_pulse_tween.is_valid():
			_vignette_pulse_tween.kill()
		_vignette_pulse_tween = vignette.create_tween()
		_vignette_pulse_tween.set_loops()
		_vignette_pulse_tween.tween_property(vignette, "modulate:a", alpha * 1.3, 0.6)
		_vignette_pulse_tween.tween_property(vignette, "modulate:a", alpha * 0.7, 0.6)
	else:
		# Fade out smoothly
		var tween := vignette.create_tween()
		tween.tween_property(vignette, "modulate:a", 0.0, 0.5)
