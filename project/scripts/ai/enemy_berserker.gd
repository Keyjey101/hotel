extends "res://scripts/ai/base_enemy.gd"

## Berserker — Floor 6 (Arena/Wrath) rage-fueled fighter.
## Gets STRONGER with every lost limb. Charges, friendly fire, inverse difficulty.

# Charge system
var _charging: bool = false
var _charge_timer: float = 0.0
var _charge_duration: float = 0.5
var _charge_cooldown: float = 0.0
var _charge_cooldown_max: float = 3.0
var _charge_speed_mult: float = 2.0
var _charge_range: float = 150.0
var _charge_damage: float = 30.0

# Friendly fire multiplier
var _friendly_fire_mult: float = 2.0


func _ready() -> void:
	enemy_name = "Berserker"
	enemy_type = "berserker"

	torso_hp = 90.0
	head_hp = 20.0
	arm_hp = 20.0
	leg_hp = 20.0
	move_speed = 140.0
	detection_range = 200.0
	attack_range = 45.0
	attack_damage = 20.0
	attack_speed = 1.0
	grab_strength = 5.0
	regen_speed_mult = 0.5
	aggression = 10.0
	coordination = 0.0

	add_to_group("berserkers")
	super._ready()

	# Create chain visuals on wrists
	_create_chain_visuals()


func _create_chain_visuals() -> void:
	# Left wrist chain
	var left_chain := ColorRect.new()
	left_chain.name = "LeftChain"
	left_chain.size = Vector2(2.0, 12.0)
	left_chain.color = Color(0.533, 0.533, 0.533, 1.0)  # #888888
	left_chain.position = Vector2(-14.0, -2.0)
	left_chain.z_index = 1
	sprite.add_child(left_chain)

	# Right wrist chain
	var right_chain := ColorRect.new()
	right_chain.name = "RightChain"
	right_chain.size = Vector2(2.0, 12.0)
	right_chain.color = Color(0.533, 0.533, 0.533, 1.0)  # #888888
	right_chain.position = Vector2(12.0, -2.0)
	right_chain.z_index = 1
	sprite.add_child(right_chain)


# ---------------------------------------------------------------------------
# Limb loss — gets STRONGER
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	# DON'T call super — Berserker gets STRONGER
	severed_limbs[zone] = true  # Mark as severed but skip base debuffs

	var lost_count := _count_missing_limbs()
	_initial_move_speed = 140.0 + (lost_count * 30.0)
	move_speed = _initial_move_speed
	attack_damage = 20.0 + (lost_count * 6.0)
	attack_speed = 1.0 + (lost_count * 0.3)
	grab_strength = 5.0 + (lost_count * 2.0)

	# Visual: get REDDER per spec (11_ENEMY_DESIGN.md §3.5)
	match lost_count:
		1: sprite.modulate = Color(1.2, 0.2, 0.2)
		2: sprite.modulate = Color(1.5, 0.1, 0.1)
		_: sprite.modulate = Color(2.0, 0.0, 0.0)  # 3+ lost

	# Check for all-limbs-lost disable condition
	var all_severed := true
	for z in DamageZone.all_limbs():
		if not severed_limbs.get(z, false):
			all_severed = false
			break
	if all_severed and limb_health[DamageZone.Zone.TORSO] <= torso_hp * 0.3:
		_disable_enemy()


func _count_missing_limbs() -> int:
	var count := 0
	for zone in [DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM, DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG]:
		if severed_limbs.get(zone, false):
			count += 1
	return count


func _evaluate_mutilated_behavior() -> void:
	# Berserker NEVER retreats — do nothing
	pass


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	# Charge cooldown
	_charge_cooldown = maxf(0.0, _charge_cooldown - delta)

	# If currently charging, maintain charge
	if _charging:
		_charge_timer -= delta
		if _charge_timer <= 0.0:
			_charging = false
			# Check if in attack range after charge
			if global_position.distance_to(_target.global_position) <= attack_range:
				_enter_state("engage")
				return
		else:
			# Charge straight toward player at double speed
			var dir := global_position.direction_to(_target.global_position)
			velocity = dir * move_speed * _charge_speed_mult
			_direction = dir
			# If close enough during charge, deliver tackle
			if global_position.distance_to(_target.global_position) <= attack_range:
				_perform_tackle()
				_charging = false
				_enter_state("engage")
			return

	var dist := global_position.distance_to(_target.global_position)

	# Start charge if player within charge range and cooldown ready
	if dist <= _charge_range and dist > attack_range and _charge_cooldown <= 0.0:
		_charging = true
		_charge_timer = _charge_duration
		_charge_cooldown = _charge_cooldown_max
		return

	# Normal chase
	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * move_speed
	_direction = dir

	if dist <= attack_range:
		_enter_state("engage")


func _state_engage(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	# Return to chase if target moves out of range
	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 2.0:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Attack logic
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dir_to_target := global_position.direction_to(_target.global_position)

	# Check if all limbs gone — biting attack
	var lost := _count_missing_limbs()
	if lost >= 4:
		# Full rage: crawling, biting
		if _target.has_method("receive_damage"):
			_target.receive_damage(40.0, DamageZone.Zone.TORSO, false, 10.0, dir_to_target * -1.0)
		# Friendly fire — hit nearby enemies
		_deal_friendly_fire(40.0, dir_to_target)
		return

	# Normal attack
	if _target.has_method("receive_damage"):
		_target.receive_damage(attack_damage, DamageZone.Zone.TORSO, false, 30.0, dir_to_target * -1.0)

	# Friendly fire — Berserker hits EVERYTHING
	_deal_friendly_fire(attack_damage, dir_to_target)


func _perform_tackle() -> void:
	"""Charge tackle: 30 dmg + knockback + stun."""
	if _target == null or not is_instance_valid(_target):
		return

	var dir_to_target := global_position.direction_to(_target.global_position)
	if _target.has_method("receive_damage"):
		_target.receive_damage(_charge_damage, DamageZone.Zone.TORSO, false, 120.0, dir_to_target * -1.0)

	# Stun player
	if _target.has_method("apply_stun"):
		_target.apply_stun(0.8)


func _deal_friendly_fire(damage: float, attack_dir: Vector2) -> void:
	"""Hit nearby enemies in range — Berserker has zero coordination."""
	var enemies := get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy == self:
			continue
		if not enemy is CharacterBody2D:
			continue

		var dist := global_position.distance_to(enemy.global_position)
		if dist <= attack_range * 1.5:
			# Check if roughly in attack direction
			var dir_to_enemy := global_position.direction_to(enemy.global_position)
			var dot := attack_dir.normalized().dot(dir_to_enemy)
			if dot > 0.3:  # Within frontal arc
				if enemy.has_method("receive_damage"):
					enemy.receive_damage(damage * _friendly_fire_mult, DamageZone.Zone.TORSO, false, 20.0, dir_to_enemy * -1.0)
