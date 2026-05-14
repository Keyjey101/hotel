extends StaticBody2D

## WeaponPickup — A weapon lying on the ground, pickable via interact (E key) or overlap.

@export var weapon_data: WeaponData


func _ready() -> void:
	# Add an Area2D child for overlap detection
	var area := Area2D.new()
	area.name = "PickupArea"
	area.collision_layer = 0
	area.collision_mask = 1  # Player layer
	area.monitoring = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	area.add_child(shape)
	# Visual indicator
	var vis := ColorRect.new()
	vis.size = Vector2(12, 12)
	vis.position = Vector2(-6, -6)
	vis.color = Color(0.3, 0.6, 1.0, 0.8)
	vis.z_index = 1
	add_child(vis)
	add_child(area)
	area.body_entered.connect(_on_body_entered)


func get_weapon_data() -> WeaponData:
	return weapon_data


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if weapon_data == null:
		return
	if body.has_node("WeaponManager"):
		var wm = body.get_node("WeaponManager")
		if wm and wm.has_method("equip_weapon"):
			wm.equip_weapon(weapon_data)
			EventBus.weapon_picked_up.emit(weapon_data)
			queue_free()
