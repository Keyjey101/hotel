extends Node2D

## WeaponManager — Manages player weapon inventory, attacks, and throws.

const MeleeHitScene := preload("res://scenes/weapons/melee_hit.tscn")
const ProjectileScene := preload("res://scenes/weapons/projectile.tscn")
const ThrowScene := preload("res://scenes/weapons/thrown_weapon.tscn")

@export var max_slots: int = 2

var equipped: Array = [null, null]   # [WeaponData, WeaponData]
var active_slot: int = 0
var _ammo: Array = [0, 0]           # Current ammo per slot


func _ready() -> void:
	# Check if Crown of Thorns artifact adds a slot
	if GameManager.run_state and GameManager.run_state.has_artifact("Crown of Thorns"):
		max_slots = 3
		equipped.append(null)
		_ammo.append(0)


func get_active_weapon() -> WeaponData:
	return equipped[active_slot]


func get_active_ammo() -> int:
	return _ammo[active_slot]


func switch_slot() -> void:
	active_slot = (active_slot + 1) % max_slots
	var weapon := get_active_weapon()
	if weapon:
		EventBus.player_weapon_changed.emit(active_slot, weapon)


func equip_weapon(weapon: WeaponData) -> void:
	# Find empty slot or replace current
	var target_slot := active_slot

	# First try empty slot
	for i in range(max_slots):
		if equipped[i] == null:
			target_slot = i
			break

	# Drop current weapon if replacing
	if equipped[target_slot] != null:
		_drop_weapon(equipped[target_slot], global_position)

	equipped[target_slot] = weapon
	active_slot = target_slot

	# Set ammo
	if weapon.ammo > 0:
		var ammo_bonus := 1.0
		if GameManager.run_state:
			ammo_bonus = 1.0 + GameManager.run_state.stat_upgrades.get("ammo_bonus", 0.0)
		_ammo[target_slot] = ceili(weapon.ammo * ammo_bonus)
	else:
		_ammo[target_slot] = -1  # Infinite (melee)

	EventBus.player_weapon_changed.emit(target_slot, weapon)


func melee_attack(weapon: WeaponData, direction: Vector2) -> void:
	if not weapon:
		return

	# Create melee hitbox
	var hit := MeleeHitScene.instantiate()
	hit.setup(weapon, direction, get_parent())
	get_tree().current_scene.add_child(hit)

	# Get melee damage multiplier from upgrades
	var dmg_mult := _get_melee_damage_mult()

	# Connect hit signal to apply damage
	hit.hit.connect(func(target: Node2D, zone: int):
		_apply_damage_to_target(target, zone, weapon.damage * dmg_mult, weapon)
	)


func ranged_attack(weapon: WeaponData, direction: Vector2) -> void:
	if not weapon:
		return
	if _ammo[active_slot] == 0:
		return  # No ammo

	# Consume ammo
	if _ammo[active_slot] > 0:
		_ammo[active_slot] -= 1

	# Get ranged damage multiplier
	var dmg_mult := _get_ranged_damage_mult()

	# Spawn projectiles
	for i in range(weapon.projectile_count):
		var spread_angle := deg_to_rad(weapon.projectile_spread)
		var angle_offset := 0.0
		if weapon.projectile_count > 1:
			angle_offset = spread_angle * (float(i) / float(weapon.projectile_count - 1) - 0.5) * 2.0

		var dir := direction.rotated(angle_offset)
		var proj := ProjectileScene.instantiate()
		proj.setup(weapon, dir, dmg_mult, weapon.piercing)
		proj.global_position = get_parent().global_position
		get_tree().current_scene.add_child(proj)

		proj.hit.connect(func(target: Node2D, zone: int):
			_apply_damage_to_target(target, zone, weapon.damage * dmg_mult, weapon)
		)


func throw_active_weapon(direction: Vector2) -> void:
	var weapon := get_active_weapon()
	if not weapon:
		return

	var throw_mult := _get_throw_damage_mult()
	var thrown := ThrowScene.instantiate()
	thrown.setup(weapon, direction, throw_mult)
	thrown.global_position = get_parent().global_position
	get_tree().current_scene.add_child(thrown)

	thrown.hit.connect(func(target: Node2D, zone: int):
		_apply_damage_to_target(target, zone, weapon.throw_damage * throw_mult, weapon)
	)

	# Remove from slot
	equipped[active_slot] = null
	_ammo[active_slot] = 0
	EventBus.weapon_dropped.emit(weapon)
	EventBus.player_weapon_changed.emit(active_slot, null)


func _drop_weapon(weapon: WeaponData, pos: Vector2) -> void:
	# Create pickup at position
	# TODO: spawn weapon pickup scene
	EventBus.weapon_dropped.emit(weapon)


func _apply_damage_to_target(target: Node2D, zone: int, base_damage: float, weapon: WeaponData) -> void:
	if not target.has_method("receive_damage"):
		return

	# Apply limb multiplier
	var limb_mult := 1.0
	if zone != DamageZone.Zone.TORSO:
		limb_mult = weapon.limb_damage_multiplier

	var final_damage := base_damage * limb_mult

	# Calculate sever
	var sever := false
	if DamageZone.is_limb(zone) and randf() < weapon.sever_chance:
		sever = true

	target.receive_damage(final_damage, zone, sever, weapon.knockback, global_position.direction_to(target.global_position))
	EventBus.weapon_hit_target.emit(weapon, target, final_damage)


func _get_melee_damage_mult() -> float:
	var mult := 1.0
	if GameManager.run_state:
		mult += GameManager.run_state.stat_upgrades.get("damage_melee", 0.0)
		# Hunger Blade artifact: melee heals
		if GameManager.run_state.has_artifact("Hunger Blade"):
			var heal_amount := final_damage * 0.15  # Will be applied in the hit callback
			# TODO: heal after hit connects
		# Demon Eye penalty
		if GameManager.run_state.has_artifact("Demon Eye"):
			mult -= 0.2
	return maxf(mult, 0.1)


func _get_ranged_damage_mult() -> float:
	var mult := 1.0
	if GameManager.run_state:
		mult += GameManager.run_state.stat_upgrades.get("damage_ranged", 0.0)
		# Demon Eye bonus
		if GameManager.run_state.has_artifact("Demon Eye"):
			mult += 0.3
	return maxf(mult, 0.1)


func _get_throw_damage_mult() -> float:
	var mult := 1.0
	if GameManager.run_state:
		mult += GameManager.run_state.stat_upgrades.get("damage_throw", 0.0)
	return maxf(mult, 0.1)
