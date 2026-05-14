extends "res://scripts/ai/base_enemy.gd"

## Cultist — Floor 7 (Observatory/Envy).
## Melee + ranged thrown knife. Moderate HP, moderate speed.

# Ranged attack state
var _throw_cooldown: float = 0.0
var _throw_ready: bool = true
var _active_knives: Array[Dictionary] = []


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
	_process_active_knives(delta)
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

	get_parent().add_child(knife)
	_active_knives.append({
		"knife": knife,
		"direction": dir,
		"speed": 200.0,
		"damage": 12.0,
		"elapsed": 0.0,
		"lifetime": 3.0,
	})


func _process_active_knives(delta: float) -> void:
	var i := _active_knives.size() - 1
	while i >= 0:
		var entry: Dictionary = _active_knives[i]
		var knife: Area2D = entry["knife"]
		if not is_instance_valid(knife):
			_active_knives.remove_at(i)
			i -= 1
			continue
		entry["elapsed"] += delta
		if entry["elapsed"] >= entry["lifetime"]:
			knife.queue_free()
			_active_knives.remove_at(i)
			i -= 1
			continue
		var dir: Vector2 = entry["direction"]
		var speed: float = entry["speed"]
		var damage: float = entry["damage"]
		knife.global_position += dir * speed * delta
		# Check hits
		var bodies := knife.get_overlapping_bodies()
		var hit_player: bool = false
		for body in bodies:
			if body.is_in_group("player") and body.has_method("receive_damage"):
				body.receive_damage(damage, DamageZone.Zone.TORSO, false)
				knife.queue_free()
				_active_knives.remove_at(i)
				hit_player = true
				break
		if hit_player:
			i -= 1
			continue
		i -= 1
