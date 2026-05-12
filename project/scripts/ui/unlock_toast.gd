extends CanvasLayer

## UnlockToast — Shows a brief notification when an artifact/upgrade is unlocked during a run.
## Auto-removes after display. Only visual — actual meta commit happens at run end.

const GOLD := Color(0.855, 0.647, 0.125)
const TOAST_DURATION := 3.0


func _ready() -> void:
	layer = 100  # Above most game elements


func show_toast(message: String) -> void:
	# Build toast panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	panel.offset_top = 20
	panel.offset_left = -160
	panel.offset_right = 160
	panel.offset_bottom = 50

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.02, 0.9)
	style.set_border_width_all(2)
	style.border_color = GOLD
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", GOLD)
	panel.add_child(label)

	add_child(panel)

	# Animate: fade in, hold, fade out, then remove
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(TOAST_DURATION)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(panel.queue_free)
