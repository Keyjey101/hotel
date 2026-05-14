extends Node2D

## WeaponManager — Manages player weapon inventory, attacks, and throws.

const MeleeHitScene := preload("res://scenes/weapons/melee_hit.tscn")
const ProjectileScene := preload("res://scenes/weapons/projectile.tscn")
const ThrowScene := preload("res://scenes/weapons/thrown_weapon.tscn")
const ObjectPoolScript := preload("res://scripts/effects/object_pool.gd")

@export var max_slots: int = 2

var equipped: Array = [null, null]   # [WeaponData, WeaponData]
var active_slot: int = 0
var _ammo: Array = [0, 0]           # Current ammo per slot
var _melee_pool: Node
var _projectile_pool: Node
var _thrown_pool: Node


func _ready() -> void:
	# Check if Crown of Thorns artifact adds a slot
	if GameManager.run_state and GameManager.run_state.has_artifact("a11_crown_of_thorns"):
		max_slots = 3
		equipped.append(null)
		_ammo.append(0)

	# Initialize object pools
	_melee_pool = ObjectPoolScript.new(MeleeHitScene, 8, 20)
	_projectile_pool = ObjectPoolScript.new(ProjectileScene, 15, 30)
	_thrown_pool = ObjectPoolScript.new(ThrowScene, 5, 15)
	add_child(_melee_pool)
	add_child(_projectile_pool)
	add_child(_thrown_pool)

	# Sync weapons from run_state
	if GameManager.run_state:
		for i in range(mini(GameManager.run_state.weapon_slots.size(), max_slots)):
			equipped[i] = GameManager.run_state.weapon_slots[i]
			if equipped[i] != null and equipped[i].ammo > 0:
				var ammo_bonus := 1.0 + float(GameManager.run_state.stat_upgrades.get("ammo_bonus", 0.0))
				_ammo[i] = ceili(equipped[i].ammo * ammo_bonus)
			else:
				_ammo[i] = -1
		active_slot = mini(GameManager.run_state.active_slot, max_slots - 1)


func get_active_weapon() -> WeaponData:
	return equipped[active_slot]


func get_active_ammo() -> int:
	return _ammo[active_slot]


func switch_slot() -> void:
	for i in range(1, max_slots + 1):
		var s: int = (active_slot + i) % max_slots
		if equipped[s] != null:
			active_slot = s
			EventBus.player_weapon_changed.emit(active_slot, equipped[s])
			_sync_to_run_state()
			return


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
		_drop_weapon(equipped[target_slot], get_parent().global_position)

	equipped[target_slot] = weapon
	active_slot = target_slot

	# Set ammo
	if weapon.ammo > 0:
		var ammo_bonus: float = 1.0
		if GameManager.run_state:
			ammo_bonus = 1.0 + float(GameManager.run_state.stat_upgrades.get("ammo_bonus", 0.0))
		_ammo[target_slot] = ceili(weapon.ammo * ammo_bonus)
	else:
		_ammo[target_slot] = -1  # Infinite (melee)

	EventBus.player_weapon_changed.emit(target_slot, weapon)
	_sync_to_run_state()


func melee_attack(weapon: WeaponData, direction: Vector2) -> void:
	if not weapon:
		return

	AudioManager.SFXPlayer.play_sfx_with_pitch("weapon_swing", randf_range(0.9, 1.1))

	# Create melee hitbox
	var hit = _melee_pool.get_instance()
	hit.setup(weapon, direction, get_parent())
	var saved_pos := hit.global_position
	# Reparent to scene tree if pooled
	if hit.get_parent() != get_tree().current_scene:
		hit.get_parent().remove_child(hit)
		if is_instance_valid(get_tree().current_scene):
			get_tree().current_scene.add_child(hit)
		else:
			call_deferred("add_child", hit)
	hit.global_position = saved_pos

	# Get melee damage multiplier from upgrades
	var dmg_mult := _get_melee_damage_mult()

	# Connect hit signal (clear old connections from pool reuse)
	for conn in hit.hit.get_connections():
		hit.hit.disconnect(conn.callable)
	hit.hit.connect(func(target: Node2D, zone: int):
		_apply_damage_to_target(target, zone, weapon.damage * dmg_mult, weapon, true)
	)


func ranged_attack(weapon: WeaponData, direction: Vector2) -> void:
	if not weapon:
		return
	if _ammo[active_slot] == 0:
		return  # No ammo

	AudioManager.SFXPlayer.play_sfx("weapon_shoot")

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
		var proj = _projectile_pool.get_instance()
		proj.setup(weapon, dir, dmg_mult, weapon.piercing)
		proj.global_position = get_parent().global_position
		if proj.get_parent() != get_tree().current_scene:
			proj.get_parent().remove_child(proj)
			if not is_instance_valid(get_tree().current_scene):
				# Projectile was removed from pool parent but scene is invalid.
				# Re-add to pool to avoid orphaning the projectile.
				add_child(proj)
				_projectile_pool.return_instance(proj)
				return
			get_tree().current_scene.add_child(proj)

		for conn in proj.hit.get_connections():
			proj.hit.disconnect(conn.callable)
		proj.hit.connect(func(target: Node2D, zone: int):
			_apply_damage_to_target(target, zone, weapon.damage * dmg_mult, weapon)
		)


