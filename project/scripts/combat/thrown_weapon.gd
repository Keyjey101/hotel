extends RigidBody2D

## ThrownWeapon — Physics-based thrown weapon projectile.

signal hit(target: Node2D, zone: int)

var _weapon: WeaponData
var _direction: Vector2
var _damage_mult: float = 1.0
var _has_hit: bool = false
var _despawn_time: float = 10.0
var _throw_origin: Vector2 = Vector2.ZERO


func setup(weapon: WeaponData, direction: Vector2, damage_mult: float = 1.0) -> void:
	_weapon = weapon
	_direction = direction
	_damage_mult = damage_mult
	_has_hit = false
	_despawn_time = 10.0
	_throw_origin = global_position
	freeze = false
	gravity_scale = 1.0
	# Re-activate for pool reuse
	set_process(true)
	set_physics_process(true)
	visible = true
	# Reconnect body_entered if disconnected
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
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
	# Restart lifetime
	var lifetime_node = get_node_or_null("Lifetime")
	if lifetime_node:
		lifetime_node.stop()
		lifetime_node.start(_despawn_time)


func _ready() -> void:
	# Connections are handled in setup() with guards to prevent duplicates.
	# _ready fires on first instantiate; setup() is called by the pool after.
	# Velocity is set in setup() — _ready() has no _weapon yet on pool reuse.
	$Lifetime.timeout.connect(_return_to_pool)

	# Body entered signal: connect with guard in setup() instead of here
	# to avoid double-connection on first spawn.
	if not body_entered.is_connected(_on_body_entered):
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
		AudioManager.SFXPlayer.play_sfx_2d("weapon_throw_impact", global_position)
		hit.emit(body, zone)

		# Apply throw effect
		_apply_throw_effect(body)

		# Stop or slow down
		linear_velocity *= 0.2
		angular_velocity *= 0.3

		# Despawn after hit
		get_tree().create_timer(3.0).timeout.connect(_return_to_pool)

	elif body is StaticBody2D or body is TileMapLayer:
		# Hit environment
		_has_hit = true
		linear_velocity *= 0.1
		angular_velocity *= 0.2

		# Check for discharge effect (gun throw)
		if _weapon.throw_effect == "discharge" and randf() < _weapon.throw_effect_chance:
			AudioManager.SFXPlayer.play_sfx("weapon_discharge")
			_discharge()

		# Bounce for bat
		if _weapon.throw_effect == "bounce":
			linear_velocity = linear_velocity.bounce(Vector2.UP) * 0.6
			_has_hit = false  # Can hit again

		# Shatter for bottle
		if _weapon.throw_effect == "shatter" or _weapon.name == "Bottle":
			AudioManager.SFXPlayer.play_sfx("weapon_shatter")
			_create_shatter_zone()
			_return_to_pool()
			return

		get_tree().create_timer(5.0).timeout.connect(_return_to_pool)




func _return_to_pool() -> void:
	if not visible and not is_physics_processing():
		return  # Already returned to pool
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	_has_hit = false
	_despawn_time = 10.0
	set_process(false)
	set_physics_process(false)
	visible = false
	# Disconnect body_entered to avoid double connections
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	if get_parent() and get_parent().has_method("return_instance"):
		get_parent().return_instance(self)
	else:
		queue_free()

