extends Node2D

## Game — Main game scene. Orchestrates game loop.

@onready var gore_system: Node = get_node_or_null("/root/GoreSystem")
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
	if _vignette_pulse_tween and _vignette_pulse_tween.is_valid():
		_vignette_pulse_tween.kill()


func _on_run_started(_seed: int) -> void:
	# Initialize run
	if gore_system:
		gore_system.clear_room_effects()
	# TODO: Load Floor 1


func _on_player_damaged(amount: float) -> void:
	_screen_shake(minf(amount * 0.5, 4.0))
	if GameManager.run_state:
		var hp_pct := GameManager.run_state.player_hp / GameManager.run_state.player_max_hp
		var se = get_node_or_null("/root/ScreenEffects")
		if se:
			se.update_vignette(hp_pct)


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
		# Don't override if camera already being tweened (transition in progress)
		if camera.has_meta("_transitioning") and camera.get_meta("_transitioning", false):
			return
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		camera.offset = offset
		var tween := camera.create_tween()
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)



