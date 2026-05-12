extends StaticBody2D

## CorpseEntity — A consumable corpse for The Gourmand's consumption mechanic.
## Pre-placed in boss arena or spawned when enemies die.
## Player can destroy corpses to deny Gourmand his food source.

signal corpse_consumed(corpse: StaticBody2D)

var is_consumed: bool = false
var corpse_hp: float = 30.0  # Player can attack to destroy
var _visual: ColorRect = null
var _fade_tween: Tween = null


func _ready() -> void:
	add_to_group("corpses")
	collision_layer = 16  # environment layer
	collision_mask = 0

	# Visual: blood red body shape
	_visual = ColorRect.new()
	_visual.size = Vector2(16, 20)
	_visual.position = Vector2(-8, -10)
	_visual.color = Color(0.8, 0.133, 0.133, 1.0)  # #CC2222
	_visual.z_index = -1
	add_child(_visual)


func consume() -> void:
	if is_consumed:
		return
	is_consumed = true
	corpse_consumed.emit(self)

	# Shrink + fade animation
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "scale", Vector2.ZERO, 0.4)
	_fade_tween.parallel().tween_property(_visual, "color:a", 0.0, 0.4)
	_fade_tween.tween_callback(queue_free)


func take_damage(amount: float, _dir: Vector2 = Vector2.ZERO, _kb: float = 0.0) -> void:
	if is_consumed:
		return
	corpse_hp -= amount
	if corpse_hp <= 0.0:
		_destroy_corpse()


func _destroy_corpse() -> void:
	if is_consumed:
		return
	is_consumed = true
	corpse_consumed.emit(self)
	# Kill any existing tween before creating new one
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	# Quick destroy animation
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	_fade_tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	_fade_tween.parallel().tween_property(_visual, "color:a", 0.0, 0.2)
	_fade_tween.tween_callback(queue_free)
