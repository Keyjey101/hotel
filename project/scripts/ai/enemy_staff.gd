extends "res://scripts/ai/base_enemy.gd"

## Staff enemy — weak alone, dangerous in groups.
## Design doc: 11_ENEMY_DESIGN.md section 2.1

var _courage_active: bool = false
var _base_aggression: float = 3.0


func _ready() -> void:
	# Override identity
	enemy_name = "Staff"
	enemy_type = "staff"

	# Override stats from design doc §2.1
	torso_hp = 40.0
	head_hp = 15.0
	arm_hp = 12.0
	leg_hp = 14.0
	move_speed = 120.0
	detection_range = 200.0
	attack_range = 40.0
	attack_damage = 10.0
	attack_speed = 1.0
	grab_strength = 2.0
	regen_speed_mult = 1.0
	aggression = 3.0
	coordination = 2.0

	_base_aggression = aggression
	super._ready()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_group_courage()


# ---------------------------------------------------------------------------
# Group Courage — Staff in groups of 4+ gain +4 Aggression
# ---------------------------------------------------------------------------

func _update_group_courage() -> void:
	var count := _count_nearby_staff(200.0)
	if count >= 4 and not _courage_active:
		_courage_active = true
		aggression = _base_aggression + 4.0
	elif count < 4 and _courage_active:
		_courage_active = false
		aggression = _base_aggression


func _count_nearby_staff(radius: float) -> int:
	var count := 1  # include self
	var enemies := get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e == self:
			continue
		if not e.has_method("get_enemy_type"):
			continue
		if e.get_enemy_type() != "staff":
			continue
		if global_position.distance_to(e.global_position) <= radius:
			count += 1
	return count


func get_enemy_type() -> String:
	return enemy_type


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_alert(delta: float) -> void:
	# Staff screams and alerts nearby within 250px, then falls through to base
	_alert_nearby()
	super._state_alert(delta)


func _state_chase(delta: float) -> void:
	# If alone (< 3 allies nearby), flee toward nearest ally instead
	var ally_count := _count_nearby_staff(250.0)
	if ally_count < 3 and _target != null:
		# Flee: move toward nearest Staff/Guard instead of chasing player
		var nearest_ally := _find_nearest_ally(400.0)
		if nearest_ally != null:
			navigation.target_position = nearest_ally.global_position
			var direction := navigation.get_next_path_position() - global_position
			velocity = direction.normalized() * move_speed
			return
	super._state_chase(delta)


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)
	var damage_zones = load("res://scripts/combat/damage_zones.gd")

	# Check all-severed condition FIRST — lie down, act as alert beacon
	var arms_severed: bool = severed_limbs.get(damage_zones.DamageZone.LEFT_ARM, false) and \
		severed_limbs.get(damage_zones.DamageZone.RIGHT_ARM, false)
	var legs_severed: bool = severed_limbs.get(damage_zones.DamageZone.LEFT_LEG, false) and \
		severed_limbs.get(damage_zones.DamageZone.RIGHT_LEG, false)
	if arms_severed and legs_severed:
		# Scream continuously as alert beacon
		_alert_nearby()
		return

	# Lost arm → drop weapon, flee toward nearest Guard
	if zone == damage_zones.DamageZone.LEFT_ARM or zone == damage_zones.DamageZone.RIGHT_ARM:
		if _current_state != "retreat":
			_enter_state("retreat")
		return

	# Lost leg → crawl toward room exit (retreat direction)
	if zone == damage_zones.DamageZone.LEFT_LEG or zone == damage_zones.DamageZone.RIGHT_LEG:
		if _current_state != "retreat":
			_enter_state("retreat")
		return


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _find_nearest_ally(radius: float) -> Node2D:
	var best: Node2D = null
	var best_dist := radius
	var enemies := get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e == self:
			continue
		if not e.has_method("get_enemy_type"):
			continue
		var dist := global_position.distance_to(e.global_position)
		if dist < best_dist:
			best = e
			best_dist = dist
	return best


func _perform_attack() -> void:
	# Weak strike with tray/broom — low damage, fast
	if _attack_cooldown > 0.0:
		return
	if _target == null:
		return
	_attack_cooldown = 1.0 / attack_speed
	_deal_melee_damage_to_player()
