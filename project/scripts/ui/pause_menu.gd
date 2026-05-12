extends CanvasLayer

## PauseMenu — Shown when player presses ESC during gameplay.

signal resume_pressed
signal settings_pressed
signal quit_pressed

var _settings_open: bool = false


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
	GameManager.unpause_game()
	queue_free()


func _on_settings() -> void:
	if _settings_open:
		return
	_settings_open = true
	var settings_scene := preload("res://scenes/ui/settings_menu.tscn")
	var settings := settings_scene.instantiate()
	settings.back_pressed.connect(func():
		_settings_open = false
	)
	add_child(settings)


func _on_quit() -> void:
	GameManager.unpause_game()
	GameManager.restart_run()
