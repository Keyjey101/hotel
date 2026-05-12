extends CanvasLayer

## PauseMenu — Shown when player presses ESC during gameplay.

signal resume_pressed
signal settings_pressed
signal quit_pressed


func _ready() -> void:
	layer = 100

	# Semi-transparent background
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.6)
	bg.size = get_viewport().get_visible_rect().size
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	# Center container
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.position = Vector2(get_viewport().get_visible_rect().size.x * 0.5, 0)
	vbox.anchor_left = 0.5
	vbox.anchor_right = 0.5
	add_child(vbox)

	# Resume button
	var btn_resume := Button.new()
	btn_resume.name = "ResumeButton"
	btn_resume.text = "Resume"
	btn_resume.pressed.connect(_on_resume)
	add_child(btn_resume)

	# Settings button
	var btn_settings := Button.new()
	btn_settings.name = "SettingsButton"
	btn_settings.text = "Settings"
	btn_settings.pressed.connect(_on_settings)
	add_child(btn_settings)

	# Quit to title button
	var btn_quit := Button.new()
	btn_quit.name = "QuitButton"
	btn_quit.text = "Quit to Title"
	btn_quit.pressed.connect(_on_quit)
	add_child(btn_quit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		_on_resume()


func _on_resume() -> void:
	GameManager.unpause_game()
	queue_free()


func _on_settings() -> void:
	var settings_scene := preload("res://scenes/ui/settings_menu.tscn")
	var settings := settings_scene.instantiate()
	settings.back_pressed.connect(func():
		# Re-show pause menu buttons if needed
		pass
	)
	add_child(settings)


func _on_quit() -> void:
	GameManager.unpause_game()
	GameManager.restart_run()