func _apply_throw_effect(target: Node2D) -> void:
	match _weapon.throw_effect:
		"stick_bleed":
			_apply_stick_bleed()
		"pin":
			_apply_pin(target)
		"embed":
			_apply_embed(target)
		"bounce":
			_has_hit = false  # Ricochet
			linear_velocity = linear_velocity.rotated(randf_range(-0.5, 0.5)) * 0.6
		"shatter":
			AudioManager.SFXPlayer.play_sfx("weapon_shatter")
			_create_shatter_zone()
			_return_to_pool()
		"discharge":
			if randf() < _weapon.throw_effect_chance:
				AudioManager.SFXPlayer.play_sfx("weapon_discharge")
				_discharge()
		"barricade":
			# Chair lands as obstacle
			freeze = true
			_despawn_time = 30.0
		"demoralize":
			_apply_demoralize()
		"tangle":
			_apply_tangle(target)
		"soul_rip":
			_apply_soul_rip(target)
		"blood_syphon":
			# Heal player
			var heal := _weapon.throw_damage * _damage_mult * 0.3
			var player := get_tree().get_first_node_in_group("player")
			if player and player.has_method("heal"):
				player.heal(heal)
		"reality_tear":
			_apply_reality_tear()
		_:
			pass


func _apply_stick_bleed() -> void:
	# Machete throw: weapon sticks and creates bleed zone
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true
	# Create HazardZone at impact point (3 dmg/s, 3s, radius 20)
	var zone := HazardZone.new()
	zone.damage_per_second = 3.0
	zone.duration = 3.0
	zone.zone_radius = 20.0
	zone.zone_color = Color(0.7, 0.0, 0.0, 0.3)
	zone.global_position = global_position
	get_tree().current_scene.add_child(zone)
	# Visual: blade sticking out
	var blade := ColorRect.new()
	blade.size = Vector2(8, 3)
	blade.color = Color(0.75, 0.75, 0.75)  # #C0C0C0
	blade.position = Vector2(-4, -1)
	add_child(blade)


func _apply_pin(target: Node2D) -> void:
	# Knife throw: pin to target or wall
	if target is CharacterBody2D:
		# Pin to enemy
		var offset := global_position - target.global_position
		reparent(target)
		position = offset
		set_physics_process(false)
		freeze = true
		# Fall off after 3 seconds
		get_tree().create_timer(3.0).timeout.connect(_return_to_pool)
	else:
		# Pin to wall/static — just stick
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		freeze = true


func _apply_embed(target: Node2D) -> void:
	# Axe throw: embed in target, slow 40% for 7 seconds
	if target is CharacterBody2D:
		var offset := global_position - target.global_position
		reparent(target)
		position = offset
		set_physics_process(false)
		freeze = true
		# Apply 40% slow (0.6x speed) for 7 seconds
		if "move_speed" in target:
			if not target.has_meta("_original_speed"):
				target.set_meta("_original_speed", target.move_speed)
			target.move_speed = target.get_meta("_original_speed") * 0.6
			get_tree().create_timer(7.0).timeout.connect(func():
				if is_instance_valid(target) and target.has_meta("_original_speed"):
					target.move_speed = target.get_meta("_original_speed")
					target.remove_meta("_original_speed")
				if is_instance_valid(self):
					_return_to_pool()
			)
		# Visual: handle sticking out
		var handle := ColorRect.new()
		handle.size = Vector2(3, 10)
		handle.color = Color(0.545, 0.271, 0.075)  # #8B4513
		handle.position = Vector2(-1, -10)
		add_child(handle)
	else:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		freeze = true


func _apply_demoralize() -> void:
	# Severed Limb throw: AoE reduce aggression in radius 60px
	var radius := 60.0
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist <= radius:
			if "aggression" in enemy:
				enemy.aggression = maxf(0.0, enemy.aggression - 3.0)
				# Restore after 5 seconds
				var enemy_ref := enemy
				get_tree().create_timer(5.0).timeout.connect(func():
					if is_instance_valid(enemy_ref) and "aggression" in enemy_ref:
						enemy_ref.aggression += 3.0
				)
	# Visual: expanding red ring
	var ring := ColorRect.new()
	ring.size = Vector2(4, 4)
	ring.color = Color(1.0, 0.0, 0.0, 1.0)
	ring.position = Vector2(-2, -2)
	ring.global_position = global_position
	ring.z_index = 10
	get_tree().current_scene.add_child(ring)
	var tween := ring.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ring, "scale", Vector2(radius / 2.0, radius / 2.0), 0.5)
	tween.tween_property(ring, "modulate:a", 0.0, 0.5)
	tween.set_parallel(false)
	tween.tween_callback(ring.queue_free)


