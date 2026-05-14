extends "res://scripts/ai/base_enemy.gd"

## Champion enemy — elite duelist, greatsword combo, parry master, charge.
## Floor 8 Ballroom/Pride. Design doc: 11_ENEMY_DESIGN.md section 8.x

# Greatsword combo system
var _combo_count: int = 0
var _combo_max: int = 4
var _combo_damage: Array[float] = [15.0, 20.0, 25.0, 35.0]
var _combo_windup: Array[float] = [0.1, 0.2, 0.3, 0.5]
var _combo_cooldown: float = 0.0
var _combo_active: bool = false
var _combo_generation: int = 0

# Charge system
var _is_charging: bool = false
var _charge_speed_mult: float = 2.0
var _charge_duration: float = 0.8
var _charge_timer: float = 0.0
var _charge_damage: float = 40.0

# Parry system
var _base_parry_chance: float = 0.7
var _current_parry_chance: float = 0.7

# Adaptive AI tracking
var _player_melee_count: int = 0
var _player_ranged_count: int = 0
var _adaptive_reset_timer: float = 10.0

# Greatsword visual
var _greatsword_visual: ColorRect
var _cape_visual: ColorRect


func _ready() -> void:
	# Override identity
	enemy_name = "Champion"
	enemy_type = "champion"

	# Override stats from design doc
	torso_hp = 130.0
	head_hp = 40.0
	arm_hp = 35.0
	leg_hp = 30.0
	move_speed = 140.0
	detection_range = 180.0
	attack_range = 65.0  # greatsword reach
	attack_damage = 35.0  # last hit of combo
	attack_speed = 0.5
	grab_strength = 4.0
	regen_speed_mult = 1.0
	aggression = 8.0
	coordination = 6.0

	# Combo setup
	_combo_damage = [15.0, 20.0, 25.0, 35.0]
	_combo_windup = [0.1, 0.2, 0.3, 0.5]

	# Parry setup
	_base_parry_chance = 0.7
	_current_parry_chance = 0.7

	add_to_group("champions")
	super._ready()

	# Create equipment visuals (after super so sprite exists)
	_create_visuals()


func _create_visuals() -> void:
	# Greatsword
	_greatsword_visual = ColorRect.new()
	_greatsword_visual.name = "Greatsword"
	_greatsword_visual.size = Vector2(4.0, 50.0)
	_greatsword_visual.color = Color(0.753, 0.753, 0.753, 1.0)  # #C0C0C0
	_greatsword_visual.position = Vector2(18.0, -25.0)
	_greatsword_visual.z_index = 1
	sprite.add_child(_greatsword_visual)

	# Cape (blood red)
	_cape_visual = ColorRect.new()
	_cape_visual.name = "Cape"
	_cape_visual.size = Vector2(20.0, 16.0)
	_cape_visual.color = Color(0.545, 0.0, 0.0, 1.0)  # #8B0000
	_cape_visual.position = Vector2(-10.0, -8.0)
	_cape_visual.z_index = -1
	sprite.add_child(_cape_visual)


func get_enemy_type() -> String:
	return enemy_type


# ---------------------------------------------------------------------------
# Physics — charge + adaptive AI
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	# Handle charge movement separately
	if _is_charging:
		_process_charge(delta)
		return

	# Combo cooldown tick
	if _combo_cooldown > 0.0:
		_combo_cooldown -= delta

	# Adaptive AI timer
	_adaptive_reset_timer -= delta
	if _adaptive_reset_timer <= 0.0:
		_reset_adaptive_counters()

	super._physics_process(delta)


func _process_charge(delta: float) -> void:
	_charge_timer -= delta

	if _target and is_instance_valid(_target):
		var dir := global_position.direction_to(_target.global_position)
		velocity = dir * move_speed * _charge_speed_mult
		_direction = dir

		# Hit target during charge
		var dist := global_position.distance_to(_target.global_position)
		if dist <= attack_range:
			_end_charge(true)
			return
	else:
		velocity = _direction * move_speed * _charge_speed_mult

	# End charge after duration
	if _charge_timer <= 0.0:
		_end_charge(false)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	velocity += _knockback_vel
	move_and_slide()


