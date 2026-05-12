extends "res://scripts/ai/base_enemy.gd"

## Drowned One enemy — Spa/Sloth Floor 5. Aquatic ambush predator.
## Nearly invisible in water, grapples from below. Slow and vulnerable on land.
## Design doc: Floor 5 Spa/Sloth

var is_in_water: bool = false
var _ambush_mode: bool = false
var _move_speed_water: float = 180.0
var _move_speed_land: float = 60.0
var _detection_water: float = 300.0
var _detection_land: float = 150.0
var _regen_water: float = 1.5
var _regen_land: float = 0.5
var _emerging: bool = false
var _water_mult: float = 1.0


func _ready() -> void:
	enemy_name = "Drowned One"
	enemy_type = "drowned_one"

	torso_hp = 65.0
	head_hp = 22.0
	arm_hp = 18.0
	leg_hp = 18.0
	move_speed = 60.0  # Starts on land
	detection_range = 150.0
	attack_range = 50.0
	attack_damage = 15.0
	attack_speed = 0.6
	grab_strength = 8.0
	regen_speed_mult = 0.5  # Starts on land
	aggression = 6.0
	coordination = 3.0

	super._ready()


func _physics_process(delta: float) -> void:
	_update_water_state()
	super._physics_process(delta)


# ---------------------------------------------------------------------------
# Water detection
# ---------------------------------------------------------------------------

func _update_water_state() -> void:
	var was_in_water := is_in_water
	is_in_water = false

	# Check overlapping areas for water zones
	var areas := hitbox.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("water"):
			is_in_water = true
			break

	if is_in_water != was_in_water:
		_on_water_changed()


func _on_water_changed() -> void:
	if is_in_water:
		_water_mult = _move_speed_water / _initial_move_speed
		detection_range = _detection_water
		regen_speed_mult = _regen_water
		# Enter ambush mode if in patrol
		if _current_state == "patrol":
			_enter_ambush()
	else:
		_water_mult = _move_speed_land / _initial_move_speed
		detection_range = _detection_land
		regen_speed_mult = _regen_land
		_ambush_mode = false
		_emerging = false
		# Restore visibility
		if sprite:
			sprite.modulate.a = 1.0
	_recalc_move_speed()


# ---------------------------------------------------------------------------
# Ambush mode — submerged and nearly invisible
# ---------------------------------------------------------------------------

func _enter_ambush() -> void:
	_ambush_mode = true
	_emerging = false
	if sprite:
		sprite.modulate.a = 0.1
	velocity = Vector2.ZERO


func _check_ambush_trigger() -> void:
	if not _ambush_mode:
		return
	if not _target or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist <= 80.0:
		# Emerge! Become visible and attack
		_emerging = true
		_ambush_mode = false
		if sprite:
			sprite.modulate.a = 1.0
		_enter_state("engage")


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_patrol(delta: float) -> void:
	if is_in_water:
		# Stay submerged in ambush
		if not _ambush_mode:
			_enter_ambush()
		if _target and is_instance_valid(_target):
			_check_ambush_trigger()
		velocity = Vector2.ZERO
		return

	# On land: slow crawl patrol
	if _patrol_points.is_empty():
		velocity = Vector2.ZERO
		return

	var target_pos := _patrol_points[_patrol_index]
	var dir := global_position.direction_to(target_pos)
	velocity = dir * move_speed * 0.4  # Extra slow crawl on land

	if global_position.distance_to(target_pos) < 10.0:
		_patrol_index = (_patrol_index + 1) % _patrol_points.size()


func _state_chase(delta: float) -> void:
	if _ambush_mode:
		_check_ambush_trigger()
		return

	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)

	# Speed depends on water state (already set in _on_water_changed)
	velocity = dir * move_speed
	_direction = dir

	if global_position.distance_to(_target.global_position) <= attack_range:
		_enter_state("engage")


func _state_engage(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	_direction = global_position.direction_to(_target.global_position)

	# In water: grapple attempt
	if is_in_water:
		if _attack_cooldown <= 0.0:
			_perform_grapple()
			_attack_cooldown = 1.0 / attack_speed
		velocity = _direction * move_speed * 0.5  # Slow approach in water
		return

	# On land: weak melee
	velocity = Vector2.ZERO

	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = 1.0 / attack_speed

	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Grapple from water
# ---------------------------------------------------------------------------

func _perform_grapple() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.5:
		return

	var arms_lost := int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
		int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
	var effective_grab := grab_strength - (arms_lost * 3.0)
	if effective_grab <= 0.0:
		return

	var roll := randf() * 10.0
	if roll <= effective_grab:
		EventBus.player_captured.emit()
		# Concept: pulling player into water — signal emitted,
		# player script handles the movement/forcing


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	var arms_lost := int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
		int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
	var legs_lost := int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + \
		int(severed_limbs[DamageZone.Zone.RIGHT_LEG])

	if is_in_water:
		# In water: arms lost = weaker grab (already handled in _perform_grapple)
		# Legs lost = still swims fast (water buoyancy)
		pass
	else:
		# On land: arms lost = helpless, retreat
		if arms_lost >= 2:
			if _current_state != "retreat":
				_enter_state("retreat")
		# Legs lost on land = nearly immobile
		if legs_lost >= 1 and not is_in_water:
			if legs_lost == 1:
				move_speed = _move_speed_land * 0.3
			elif legs_lost >= 2:
				move_speed = _move_speed_land * 0.1


func _recalc_move_speed() -> void:
	move_speed = _initial_move_speed * _water_mult

func get_enemy_type() -> String:
	return enemy_type


func _perform_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range:
		return

	_attack_cooldown = 1.0 / attack_speed

	if is_in_water:
		_perform_grapple()
	else:
		# Weak land melee
		_deal_melee_damage_to_player()