func throw_active_weapon(direction: Vector2) -> void:
	var weapon := get_active_weapon()
	if not weapon:
		return
	if weapon.throw_damage <= 0.0:
		return

	AudioManager.SFXPlayer.play_sfx("weapon_throw")

	var throw_mult := _get_throw_damage_mult()
	var thrown = _thrown_pool.get_instance()
	thrown.setup(weapon, direction, throw_mult)
	thrown.global_position = get_parent().global_position
	# Reparent to scene tree if pooled
	if thrown.get_parent() != get_tree().current_scene:
		thrown.get_parent().remove_child(thrown)
		get_tree().current_scene.add_child(thrown)

	for conn in thrown.hit.get_connections():
		thrown.hit.disconnect(conn.callable)
	thrown.hit.connect(func(target: Node2D, zone: int):
		_apply_damage_to_target(target, zone, weapon.throw_damage * throw_mult, weapon)
	)

	# Remove from slot
	equipped[active_slot] = null
	_ammo[active_slot] = 0
	EventBus.weapon_dropped.emit(weapon)
	EventBus.player_weapon_changed.emit(active_slot, null)
	_sync_to_run_state()


func _drop_weapon(weapon: WeaponData, pos: Vector2) -> void:
	# Spawn weapon pickup at player position
	var pickup_scene := preload("res://scenes/weapons/weapon_pickup.tscn")
	var pickup := pickup_scene.instantiate()
	pickup.weapon_data = weapon
	pickup.global_position = pos
	get_tree().current_scene.add_child(pickup)
	EventBus.weapon_dropped.emit(weapon)


func _apply_damage_to_target(target: Node2D, zone: int, base_damage: float, weapon: WeaponData, is_melee: bool = false) -> void:
	if not target.has_method("receive_damage"):
		return

	# Apply limb multiplier
	var limb_mult := 1.0
	if zone != DamageZone.Zone.TORSO:
		limb_mult = weapon.limb_damage_multiplier

	var final_damage: float = base_damage * limb_mult

	# Calculate sever
	var sever := false
	if DamageZone.is_limb(zone) and randf() < weapon.sever_chance:
		sever = true

	target.receive_damage(final_damage, zone, sever, weapon.knockback, get_parent().global_position.direction_to(target.global_position))
	EventBus.weapon_hit_target.emit(weapon, target, final_damage)

	# Hunger Blade: 15% lifesteal on melee hits only
	if is_melee and GameManager.run_state and GameManager.run_state.has_artifact("a4_hunger_blade"):
		var heal_amount := final_damage * 0.15
		var player := get_tree().get_first_node_in_group("player")
		if player and player.has_method("heal"):
			player.heal(heal_amount)


func _get_melee_damage_mult() -> float:
	var mult := 1.0
	if GameManager.run_state:
		mult += float(GameManager.run_state.stat_upgrades.get("damage_melee", 0.0))
		# Demon Eye penalty
		if GameManager.run_state.has_artifact("a1_demon_eye"):
			mult -= 0.2
	return maxf(mult, 0.1)


func _get_ranged_damage_mult() -> float:
	var mult := 1.0
	if GameManager.run_state:
		mult += float(GameManager.run_state.stat_upgrades.get("damage_ranged", 0.0))
		# Demon Eye bonus
		if GameManager.run_state.has_artifact("a1_demon_eye"):
			mult += 0.3
	return maxf(mult, 0.1)


func _get_throw_damage_mult() -> float:
	var mult := 1.0
	if GameManager.run_state:
		mult += float(GameManager.run_state.stat_upgrades.get("damage_throw", 0.0))
	return maxf(mult, 0.1)


func refill_ammo() -> void:
	for i in range(max_slots):
		if equipped[i] != null and equipped[i].ammo > 0:
			var ammo_bonus := 1.0
			if GameManager.run_state:
				ammo_bonus = 1.0 + float(GameManager.run_state.stat_upgrades.get("ammo_bonus", 0.0))
			_ammo[i] = ceili(equipped[i].ammo * ammo_bonus)
	_sync_to_run_state()


func get_ammo_for_slot(slot: int) -> int:
	if slot < 0 or slot >= _ammo.size():
		return 0
	return _ammo[slot]


func _sync_to_run_state() -> void:
	if GameManager.run_state:
		for i in range(mini(max_slots, GameManager.run_state.weapon_slots.size())):
			GameManager.run_state.weapon_slots[i] = equipped[i]
		GameManager.run_state.active_slot = active_slot
