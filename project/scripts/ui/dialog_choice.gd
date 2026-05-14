extends Control

## DialogChoice — Two-button dialog UI that emits dialog_choice_made via EventBus.

@onready var _label: Label = %Label
@onready var _option1: Button = %Option1Button
@onready var _option2: Button = %Option2Button

var _text: String = ""
var _opt1_text: String = ""
var _opt2_text: String = ""
var _opt1_val: String = ""
var _opt2_val: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_apply_stored_values()


func setup(text: String, option1_text: String, option2_text: String, choice1: String, choice2: String) -> void:
	_text = text
	_opt1_text = option1_text
	_opt2_text = option2_text
	_opt1_val = choice1
	_opt2_val = choice2
	# If already in tree, apply now; otherwise _ready will handle it
	if _label and is_instance_valid(_label):
		_apply_stored_values()


func _apply_stored_values() -> void:
	if _label == null or _option1 == null or _option2 == null:
		return
	# Disconnect previous connections to prevent signal stacking
	for conn in _option1.pressed.get_connections():
		_option1.pressed.disconnect(conn.callable)
	for conn in _option2.pressed.get_connections():
		_option2.pressed.disconnect(conn.callable)

	_label.text = _text
	_option1.text = _opt1_text
	_option2.text = _opt2_text
	_option1.pressed.connect(func() -> void:
		if EventBus: EventBus.dialog_choice_made.emit(_opt1_val)
		queue_free()
	)
	_option2.pressed.connect(func() -> void:
		if EventBus: EventBus.dialog_choice_made.emit(_opt2_val)
		queue_free()
	)
