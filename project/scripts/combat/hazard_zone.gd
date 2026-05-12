class_name HazardZone
extends Area2D

## HazardZone — Reusable floor hazard zone (oil slick, poison cloud, etc.)
## Used by Chef (Oil Slick) and Taster (Corpse Burst, poison pools).

@export var damage_per_second: float = 0.0
@export var slow_factor: float = 1.0  ## 1.0 = normal, 0.3 = slippery
@export var duration: float = 5.0
@export var zone_color: Color = Color.GREEN
@export var zone_radius: float = 48.0

var _affected_bodies: Dictionary = {}  # body -> {timer: float}
var _elapsed: float = 0.0


func _ready() -> void:
	# Collision shape
	var collision_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = zone_radius
	collision_shape.shape = circle
	add_child(collision_shape)

	# Visual placeholder
	var visual := ColorRect.new()
	var size := zone_radius * 2.0
	visual.size = Vector2(size, size)
	visual.position = Vector2(-zone_radius, -zone_radius)
	visual.color = Color(zone_color.r, zone_color.g, zone_color.b, 0.4)
	visual.z_index = -1
	add_child(visual)

	# Monitoring
	monitoring = true
	monitorable = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= duration:
		# Remove slow from all affected bodies before freeing
		for body in _affected_bodies:
			if is_instance_valid(body) and body.has_method("remove_hazard_slow"):
				body.remove_hazard_slow(slow_factor)
		queue_free()
		return

	# Apply DOT to all bodies inside
	for body in _affected_bodies:
		if not is_instance_valid(body):
			continue
		if damage_per_second > 0.0:
			_apply_dot(body, damage_per_second * delta)


func _on_body_entered(body: Node2D) -> void:
	_affected_bodies[body] = {"timer": 0.0}
	# Apply slow
	if slow_factor < 1.0 and body.has_method("apply_hazard_slow"):
		body.apply_hazard_slow(slow_factor)


func _on_body_exited(body: Node2D) -> void:
	_affected_bodies.erase(body)
	# Remove slow
	if slow_factor < 1.0 and body.has_method("remove_hazard_slow"):
		body.remove_hazard_slow(slow_factor)


func _apply_dot(body: Node2D, damage: float) -> void:
	if body.has_method("receive_damage"):
		body.receive_damage(damage, DamageZone.Zone.TORSO, false)  # Zone TORSO, no sever
	elif body.has_method("take_damage"):
		body.take_damage(damage)
