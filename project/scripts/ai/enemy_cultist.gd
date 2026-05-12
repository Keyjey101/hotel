extends "res://scripts/ai/base_enemy.gd"

## Cultist — Floor 7 (Observatory/Envy).
## Melee + ranged thrown knife. Moderate HP, moderate speed.

# Ranged attack state
var _throw_cooldown: float = 0.0
var _throw_ready: bool = true


func _ready() -> void:
	enemy_name = "Cultist"
	enemy_type = "cultist"

	torso_hp = 80.0
	head_hp = 30.0
	arm_hp = 25.0
	leg_hp = 25.0
	move_speed = 85.0
	detection_range = 250.0
	attack_range = 45.0
	attack_damage = 18.0
	attack_speed = 0.8
	grab_strength = 2.0
	regen_speed_mult = 1.0
	aggression = 6.0
	coordination = 4.0

	add_to_group("cultists")
	super._ready()
	_create_robe_visual()


func _create_robe_visual() -> void:
	# Dark purple robe overlay on sprite
	var robe := ColorRect.new()
	robe.size = Vector2(20, 28)
	robe.position = Vector2(-10, -14)
	robe.color = Color(0.294, 0.0, 0.510, 0.8)  # #4B0082 indigo
	robe.z_index = -1
	sprite.add_child(robe)


func _physics_process(delta: float) -> void:
	_throw_cooldown = maxf(0.0, _throw_cooldown - delta)
	if _throw_cooldown <= 0.0:
		_throw_ready = true
	super._physics_process(delta)


func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	# Ranged: throw knife if target is 80-200px away and cooldown ready
	if dist > 80.0 and _throw_ready:
		_throw_knife()
		_throw_ready = false
		_throw_cooldown = 3.0
	else:
		# Melee hit
		if _target.has_method("receive_damage"):
			var dir := global_position.direction_to(_target.global_position)
			_target.receive_damage(attack_damage, DamageZone.Zone.TORSO, false, 20.0, dir * -1.0)


func _throw_knife() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dir := global_position.direction_to(_target.global_position)
	var knife := Area2D.new()
	knife.name = "ThrownKnife"
	knife.add_to_group("enemy_hitbox")

	var shape := RectangleShape2D.new()
	shape.size = Vector2(6, 2)
	var col := CollisionShape2D.new()
	col.shape = shape
	knife.add_child(col)

	var visual := ColorRect.new()
	visual.size = Vector2(8, 3)
	visual.position = Vector2(-4, -1.5)
	visual.color = Color(0.6, 0.6, 0.7)
	knife.add_child(visual)

	knife.global_position = global_position
	knife.set_meta("direction", dir)
	knife.set_meta("speed", 200.0)
	knife.set_meta("damage", 12.0)
	knife.set_meta("source", self)

	get_tree().current_scene.add_child(knife)
	_move_projectile(knife)


func _move_projectile(bolt: Area2D) -> void:
	var speed: float = bolt.get_meta("speed", 200.0)
	var damage: float = bolt.get_meta("damage", 12.0)
	var lifetime := 3.0
	var elapsed := 0.0

	while is_instance_valid(bolt) and is_instance_valid(self) and elapsed < lifetime:
		await get_tree().process_frame
		if not is_instance_valid(self): return
		elapsed += get_process_delta_time()
		var dir: Vector2 = bolt.get_meta("direction", Vector2.RIGHT)
		bolt.global_position += dir * speed * get_process_delta_time()

		var bodies := bolt.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player") and body.has_method("receive_damage"):
				body.receive_damage(damage, DamageZone.Zone.TORSO, false)
				if is_instance_valid(bolt):
					bolt.queue_free()
				return

	if is_instance_valid(bolt):
		bolt.queue_free()