func _end_charge(hit_target: bool) -> void:
	_is_charging = false

	if hit_target and _target and is_instance_valid(_target):
		# Charge hit: 40 damage
		var dir_to_target := global_position.direction_to(_target.global_position)
		if _target.has_method("receive_damage"):
			_target.receive_damage(_charge_damage, 0, false, 120.0, dir_to_target * -1.0)
		if _target.has_method("apply_stun"):
			_target.apply_stun(0.6)
		# Reset combo after charge hit
		_combo_count = 0
		_attack_cooldown = 0.3

	_enter_state("engage")


func _reset_adaptive_counters() -> void:
	_player_melee_count = 0
	_player_ranged_count = 0
	_adaptive_reset_timer = 10.0

	# Reset parry to base
	_current_parry_chance = _base_parry_chance

	# Reset speed modification (only if legs intact)
	var legs_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)
	if not legs_severed:
		move_speed = _get_base_speed()


func _update_adaptive_ai() -> void:
	# If player is melee-heavy, increase parry
	if _player_melee_count > 5:
		_current_parry_chance = 0.85
	else:
		_current_parry_chance = _base_parry_chance

	# If player is ranged-heavy, increase speed
	if _player_ranged_count > 3:
		var legs_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) and \
			severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)
		if not legs_severed:
			move_speed = _get_base_speed() * 1.2
	else:
		var legs_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) and \
			severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)
		if not legs_severed:
			move_speed = _get_base_speed()


# ---------------------------------------------------------------------------
# Damage — Parry Master override
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if _disabled:
		return

	# Charge armor: 50% damage reduction while charging
	if _is_charging:
		damage *= 0.5

	# Parry Master: parry frontal melee attacks
	if knockback_dir != Vector2.ZERO and not _is_charging:
		var facing_dir := _direction.normalized()
		var incoming_dir := knockback_dir.normalized()
		var dot := facing_dir.dot(incoming_dir)
		if dot < 0.0:
			# Frontal hit — attempt parry
			_player_melee_count += 1
			_update_adaptive_ai()
			if randf() < _current_parry_chance:
				# Parried! Negate damage, counter-attack
				_flash_hurt()
				sprite.modulate = Color(1.5, 1.5, 0.5, 1.0)  # Gold flash for parry
				var tween := create_tween()
				tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
				EventBus.enemy_damaged.emit(self, zone, 0.0)
				_counter_attack()
				return
	else:
		# Ranged hit (no knockback dir or from behind)
		_player_ranged_count += 1
		_update_adaptive_ai()

	# Normal damage path
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


func _counter_attack() -> void:
	# Guaranteed counter hit
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist <= attack_range * 1.5:
		var dir_to_target := global_position.direction_to(_target.global_position)
		if _target.has_method("receive_damage"):
			_target.receive_damage(attack_damage, 0, false, 80.0, dir_to_target * -1.0)


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	# Charge if player is far enough away
	if dist > 100.0 and not _is_charging and _attack_cooldown <= 0.0:
		_start_charge()
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
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	var dist := global_position.distance_to(_target.global_position)

	# Target moved away — chase or charge
	if dist > attack_range * 1.5:
		# Reset combo if player escapes
		if _combo_active:
			_combo_count = 0
			_combo_active = false
		_enter_state("chase")
		return

	# Execute combo
	if _combo_cooldown <= 0.0 and _attack_cooldown <= 0.0:
		_perform_attack()
	elif _combo_active and _combo_cooldown <= 0.0:
		# Continue combo
		_perform_attack()

	# Check if target moved out of range after attack
	if _target and is_instance_valid(_target):
		dist = global_position.distance_to(_target.global_position)
		if dist > attack_range * 1.5:
			_combo_count = 0
			_combo_active = false
			_combo_generation += 1
			_enter_state("chase")


# ---------------------------------------------------------------------------
# Charge attack
# ---------------------------------------------------------------------------

func _start_charge() -> void:
	_is_charging = true
	_charge_timer = _charge_duration
	_combo_count = 0
	_combo_active = false
	_combo_generation += 1

	# Visual feedback: flash
	sprite.modulate = Color(1.5, 0.8, 0.8, 1.0)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


