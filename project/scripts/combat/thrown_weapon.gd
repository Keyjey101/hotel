extends RigidBody2D

## ThrownWeapon — Physics-based thrown weapon projectile.

signal hit(target: Node2D, zone: int)

var _weapon: WeaponData
var _direction: Vector2
var _damage_mult: float = 1.0
var _has_hit: bool = false
var _despawn_time: float = 10.0


func setup(weapon: WeaponData, direction: Vector2, damage_mult: float = 1.0) -> void:
	_weapon = weapon
	_direction = direction
	_damage_mult = damage_mult


func _ready() -> void:
	# Apply velocity based on arc type
	match _weapon.throw_arc:
		WeaponData.ThrowArc.STRAIGHT:
			linear_velocity = _direction * _weapon.throw_speed
		WeaponData.ThrowArc.ARC:
			linear_velocity = _direction * _weapon.throw_speed
			gravity_scale = 2.0
		WeaponData.ThrowArc.SPIN:
			linear_velocity = _direction * _weapon.throw_speed
			angular_velocity = 10.0
		WeaponData.ThrowArc.TUMBLE:
			linear_velocity = _direction * _weapon.throw_speed
			angular_velocity = randf_range(-8.0, 8.0)
		WeaponData.ThrowArc.FLOAT:
			linear_velocity = _direction * _weapon.throw_speed * 0.5
			gravity_scale = 0.0

	$Lifetime.timeout.connect(queue_free)

	# Body entered signal for collision
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _has_hit:
		return

	if body.is_in_group("enemy"):
		_has_hit = true
		var zone := DamageZone.Zone.TORSO  # Throws tend to hit torso
		if randf() < 0.3:
			zone = [DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM,
				DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG].pick_random()
		hit.emit(body, zone)

		# Apply throw effect
		_apply_throw_effect(body)

		# Stop or slow down
		linear_velocity *= 0.2
		angular_velocity *= 0.3

		# Despawn after hit
		get_tree().create_timer(3.0).timeout.connect(queue_free)

	elif body is StaticBody2D or body is TileMapLayer:
		# Hit environment
		_has_hit = true
		linear_velocity *= 0.1
		angular_velocity *= 0.2

		# Check for discharge effect (gun throw)
		if _weapon.throw_effect == "discharge" and randf() < _weapon.throw_effect_chance:
			_discharge()

		# Bounce for bat
		if _weapon.throw_effect == "bounce":
			linear_velocity = linear_velocity.bounce(Vector2.UP) * 0.6
			_has_hit = false  # Can hit again

		# Shatter for bottle
		if _weapon.throw_effect == "shatter" or _weapon.name == "Bottle":
			queue_free()
			return

		get_tree().create_timer(5.0).timeout.connect(queue_free)


func _apply_throw_effect(target: Node2D) -> void:
	match _weapon.throw_effect:
		"stick_bleed":
			pass  # TODO: Apply bleed debuff
		"pin":
			pass  # TODO: Pin to wall if nearby
		"embed":
			pass  # TODO: Slow target
		"bounce":
			_has_hit = false  # Ricochet
			linear_velocity = linear_velocity.rotated(randf_range(-0.5, 0.5)) * 0.6
		"shatter":
			queue_free()
		"discharge":
			if randf() < _weapon.throw_effect_chance:
				_discharge()
		"barricade":
			# Chair lands as obstacle
			freeze = true
			_despawn_time = 30.0
		"demoralize":
			pass  # TODO: Reduce nearby enemy aggression
		"tangle":
			pass  # TODO: Slow target
		"soul_rip":
			pass  # TODO: Disarm + silence target
		"blood_syphon":
			# Heal player
			var heal := _weapon.throw_damage * _damage_mult * 0.3
			var player := get_tree().get_first_node_in_group("player")
			if player and player.has_method("heal"):
				player.heal(heal)
		"reality_tear":
			pass  # TODO: AoE damage
		_:
			pass


func _discharge() -> void:
	# Fire a random projectile from the landing point
	var directions := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
		Vector2(1, 1).normalized(), Vector2(1, -1).normalized(),
		Vector2(-1, 1).normalized(), Vector2(-1, -1).normalized()]
	var count := 1
	if _weapon.name == "SMG":
		count = 5
	elif _weapon.name == "Shotgun":
		count = 8

	for i in range(count):
		var dir := directions[randi() % directions.size()]
		var proj := preload("res://scenes/weapons/projectile.tscn").instantiate()
		var fake_weapon := WeaponData.new()
		fake_weapon.damage = _weapon.throw_damage * 0.5
		fake_weapon.projectile_speed = 400.0
		fake_weapon.limb_damage_multiplier = _weapon.limb_damage_multiplier
		fake_weapon.sever_chance = _weapon.sever_chance * 0.5
		proj.setup(fake_weapon, dir, _damage_mult, false)
		proj.global_position = global_position
		get_tree().current_scene.add_child(proj)
		proj.hit.connect(func(target: Node2D, zone: int):
			if target.has_method("receive_damage"):
				target.receive_damage(fake_weapon.damage * _damage_mult, zone, false, 10.0, dir)
		)
