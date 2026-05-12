extends Control

## DialogChoice — Two-button dialog UI that emits dialog_choice_made via EventBus.

@onready var _label: Label = %Label
@onready var _option1: Button = %Option1Button
@onready var _option2: Button = %Option2Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func setup(text: String, option1_text: String, option2_text: String, choice1: String, choice2: String) -> void:
	_label.text = text
	_option1.text = option1_text
	_option2.text = option2_text
	_option1.pressed.connect(func() -> void:
		EventBus.dialog_choice_made.emit(choice1)
		queue_free()
	)
	_option2.pressed.connect(func() -> void:
		EventBus.dialog_choice_made.emit(choice2)
		queue_free()
	)