# ---------------------------------------------------------------------------
# Greatsword combo attack
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.5:
		_combo_count = 0
		_combo_active = false
		_combo_generation += 1
		return

	# Current combo step
	var step := _combo_count
	var damage := _combo_damage[step]
	var windup := _combo_windup[step]

	# Apply windup delay then strike
	_attack_cooldown = windup + attack_speed

	_combo_cooldown = windup + 0.1  # Small gap between combo hits

	# Windup visual: flash brighter for bigger hits
	if step >= 2:
		sprite.modulate = Color(2.0, 1.5, 0.5, 1.0)
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, windup)

	# Schedule the actual hit after windup
	var timer := get_tree().create_timer(windup)
	var gen := _combo_generation
	timer.timeout.connect(func() -> void: _deliver_combo_hit(step, damage, gen))

	_combo_count += 1
	_combo_active = true

	# Reset combo after completing all 4 hits
	if _combo_count >= _combo_max:
		_combo_count = 0
		_combo_active = false
		_combo_generation += 1


func _deliver_combo_hit(step: int, damage: float, generation: int = -1) -> void:
	if _disabled or not is_instance_valid(self):
		return
	if generation >= 0 and generation != _combo_generation:
		return
	if _target == null or not is_instance_valid(_target):
		_combo_count = 0
		_combo_active = false
		_combo_generation += 1
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.5:
		# Combo interrupted — reset
		_combo_count = 0
		_combo_active = false
		_combo_generation += 1
		return

	var dir_to_target := global_position.direction_to(_target.global_position)
	var knockback := 40.0 + step * 20.0  # Increasing knockback

	if _target.has_method("receive_damage"):
		# Last hit: guaranteed limb sever
		if step == _combo_max - 1:
			_target.receive_damage(damage, 0, true, knockback, dir_to_target * -1.0)
		else:
			_target.receive_damage(damage, 0, false, knockback, dir_to_target * -1.0)


# ---------------------------------------------------------------------------
# Mutilated overrides — THE MOST DANGEROUS mutilated enemy
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	var one_arm_lost: bool = severed_limbs.get(DamageZone.Zone.LEFT_ARM, false) or \
		severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false)
	var both_arms_lost: bool = severed_limbs.get(DamageZone.Zone.LEFT_ARM, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false)
	var one_leg_lost: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) or \
		severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)
	var both_legs_lost: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)

	# One arm → switches to one-handed sword (FASTER, not slower!)
	if one_arm_lost and not both_arms_lost:
		attack_speed = 0.8  # Faster one-handed style
		_combo_damage = [12.0, 16.0, 20.0, 28.0]  # Slightly reduced but still deadly
		_combo_windup = [0.05, 0.1, 0.15, 0.3]  # Faster windups
		# Update greatsword visual to shorter blade
		if _greatsword_visual and is_instance_valid(_greatsword_visual):
			_greatsword_visual.size = Vector2(3.0, 35.0)
			_greatsword_visual.color = Color(0.85, 0.85, 0.85, 1.0)  # Brighter, more dangerous look
		return

	# Both arms → headbutt/kick only, still aggressive
	if both_arms_lost:
		attack_damage = 15.0
		attack_speed = 0.6
		if _greatsword_visual and is_instance_valid(_greatsword_visual):
			_greatsword_visual.visible = false
		return

	# One leg → stays put but attack_range INCREASES (wider sweeps from planted stance)
	if one_leg_lost and not both_legs_lost:
		attack_range = 80.0  # Wider sweeps from a planted stance
		aggression = 10.0  # Even more aggressive
		# Parry chance increases — more focused
		_base_parry_chance = 0.8
		_current_parry_chance = 0.8
		return

	# Both legs → rooted but extremely dangerous in melee range
	if both_legs_lost:
		attack_range = 85.0  # Maximum sweep range
		aggression = 10.0
		_base_parry_chance = 0.85
		_current_parry_chance = 0.85
		attack_speed = 0.9  # Fastest yet — desperation speed
		_combo_windup = [0.03, 0.08, 0.12, 0.25]
		if _target != null and is_instance_valid(_target):
			if _current_state == "chase":
				_enter_state("engage")
