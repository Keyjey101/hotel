extends CharacterBody2D

## Player — Main player controller.
## Handles movement, aiming, combat input, HP, and weapon management.

@onready var sprite: Sprite2D = %Sprite
@onready var weapon_manager: Node2D = %WeaponManager
@onready var hurtbox: Area2D = %Hurtbox
@onready var pickup_area: Area2D = %PickupArea
@onready var anim_player: AnimationPlayer = %AnimPlayer

@export_group("Movement")
@export var base_speed: float = 200.0

var _current_speed: float = 200.0
var _facing: Vector2 = Vector2.DOWN
var _aim_direction: Vector2 = Vector2.DOWN
var _is_attacking: bool = false
var _attack_cooldown: float = 0.0
var _is_hurt: bool = false
var _hurt_timer: float = 0.0
var _is_dead: bool = false
var _invulnerable: bool = false
var _invul_timer: float = 0.0


func _ready() -> void:
	_current_speed = base_speed
	if GameManager.run_state:
		_current_speed = GameManager.run_state.player_speed
	_connect_signals()


func _connect_signals() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_hit)
	EventBus.player_weapon_changed.connect(_on_weapon_changed)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# Timers
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_hurt_timer = maxf(0.0, _hurt_timer - delta)
	if _hurt_timer <= 0.0:
		_is_hurt = false
	_invul_timer = maxf(0.0, _invul_timer - delta)
	if _invul_timer <= 0.0:
		_invulnerable = false

	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * _current_speed
	move_and_slide()

	# Facing / Aim
	_aim_direction = (get_global_mouse_position() - global_position).normalized()
	if input_dir != Vector2.ZERO:
		_facing = input_dir.normalized()

	# Attack
	if Input.is_action_pressed("attack") and _attack_cooldown <= 0.0 and not _is_attacking:
		_attack()
	# Throw
	if Input.is_action_just_pressed("throw_weapon") and not _is_attacking:
		weapon_manager.throw_active_weapon(_aim_direction)
	# Switch weapon
	if Input.is_action_just_pressed("switch_weapon"):
		weapon_manager.switch_slot()
	# Pickup
	if Input.is_action_just_pressed("interact"):
		_try_pickup()

	# Update visual facing
	_update_sprite_facing()


func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if _invulnerable or _is_dead:
		return

	if GameManager.run_state:
		# Apply damage reduction from upgrades
		var reduction := GameManager.run_state.stat_upgrades.get("damage_reduction", 0.0)
		amount *= (1.0 - reduction)
		GameManager.run_state.player_hp -= amount
	else:
		amount = 0.0

	_is_hurt = true
	_hurt_timer = 0.2
	_invulnerable = true
	_invul_timer = 0.5

	# Knockback
	if knockback_force > 0.0:
		velocity = knockback_dir * knockback_force * 5.0

	# Flash
	_flash_white()

	EventBus.player_damaged.emit(amount)

	# Check death
	if GameManager.run_state and GameManager.run_state.player_hp <= 0.0:
		GameManager.run_state.player_hp = 0.0
		_die()


func heal(amount: float) -> void:
	if _is_dead:
		return
	if GameManager.run_state:
		GameManager.run_state.player_hp = minf(
			GameManager.run_state.player_hp + amount,
			GameManager.run_state.player_max_hp
		)
	EventBus.player_healed.emit(amount)


func get_hp() -> float:
	if GameManager.run_state:
		return GameManager.run_state.player_hp
	return 100.0


func get_max_hp() -> float:
	if GameManager.run_state:
		return GameManager.run_state.player_max_hp
	return 100.0


func _attack() -> void:
	var weapon := weapon_manager.get_active_weapon()
	if weapon == null:
		return

	_is_attacking = true
	_attack_cooldown = weapon.attack_speed

	if weapon.weapon_type == WeaponData.WeaponType.MELEE or weapon.weapon_type == WeaponData.WeaponType.IMPROVISED:
		weapon_manager.melee_attack(weapon, _aim_direction)
	elif weapon.weapon_type == WeaponData.WeaponType.RANGED:
		weapon_manager.ranged_attack(weapon, _aim_direction)

	# End attack after brief delay
	get_tree().create_timer(weapon.attack_speed).timeout.connect(func(): _is_attacking = false)


func _try_pickup() -> void:
	var bodies := pickup_area.get_overlapping_bodies()
	var closest: Node2D = null
	var closest_dist: float = INF

	for body in bodies:
		if body.has_method("get_weapon_data"):
			var dist := global_position.distance_to(body.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = body

	if closest:
		var weapon := closest.get_weapon_data()
		weapon_manager.equip_weapon(weapon)
		closest.queue_free()
		EventBus.weapon_picked_up.emit(weapon)


func _die() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	# Trigger capture sequence after brief delay
	get_tree().create_timer(0.5).timeout.connect(func():
		GameManager.handle_player_death()
	)


func _flash_white() -> void:
	sprite.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func _update_sprite_facing() -> void:
	# Flip sprite based on aim direction
	if _aim_direction.x < -0.1:
		sprite.flip_h = true
	elif _aim_direction.x > 0.1:
		sprite.flip_h = false


func _on_hurtbox_hit(hit_area: Area2D) -> void:
	# Incoming hit from enemy hitbox
	if not hit_area.is_in_group("enemy_hitbox"):
		return

	var damage: float = 15.0  # Default damage
	var knockback_dir: Vector2 = global_position.direction_to(hit_area.global_position)
	var knockback_force: float = 100.0

	# Try to get damage from the enemy
	var enemy = hit_area.get_parent()
	if enemy and enemy.has_method("get_attack_damage"):
		damage = enemy.get_attack_damage()

	take_damage(damage, -knockback_dir, knockback_force)


func _on_weapon_changed(slot: int, _weapon: Resource) -> void:
	# Visual update for weapon slots
	pass
