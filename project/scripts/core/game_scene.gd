extends Node2D

## Game — Main game scene. Orchestrates game loop.

@onready var gore_system: Node = %GoreSystem


func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.enemy_disabled.connect(_on_enemy_disabled)
	GameManager.run_started.connect(_on_run_started)


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


func _screen_shake(intensity: float) -> void:
	var camera := get_tree().get_first_node_in_group("camera")
	if camera and camera is Camera2D:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		camera.offset = offset
		var tween := camera.create_tween()
		tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)


func _show_low_hp_vignette() -> void:
	# TODO: Show red vignette overlay
	pass
