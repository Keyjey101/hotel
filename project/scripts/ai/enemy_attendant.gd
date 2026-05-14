extends "res://scripts/ai/base_enemy.gd"

## Attendant enemy — Spa/Sloth Floor 5. Support/healer that keeps distance,
## fires slowing fog breath, sedative touch up close, and heals nearby allies.
## Design doc: Floor 5 Spa/Sloth

var _arms_lost: int = 0
var _fog_cooldown: float = 0.0
var _heal_cooldown: float = 0.0
var _healing_channel_timer: float = 0.0
var _is_channeling_heal: bool = false

const FOG_COOLDOWN_TIME: float = 5.0
const HEAL_COOLDOWN_TIME: float = 12.0
const HEAL_CHANNEL_TIME: float = 3.0
const HEAL_RADIUS: float = 80.0
const HEAL_PERCENT: float = 0.15
const FOG_RANGE: float = 150.0
const TOUCH_RANGE: float = 40.0
const HAZARD_SCENE := preload("res://scenes/combat/hazard_zone.tscn")


func _ready() -> void:
	enemy_name = "Attendant"
	enemy_type = "attendant"

	torso_hp = 55.0
	head_hp = 18.0
	arm_hp = 14.0
	leg_hp = 14.0
	move_speed = 70.0
	detection_range = 200.0
	attack_range = 150.0
	attack_damage = 10.0
	attack_speed = 0.4
	grab_strength = 5.0
	regen_speed_mult = 1.0
	aggression = 2.0
	coordination = 6.0

	super._ready()


func _physics_process(delta: float) -> void:
	_fog_cooldown = maxf(0.0, _fog_cooldown - delta)
	_heal_cooldown = maxf(0.0, _heal_cooldown - delta)
	super._physics_process(delta)
	if _is_channeling_heal:
		_healing_channel_timer -= delta
		if _healing_channel_timer <= 0.0:
			_complete_heal()
			_is_channeling_heal = false


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	# Keep distance at ~100-150px from player
	if dist < 80.0:
		# Too close — back away
		var away_dir := global_position.direction_to(_target.global_position) * -1.0
		velocity = away_dir * move_speed
		_direction = away_dir
	elif dist > 160.0:
		# Too far — move toward player slowly
		navigation.target_position = _target.global_position
		var next_pos := navigation.get_next_path_position()
		var dir := global_position.direction_to(next_pos)
		velocity = dir * move_speed * 0.6
		_direction = dir
	else:
		# Sweet spot — strafe slowly
		var perp := Vector2(_direction.y, -_direction.x)
		velocity = perp * move_speed * 0.3

	# Check for heal opportunity
	if _heal_cooldown <= 0.0 and _has_injured_allies_nearby():
		_begin_heal_channel()
		return

	# Transition to engage when in preferred range
	if dist <= FOG_RANGE and dist >= TOUCH_RANGE and _fog_cooldown <= 0.0:
		_enter_state("engage")
	elif dist <= TOUCH_RANGE:
		_enter_state("engage")


func _state_engage(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)
	_direction = global_position.direction_to(_target.global_position)

	# Channeling heal takes priority
	if _is_channeling_heal:
		velocity = Vector2.ZERO
		return

	# Periodically check for heal opportunity
	if _heal_cooldown <= 0.0 and _has_injured_allies_nearby():
		_begin_heal_channel()
		return

	# Sedative Touch — close range
	if dist <= TOUCH_RANGE:
		_perform_attack()
		return

	# Fog Breath — medium range
	if dist > 80.0 and _fog_cooldown <= 0.0:
		_perform_fog_breath()
		return

	# Too far — resume chase
	if dist > attack_range * 1.5:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Fog Breath — spawn HazardZone at player position
# ---------------------------------------------------------------------------

func _perform_fog_breath() -> void:
	if _fog_cooldown > 0.0:
		return
	if _arms_lost >= 2:
		return  # No fog with no arms

	var target_pos: Vector2 = _target.global_position if _target else global_position

	var fog_radius := 60.0
	if _arms_lost >= 1:
		fog_radius = 30.0  # Weaker fog with one arm

	var hz := HAZARD_SCENE.instantiate()
	hz.damage_per_second = 0.0
	hz.slow_factor = 0.6
	hz.duration = 4.0
	hz.zone_color = Color(0.722, 0.847, 0.816)
	hz.zone_radius = fog_radius
	hz.global_position = target_pos
	get_tree().current_scene.add_child(hz)

	_fog_cooldown = FOG_COOLDOWN_TIME


# ---------------------------------------------------------------------------
# Sedative Touch — melee slow
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > TOUCH_RANGE:
		return

	_attack_cooldown = 1.0 / attack_speed
	# Sedative touch: apply slow directly to the player
	if _target.has_method("apply_slow"):
		_target.apply_slow(0.5, 3.0)		
	AudioManager.SFXPlayer.play_sfx("enemy_grab")


# ---------------------------------------------------------------------------
# Healing Mist — channel 3s, then heal all enemies in radius
# ---------------------------------------------------------------------------

func _begin_heal_channel() -> void:
	_is_channeling_heal = true
	_healing_channel_timer = HEAL_CHANNEL_TIME
	velocity = Vector2.ZERO


func _complete_heal() -> void:
	if _disabled:
		return
	_heal_cooldown = HEAL_COOLDOWN_TIME

	var enemies := get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e == self:
			continue
		if not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) > HEAL_RADIUS:
			continue
		if not "torso_hp" in e:
			continue
		# Heal 15% of torso_hp
		var heal_amount := e.torso_hp * HEAL_PERCENT
		if "limb_health" in e and DamageZone.Zone.TORSO in e.limb_health:
			e.limb_health[DamageZone.Zone.TORSO] = minf(
				e.limb_health[DamageZone.Zone.TORSO] + heal_amount,
				e.torso_hp
			)


func _has_injured_allies_nearby() -> bool:
	var enemies := get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e == self:
			continue
		if not is_instance_valid(e):
			continue
		if global_position.distance_to(e.global_position) > HEAL_RADIUS:
			continue
		if "limb_health" in e and DamageZone.Zone.TORSO in e.limb_health:
			if e.limb_health[DamageZone.Zone.TORSO] < e.torso_hp:
				return true
	return false


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_ARM])

		if _arms_lost >= 2:
			# No fog at all, can only slow with touch (still works)
			attack_range = TOUCH_RANGE

	# Lost legs — stay in position, channel healing mist more often
	if DamageZone.is_leg(zone):
		var legs_lost := int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_LEG])
		if legs_lost >= 1:
			# More frequent healing
			_heal_cooldown = 0.0  # Immediate heal opportunity


func get_enemy_type() -> String:
	return enemy_type
