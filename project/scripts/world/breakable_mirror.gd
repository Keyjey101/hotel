extends StaticBody2D

## Breakable mirror — used in Hall of Mirrors (B1) and Madame's Chamber.
## HP-based destruction with visual crack overlay.

var hp: float = 30.0
var max_hp: float = 30.0
var is_broken: bool = false

signal mirror_broken(mirror: StaticBody2D)


func take_damage(amount: float) -> void:
	if is_broken:
		return
	hp -= amount
	# Visual crack: darken overlay proportional to damage
	var crack_node := get_node_or_null("CrackOverlay")
	if crack_node and crack_node is ColorRect:
		var hp_pct := hp / max_hp
		crack_node.color.a = 1.0 - hp_pct
	if hp <= 0.0:
		_break()


func _break() -> void:
	if is_broken:
		return
	is_broken = true
	mirror_broken.emit(self)
	# Disable collision before fading to prevent invisible wall
	var _col := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if _col:
		_col.disabled = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
