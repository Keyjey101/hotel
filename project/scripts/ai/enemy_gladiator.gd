extends "res://scripts/ai/base_enemy.gd"

## Gladiator — Floor 6 (Arena/Wrath) elite arena fighter.
## Blocks passages, parries frontal attacks, alternates spear and sword.

# Weapon ranges
var _spear_range: float = 60.0
var _sword_range: float = 40.0
var _spear_damage: float = 25.0
var _sword_damage: Array[float] = [15.0, 20.0, 25.0]

# Blocking state — stands in narrow passage, forces engagement
var _blocking: bool = true

# Parry system
var _can_parry: bool = true

# Sword combo tracking
var _combo_count: int = 0
var _combo_timer: float = 0.0
var _combo_max_time: float = 2.0

# Visual references
var _shield_visual: ColorRect
var _spear_visual: ColorRect


func _ready() -> void:
	enemy_name = "Gladiator"
	enemy_type = "gladiator"

	torso_hp = 110.0
	head_hp = 35.0
	arm_hp = 30.0
	leg_hp = 25.0
	move_speed = 130.0
	detection_range = 150.0
	attack_range = _spear_range  # Use spear range as primary
	attack_damage = 25.0
	attack_speed = 0.7
	grab_strength = 3.0
	regen_speed_mult = 0.9
	aggression = 8.0
	coordination = 4.0

	add_to_group("gladiators")
	super._ready()

	# Create weapon/shield visuals (after super so sprite exists)
	_create_shield_visual()
	_create_spear_visual()


func _create_shield_visual() -> void:
	_shield_visual = ColorRect.new()
	_shield_visual.name = "ShieldVisual"
	_shield_visual.size = Vector2(12.0, 20.0)
	_shield_visual.color = Color(0.533, 0.533, 0.533, 1.0)  # #888888 metallic
	_shield_visual.position = Vector2(-18.0, -10.0)
	_shield_visual.z_index = 1
	sprite.add_child(_shield_visual)


func _create_spear_visual() -> void:
	_spear_visual = ColorRect.new()
	_spear_visual.name = "SpearVisual"
	_spear_visual.size = Vector2(3.0, 40.0)
	_spear_visual.color = Color(0.667, 0.533, 0.333, 1.0)  # #AA8855 wooden
	_spear_visual.position = Vector2(8.0, -30.0)
	_spear_visual.z_index = 1
	sprite.add_child(_spear_visual)


# ---------------------------------------------------------------------------
# Damage — Parry override
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if _disabled:
		return

	# Parry: 50% chance to block frontal melee attacks
	if _can_parry and knockback_dir != Vector2.ZERO:
		var facing_dir := _direction.normalized()
		var incoming_dir := knockback_dir.normalized()
		# Dot product > 0 means the knockback direction points the same way
		# as our facing — the attack comes from the front
		var dot := facing_dir.dot(incoming_dir)
		if dot > 0.0 and randf() < 0.5:
			# Parried! Negate damage, flash visual, counter-attack
			_flash_parry()
			_counter_attack()
			EventBus.enemy_damaged.emit(self, zone, 0.0)
			return

	# Normal damage path
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


func _flash_parry() -> void:
	sprite.modulate = Color(1.0, 1.0, 0.5, 1.0)  # Yellow flash for parry
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)


func _counter_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist <= _spear_range:
		# Counter with spear thrust
		if _target.has_method("receive_damage"):
			var dir_to_target := global_position.direction_to(_target.global_position)
			_target.receive_damage(_spear_damage, DamageZone.Zone.TORSO, false, 30.0, dir_to_target * -1.0)


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if _blocking:
		# Block path: don't move, just face the player
		velocity = Vector2.ZERO
		if _target and is_instance_valid(_target):
			_direction = global_position.direction_to(_target.global_position)
			# Engage immediately if player is close enough
			if global_position.distance_to(_target.global_position) <= _spear_range:
				_enter_state("engage")
		return

	super._state_chase(delta)