func _apply_tangle(target: Node2D) -> void:
	# Wire throw: slow target 50% for 4s, double if leg hit
	if target is CharacterBody2D:
		var slow_mult := 0.5
		if "move_speed" in target:
			if not target.has_meta("_original_speed"):
				target.set_meta("_original_speed", target.move_speed)
			target.move_speed = target.get_meta("_original_speed") * slow_mult
			get_tree().create_timer(4.0).timeout.connect(func():
				if is_instance_valid(target) and target.has_meta("_original_speed"):
					target.move_speed = target.get_meta("_original_speed")
					target.remove_meta("_original_speed")
			)
	# Visual: wire line from throw origin to target (fades)
	var wire := ColorRect.new()
	wire.size = Vector2(global_position.distance_to(_throw_origin), 2)
	wire.color = Color(0.5, 0.5, 0.5)  # #808080
	wire.global_position = _throw_origin
	wire.z_index = 5
	get_tree().current_scene.add_child(wire)
	var tween := wire.create_tween()
	tween.tween_property(wire, "modulate:a", 0.0, 2.0)
	tween.tween_callback(wire.queue_free)


func _apply_soul_rip(target: Node2D) -> void:
	# Cult Pistol throw: 25% disarm, else +50% damage
	if randf() < 0.25:
		# Disarm: if enemy has weapon, force drop
		if target.has_method("drop_weapon"):
			target.drop_weapon()
		# Visual: purple soul particle
		var particle := ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(0.580, 0.0, 0.827)  # #9400D3
		particle.global_position = target.global_position
		particle.z_index = 10
		get_tree().current_scene.add_child(particle)
		var tween := particle.create_tween()
		tween.tween_property(particle, "global_position", global_position, 0.4)
		tween.tween_callback(particle.queue_free)
	else:
		# +50% bonus damage if no disarm
		var bonus_damage := _weapon.throw_damage * _damage_mult * 0.5
		if target.has_method("receive_damage"):
			target.receive_damage(bonus_damage, DamageZone.Zone.TORSO, false)


func _apply_reality_tear() -> void:
	# Cult Relic throw: AoE 80px, HazardZone 10 dmg/s for 6s
	var radius := 80.0
	var zone := HazardZone.new()
	zone.damage_per_second = 10.0
	zone.duration = 6.0
	zone.zone_radius = radius
	zone.zone_color = Color(0.5, 0.0, 0.5, 0.5)
	zone.global_position = global_position
	get_tree().current_scene.add_child(zone)
	# All enemies in zone: aggression +5 for 4s
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist <= radius:
			if "aggression" in enemy:
				enemy.aggression += 5.0
				var enemy_ref := enemy
				get_tree().create_timer(4.0).timeout.connect(func():
					if is_instance_valid(enemy_ref) and "aggression" in enemy_ref:
						enemy_ref.aggression -= 5.0
				)
	# Visual: expanding purple circle
	var circle := ColorRect.new()
	circle.size = Vector2(4, 4)
	circle.color = Color(0.5, 0.0, 0.5, 0.8)
	circle.position = Vector2(-2, -2)
	circle.global_position = global_position
	circle.z_index = 10
	get_tree().current_scene.add_child(circle)
	var tween := circle.create_tween()
	tween.set_parallel(true)
	tween.tween_property(circle, "scale", Vector2(radius / 2.0, radius / 2.0), 6.0)
	tween.tween_property(circle, "modulate:a", 0.0, 6.0)
	tween.set_parallel(false)
	tween.tween_callback(circle.queue_free)
	# Single use: destroy relic
	queue_free()


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
		var dir = directions[randi() % directions.size()]
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
