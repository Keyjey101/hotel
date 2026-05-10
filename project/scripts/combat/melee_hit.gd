extends Area2D

## MeleeHit — Temporary hitbox spawned during melee attacks.
## Detects which enemy hurtbox zones it overlaps.

signal hit(target: Node2D, zone: int)

var _weapon: WeaponData
var _direction: Vector2
var _damage_mult: float = 1.0
var _lifespan: float = 0.15
var _targets_hit: Array[Node2D] = []


func setup(weapon: WeaponData, direction: Vector2, _owner: CharacterBody2D) -> void:
	_weapon = weapon
	_direction = direction

	# Position hitbox at attack range
	var offset := direction * weapon.attack_range * 0.5
	global_position = _owner.global_position + offset

	# Set collision shape based on weapon range
	var shape := $CollisionShape2D.shape as RectangleShape2D
	if shape:
		shape.size = Vector2(weapon.attack_range, 20.0)
		rotation = direction.angle()


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	# Auto-despawn
	get_tree().create_timer(_lifespan).timeout.connect(queue_free)


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy_hurtbox"):
		return

	var enemy := area.get_parent().get_parent()  # HurtboxManager -> Enemy
	if enemy in _targets_hit:
		return

	# Determine which zone was hit based on which hurtbox area
	var zone := _identify_zone(area)

	_targets_hit.append(enemy)
	hit.emit(enemy, zone)


func _identify_zone(hurtbox_area: Area2D) -> int:
	var name := hurtbox_area.name.to_lower()
	if "head" in name:
		return DamageZone.Zone.HEAD
	elif "arm_l" in name or "left_arm" in name:
		return DamageZone.Zone.LEFT_ARM
	elif "arm_r" in name or "right_arm" in name:
		return DamageZone.Zone.RIGHT_ARM
	elif "leg_l" in name or "left_leg" in name:
		return DamageZone.Zone.LEFT_LEG
	elif "leg_r" in name or "right_leg" in name:
		return DamageZone.Zone.RIGHT_LEG
	else:
		return DamageZone.Zone.TORSO