func _state_engage(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	# Tick combo timer — if timer expires, reset combo
	if _combo_count > 0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_count = 0

	# Attack if cooldown ready
	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	# Gladiator holds position — don't chase if player moves away slightly
	# Only disengage if player moves very far
	var dist := global_position.distance_to(_target.global_position)
	if dist > _spear_range * 3.0:
		if _blocking:
			# Stay put, just face player
			pass
		else:
			_enter_state("chase")


# ---------------------------------------------------------------------------
# Attack logic
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	var dir_to_target := global_position.direction_to(_target.global_position)

	# Check if weapon arm is lost — use kicks + headbutt instead
	if severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false):
		_perform_unarmed_attack(dir_to_target)
		return

	# Spear thrust if target is at distance
	if dist > 45.0:
		if _target.has_method("receive_damage"):
			_target.receive_damage(_spear_damage, DamageZone.Zone.TORSO, false, 40.0, dir_to_target * -1.0)
	else:
		# Sword combo — multi-hit
		var damage: float = _sword_damage[_combo_count] if _combo_count < _sword_damage.size() else 20.0
		if _target.has_method("receive_damage"):
			_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 20.0, dir_to_target * -1.0)
		_combo_count += 1
		_combo_timer = _combo_max_time
		if _combo_count >= 3:
			_combo_count = 0


func _perform_unarmed_attack(dir_to_target: Vector2) -> void:
	"""Kick and headbutt when weapon arm is lost."""
	if _target == null or not is_instance_valid(_target):
		return

	# Alternate between kick (15) and headbutt (20)
	var use_headbutt: bool = randf() < 0.5
	var damage := 15.0 if not use_headbutt else 20.0

	if _target.has_method("receive_damage"):
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 25.0, dir_to_target * -1.0)


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)  # Already sets severed_limbs[zone] = true

	# Weapon arm lost (RIGHT_ARM) — can't hold weapon
	if zone == DamageZone.Zone.RIGHT_ARM:
		_blocking = false
		attack_damage = 15.0  # Reduced to unarmed damage
		attack_range = _sword_range
		# Remove spear visual
		if _spear_visual and is_instance_valid(_spear_visual):
			_spear_visual.queue_free()
			_spear_visual = null
		# Remove shield too (no weapon arm to hold shield either)
		if _shield_visual and is_instance_valid(_shield_visual):
			_shield_visual.queue_free()
			_shield_visual = null

	# Shield arm lost (LEFT_ARM) — no parry
	if zone == DamageZone.Zone.LEFT_ARM:
		_can_parry = false
		# Remove shield visual
		if _shield_visual and is_instance_valid(_shield_visual):
			_shield_visual.queue_free()
			_shield_visual = null

	# Legs lost — continue fighting from ground (don't retreat)
	if DamageZone.is_leg(zone):
		var lost_legs := int(severed_limbs.get(DamageZone.Zone.LEFT_LEG, false)) + \
			int(severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false))
		match lost_legs:
			1: move_speed *= 0.5
			2: move_speed *= 0.15
		# Stay in engage state — Gladiator NEVER retreats from the arena
		if _current_state == "chase":
			_enter_state("engage")

	# Check for all-limbs-lost disable condition (same as base)
	var all_severed := true
	for z in DamageZone.all_limbs():
		if not severed_limbs.get(z, false):
			all_severed = false
			break
	if all_severed and limb_health.get(DamageZone.Zone.TORSO, torso_hp) <= torso_hp * 0.3:
		_disable_enemy()


func _evaluate_mutilated_behavior() -> void:
	# Gladiator NEVER retreats — stays in engage as long as possible
	var arms_lost := int(severed_limbs.get(DamageZone.Zone.LEFT_ARM, false)) + \
		int(severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false))
	var legs_lost := int(severed_limbs.get(DamageZone.Zone.LEFT_LEG, false)) + \
		int(severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false))

	if arms_lost >= 2 and legs_lost >= 2:
		# Still stays in engage — fights to the bitter end
		if _current_state != "engage":
			_enter_state("engage")
	elif legs_lost >= 2:
		# Immobile but keeps fighting
		if _current_state != "engage":
			_enter_state("engage")
