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
	_lifespan = 0.15
	_targets_hit.clear()

	# Position hitbox at attack range
	var offset := direction * weapon.attack_range * 0.5
	global_position = _owner.global_position + offset

	# Set collision shape based on weapon range
	var shape := $CollisionShape2D.shape as RectangleShape2D
	if shape:
		shape.size = Vector2(weapon.attack_range, 20.0)
		rotation = direction.angle()

	# Re-activate for pool reuse
	set_process(true)
	set_physics_process(true)
	visible = true
	# Reconnect area_entered if disconnected
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	# Restart despawn timer
	get_tree().create_timer(_lifespan).timeout.connect(_return_to_pool)


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	# Auto-despawn
	get_tree().create_timer(_lifespan).timeout.connect(_return_to_pool)


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy_hurtbox"):
		return

	var enemy := area.get_parent().get_parent()  # HurtboxManager -> Enemy
	if enemy in _targets_hit:
		return

	# Determine which zone was hit based on which hurtbox area
	var zone := _identify_zone(area)

	_targets_hit.append(enemy)
	AudioManager.SFXPlayer.play_sfx_2d("weapon_hit", global_position)
	hit.emit(enemy, zone)




func _return_to_pool() -> void:
	_targets_hit.clear()
	_lifespan = 0.15
	set_process(false)
	set_physics_process(false)
	visible = false
	if area_entered.is_connected(_on_area_entered):
		area_entered.disconnect(_on_area_entered)
	if get_parent() and get_parent().has_method("return_instance"):
		get_parent().return_instance(self)
	else:
		queue_free()

func _identify_zone(hurtbox_area: Area2D) -> int:
	return DamageZone.get_zone_from_collision(hurtbox_area)
