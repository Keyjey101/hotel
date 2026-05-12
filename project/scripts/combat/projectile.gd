extends CharacterBody2D

## Projectile — Bullet/projectile entity for ranged weapons.

signal hit(target: Node2D, zone: int)

var _weapon: WeaponData
var _direction: Vector2
var _speed: float = 600.0
var _damage_mult: float = 1.0
var _piercing: bool = false
var _targets_hit: Array[Node2D] = []
var _lifetime: float = 3.0


func setup(weapon: WeaponData, direction: Vector2, damage_mult: float = 1.0, piercing: bool = false) -> void:
	_weapon = weapon
	_direction = direction
	_speed = weapon.projectile_speed
	_damage_mult = damage_mult
	_piercing = piercing
	_targets_hit.clear()
	_lifetime = 3.0
	# Re-activate for pool reuse
	velocity = _direction * _speed
	rotation = _direction.angle()
	set_process(true)
	set_physics_process(true)
	visible = true
	# Restart lifetime timer
	var lifetime_node = get_node_or_null("Lifetime")
	if lifetime_node:
		lifetime_node.start(_lifetime)


func _ready() -> void:
	$Lifetime.timeout.connect(_return_to_pool)

	# Connect to hurtbox detection
	# Use body detection since CharacterBody2D
	# We need an Area2D child for detection
	# For now, use movement + overlap check
	velocity = _direction * _speed
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()
		if collider and collider.is_in_group("enemy"):
			var zone := _pick_random_limb()
			if collider not in _targets_hit:
				_targets_hit.append(collider)
				AudioManager.SFXPlayer.play_sfx_2d("weapon_hit", global_position)
				hit.emit(collider, zone)
				if not _piercing:
					_return_to_pool()
					return
		elif collider:
			# Hit wall/environment
			_return_to_pool()
			return

	_lifetime -= delta
	if _lifetime <= 0.0:
		_return_to_pool()




func _return_to_pool() -> void:
	velocity = Vector2.ZERO
	_targets_hit.clear()
	_lifetime = 3.0
	set_process(false)
	set_physics_process(false)
	visible = false
	if get_parent() and get_parent().has_method("return_instance"):
		get_parent().return_instance(self)
	else:
		queue_free()


func _pick_random_limb() -> int:
	var zones := [DamageZone.Zone.TORSO, DamageZone.Zone.HEAD,
		DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM,
		DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG]
	return zones[randi() % zones.size()]
