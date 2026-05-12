extends "res://scripts/ai/base_enemy.gd"

## Guard enemy — works in pairs, flanks, radio alerts all guards.
## Design doc: 11_ENEMY_DESIGN.md section 2.2

var _partner: Node2D = null
var _base_aggression: float = 6.0


func _ready() -> void:
	enemy_name = "Guard"
	enemy_type = "guard"

	torso_hp = 70.0
	head_hp = 25.0
	arm_hp = 20.0
	leg_hp = 22.0
	move_speed = 140.0
	detection_range = 280.0
	attack_range = 50.0
	attack_damage = 18.0
	attack_speed = 0.8
	grab_strength = 7.0
	regen_speed_mult = 0.9
	aggression = 6.0
	coordination = 8.0

	_base_aggression = aggression
	add_to_group("guards")
	super._ready()
	_find_partner()


# ---------------------------------------------------------------------------
# Partner system
# ---------------------------------------------------------------------------

func _find_partner() -> void:
	var guards := get_tree().get_nodes_in_group("guards")
	for g in guards:
		if g == self:
			continue
		_partner = g
		return


func _check_partner_alive() -> bool:
	if _partner == null or not is_instance_valid(_partner):
		return false
	return not _partner._disabled


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if _target == null:
		_enter_state("patrol")
		return

	var target_pos := _target.global_position
	var has_alive_partner := _check_partner_alive()

	# Check if partner lost → more aggressive (+3)
	if not has_alive_partner and _partner != null:
		aggression = _base_aggression + 3.0

	if has_alive_partner and _partner.has_method("_target") and _partner._target == _target:
		# Flanking: offset perpendicular to the player direction
		var to_player := (target_pos - global_position).normalized()
		var perpendicular := Vector2(-to_player.y, to_player.x)
		# Offset away from partner's side
		var partner_offset := global_position - _partner.global_position
		var side: float = sign(perpendicular.dot(partner_offset))
		if side == 0.0:
			side = 1.0
		var flank_target := target_pos + perpendicular * side * 100.0
		navigation.target_position = flank_target
	else:
		navigation.target_position = target_pos

	var direction := navigation.get_next_path_position() - global_position
	var dist := direction.length()

	if dist <= attack_range:
		_enter_state("engage")
		return

	velocity = direction.normalized() * move_speed
	move_and_slide()


# ---------------------------------------------------------------------------
# Alert override — radio alert to ALL guards on floor
# ---------------------------------------------------------------------------

func _state_alert(delta: float) -> void:
	# Radio alert: notify all guards
	var guards := get_tree().get_nodes_in_group("guards")
	for g in guards:
		if g == self:
			continue
		if g.has_method("on_nearby_alert"):
			g.on_nearby_alert(global_position)
	super._state_alert(delta)


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)
	var damage_zones = load("res://scripts/combat/damage_zones.gd")

	# Lost arm → switch to kick/headbutt (damage 12), fall back to another Guard
	if zone == damage_zones.DamageZone.LEFT_ARM or zone == damage_zones.DamageZone.RIGHT_ARM:
		attack_damage = 12.0  # kick/headbutt damage
		if _current_state != "retreat":
			_enter_state("retreat")
		return

	# Lost leg → command post: coordination radius +50%, don't move
	if zone == damage_zones.DamageZone.LEFT_LEG or zone == damage_zones.DamageZone.RIGHT_LEG:
		coordination = 8.0 * 1.5
		# Stay in place, direct others (base engage handles stationary)
		return

	# Lost both legs → full command post mode
	var legs_severed: bool = severed_limbs.get(damage_zones.DamageZone.LEFT_LEG, false) and \
		severed_limbs.get(damage_zones.DamageZone.RIGHT_LEG, false)
	if legs_severed:
		coordination = 8.0 * 1.5
		# Don't move, direct others from position
		move_speed = 0.0


func _perform_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	if _target == null:
		return
	_attack_cooldown = 1.0 / attack_speed
	# Baton strike — base attack_damage handles it
	EventBus.enemy_damaged.emit(self, 0, 0)  # placeholder attack event


func get_enemy_type() -> String:
	return enemy_type
