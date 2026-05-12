extends CanvasLayer

## PauseMenu — Shown when player presses ESC during gameplay.

signal resume_pressed
signal settings_pressed
signal quit_pressed

var _settings_open: bool = false
var _settings_ref: CanvasLayer = null


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Semi-transparent background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# Center container
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -80
	vbox.offset_top = -60
	vbox.offset_right = 80
	vbox.offset_bottom = 60
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# Resume button
	var btn_resume := Button.new()
	btn_resume.name = "ResumeButton"
	btn_resume.text = "Resume"
	btn_resume.pressed.connect(_on_resume)
	vbox.add_child(btn_resume)

	# Settings button
	var btn_settings := Button.new()
	btn_settings.name = "SettingsButton"
	btn_settings.text = "Settings"
	btn_settings.pressed.connect(_on_settings)
	vbox.add_child(btn_settings)

	# Quit to title button
	var btn_quit := Button.new()
	btn_quit.name = "QuitButton"
	btn_quit.text = "Quit to Title"
	btn_quit.pressed.connect(_on_quit)
	vbox.add_child(btn_quit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		_on_resume()


func _on_resume() -> void:
	if GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.unpause_game()
	queue_free()


func _on_settings() -> void:
	if _settings_open:
		return
	_settings_open = true
	var settings_scene := preload("res://scenes/ui/settings_menu.tscn")
	if _settings_ref and is_instance_valid(_settings_ref):
		if _settings_ref.back_pressed.is_connected(_on_settings_closed):
			_settings_ref.back_pressed.disconnect(_on_settings_closed)
		_settings_ref.queue_free()
	_settings_ref = settings_scene.instantiate()
	_settings_ref.back_pressed.connect(_on_settings_closed)
	add_child(_settings_ref)


func _on_settings_closed() -> void:
	_settings_open = false
	_settings_ref = null


func _on_quit() -> void:
	GameManager.unpause_game()
	GameManager.restart_run()
