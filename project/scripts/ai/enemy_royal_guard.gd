extends "res://scripts/ai/base_enemy.gd"

## Royal Guard enemy — formation fighter, shield wall, halberd + crossbow.
## Floor 8 Ballroom/Pride. Design doc: 11_ENEMY_DESIGN.md section 8.x

# Formation system
var _formation_role: String = "solo"  # "line", "wedge", "solo"
var _in_shield_wall: bool = false

# Crossbow tracking
var _crossbow_range: float = 250.0
var _crossbow_damage: float = 20.0
var _halberd_damage: float = 25.0
var _halberd_range: float = 55.0

# Shield wall visuals
var _shield_wall_visual: ColorRect
var _halberd_visual: ColorRect
var _helmet_visual: ColorRect


func _ready() -> void:
	# Override identity
	enemy_name = "Royal Guard"
	enemy_type = "royal_guard"

	# Override stats from design doc
	torso_hp = 100.0
	head_hp = 30.0
	arm_hp = 28.0
	leg_hp = 28.0
	move_speed = 130.0
	detection_range = 280.0
	attack_range = 55.0  # halberd reach
	attack_damage = 25.0  # halberd sweep
	attack_speed = 0.6
	grab_strength = 7.0
	regen_speed_mult = 1.0
	aggression = 7.0
	coordination = 10.0

	_crossbow_damage = 20.0
	_halberd_damage = 25.0

	add_to_group("royal_guards")
	super._ready()

	# Create equipment visuals (after super so sprite exists)
	_create_visuals()


func _create_visuals() -> void:
	# Halberd polearm
	_halberd_visual = ColorRect.new()
	_halberd_visual.name = "Halberd"
	_halberd_visual.size = Vector2(3.0, 48.0)
	_halberd_visual.color = Color(0.667, 0.667, 0.800, 1.0)  # #AAAACC polearm
	_halberd_visual.position = Vector2(16.0, -24.0)
	_halberd_visual.z_index = 1
	sprite.add_child(_halberd_visual)

	# Helmet gold accent
	_helmet_visual = ColorRect.new()
	_helmet_visual.name = "HelmetAccent"
	_helmet_visual.size = Vector2(20.0, 8.0)
	_helmet_visual.color = Color(0.855, 0.647, 0.125, 1.0)  # #DAA520 gold
	_helmet_visual.position = Vector2(-10.0, -26.0)
	_helmet_visual.z_index = 1
	sprite.add_child(_helmet_visual)

	# Shield wall indicator (hidden until active)
	_shield_wall_visual = ColorRect.new()
	_shield_wall_visual.name = "ShieldWallIndicator"
	_shield_wall_visual.size = Vector2(8.0, 20.0)
	_shield_wall_visual.color = Color(0.855, 0.647, 0.125, 0.5)  # gold glow
	_shield_wall_visual.position = Vector2(14.0, -10.0)
	_shield_wall_visual.z_index = 2
	_shield_wall_visual.visible = false
	sprite.add_child(_shield_wall_visual)


func get_enemy_type() -> String:
	return enemy_type


# ---------------------------------------------------------------------------
# Formation system
# ---------------------------------------------------------------------------

func _count_nearby_guards() -> int:
	var count := 0
	var guards := get_tree().get_nodes_in_group("royal_guards")
	for g in guards:
		if g == self or not is_instance_valid(g):
			continue
		if g._disabled:
			continue
		if global_position.distance_to(g.global_position) <= 150.0:
			count += 1
	return count


func _update_formation() -> void:
	var nearby := _count_nearby_guards()

	if nearby == 0:
		_formation_role = "solo"
		_in_shield_wall = false
	elif nearby == 1:
		# 2 guards total → Shield Wall
		_formation_role = "line"
	elif nearby >= 2:
		# 3-4 guards → Surround (wedge)
		_formation_role = "wedge"

	# Update shield wall status
	if _formation_role == "line" and _target != null and is_instance_valid(_target):
		# Shield wall active when player is in front
		var facing_dir := _direction.normalized()
		var to_player := global_position.direction_to(_target.global_position).normalized()
		var dot := facing_dir.dot(to_player)
		_in_shield_wall = dot > 0.3  # Player roughly in front
	else:
		_in_shield_wall = false

	# Toggle shield wall visual
	if _shield_wall_visual and is_instance_valid(_shield_wall_visual):
		_shield_wall_visual.visible = _in_shield_wall


func _find_nearest_ally_guard() -> Node2D:
	var best: Node2D = null
	var best_dist := 150.0
	var guards := get_tree().get_nodes_in_group("royal_guards")
	for g in guards:
		if g == self or not is_instance_valid(g):
			continue
		if g._disabled:
			continue
		var dist := global_position.distance_to(g.global_position)
		if dist < best_dist:
			best = g
			best_dist = dist
	return best


# ---------------------------------------------------------------------------
# Physics — update formation each frame
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	# Update formation before base processing
	if not _disabled:
		_update_formation()
	super._physics_process(delta)


# ---------------------------------------------------------------------------
# Damage — Shield Wall block override
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if _disabled:
		return

	# Shield Wall: 80% chance to block frontal attacks
	if _in_shield_wall and knockback_dir != Vector2.ZERO:
		var facing_dir := _direction.normalized()
		var incoming_dir := knockback_dir.normalized()
		var dot := facing_dir.dot(incoming_dir)
		if dot > 0.0:
			# Frontal hit while in shield wall
			if randf() < 0.8:
				# Blocked!
				_flash_hurt()
				EventBus.enemy_damaged.emit(self, zone, 0.0)
				return

	# Normal damage path
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


# ---------------------------------------------------------------------------
# State overrides — Formation movement
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var target_pos := _target.global_position

	if _in_shield_wall and _formation_role == "line":
		# Maintain line formation with partner guard
		var ally := _find_nearest_ally_guard()
		if ally != null:
			# Move to position alongside ally, between player and ally
			var midpoint := (ally.global_position + target_pos) * 0.5
			navigation.target_position = midpoint
		else:
			navigation.target_position = target_pos
	elif _formation_role == "wedge":
		# Surround pattern: offset perpendicular based on position
		var to_player := (target_pos - global_position).normalized()
		var perpendicular := Vector2(-to_player.y, to_player.x)
		# Determine which side based on horizontal offset
		var side: float = sign(global_position.x - target_pos.x)
		if side == 0.0:
			side = 1.0
		var surround_pos := target_pos + perpendicular * side * 60.0
		navigation.target_position = surround_pos
	else:
		# Solo: normal chase
		navigation.target_position = target_pos

	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	var dist_to_target := global_position.distance_to(target_pos)

	if dist_to_target <= _halberd_range:
		_enter_state("engage")
		return

	# Crossbow if too far for halberd but within crossbow range
	if dist_to_target > 80.0 and dist_to_target <= _crossbow_range:
		velocity = dir * move_speed * 0.5  # Slow advance while shooting
		_fire_crossbow()
	else:
		velocity = dir * move_speed

	_direction = dir


func _state_engage(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	var dist := global_position.distance_to(_target.global_position)

	# Halberd sweep at close range
	if dist <= 60.0:
		if _attack_cooldown <= 0.0:
			_perform_halberd_sweep()
			_attack_cooldown = 1.0 / attack_speed
	elif dist > 80.0:
		# Switch to crossbow if player backs off
		if _attack_cooldown <= 0.0:
			_fire_crossbow()
			_attack_cooldown = 1.0 / attack_speed
		# Re-chase if beyond crossbow effective range
		if dist > _crossbow_range:
			_enter_state("chase")

	# Re-enter chase if target moves well out of range
	if dist > _halberd_range * 2.0:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Attacks
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var dist := global_position.distance_to(_target.global_position)
	if dist <= 60.0:
		_perform_halberd_sweep()
	else:
		_fire_crossbow()


func _perform_halberd_sweep() -> void:
	# Halberd Sweep: wide arc, 25 dmg, hits in 120-degree cone
	if _target == null or not is_instance_valid(_target):
		return

	var dir_to_target := global_position.direction_to(_target.global_position)
	var dist := global_position.distance_to(_target.global_position)

	if dist <= _halberd_range:
		# Check if target is within 120-degree cone (dot > cos(60deg) = 0.5)
		var dot := _direction.normalized().dot(dir_to_target)
		if dot > 0.5:
			if _target.has_method("receive_damage"):
				_target.receive_damage(_halberd_damage, 0, false, 60.0, dir_to_target * -1.0)

	# Also hit other enemies in the cone (friendly fire)
	var enemies := get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e == self or not is_instance_valid(e):
			continue
		var e_dist := global_position.distance_to(e.global_position)
		if e_dist <= _halberd_range:
			var e_dir := global_position.direction_to(e.global_position).normalized()
			var e_dot := _direction.normalized().dot(e_dir)
			if e_dot > 0.5:
				if e.has_method("receive_damage"):
					e.receive_damage(_halberd_damage * 0.5, 0, false, 30.0, e_dir * -1.0)


func _fire_crossbow() -> void:
	# Crossbow: ranged, 20 dmg, precise shot at distance
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > _crossbow_range:
		return

	# Precise shot: apply damage directly (simple projectile simulation)
	# Slight delay to simulate bolt travel
	var dir_to_target := global_position.direction_to(_target.global_position)

	# Create a simple bolt projectile visual
	var bolt := ColorRect.new()
	bolt.name = "CrossbowBolt"
	bolt.size = Vector2(6.0, 2.0)
	bolt.color = Color(0.5, 0.5, 0.4, 1.0)
	bolt.position = global_position + dir_to_target * 20.0
	bolt.z_index = 5
	get_parent().add_child(bolt)

	# Animate bolt to target position
	var target_pos := _target.global_position
	var travel_time := 0.15
	var tween := create_tween()
	tween.tween_property(bolt, "global_position", target_pos, travel_time)
	tween.tween_callback(func() -> void:
		if is_instance_valid(bolt):
			bolt.queue_free()
		# Apply damage on arrival
		if _target != null and is_instance_valid(_target):
			if _target.has_method("receive_damage"):
				_target.receive_damage(_crossbow_damage, 0, false, 20.0, dir_to_target * -1.0)
	)


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	# One arm → defensive mode: lower aggression, stay back, crossbow only
	var arms_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_ARM, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false)
	var one_arm_lost: bool = severed_limbs.get(DamageZone.Zone.LEFT_ARM, false) or \
		severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false)

	if one_arm_lost and not arms_severed:
		# Defensive: lower aggression, prefer crossbow
		aggression = 3.0
		_halberd_damage = 15.0  # Weaker one-handed swings
		attack_speed = 0.8
		# Remove halberd visual on arm loss
		if DamageZone.is_arm(zone):
			if _halberd_visual and is_instance_valid(_halberd_visual):
				_halberd_visual.size = Vector2(2.0, 30.0)  # Shorter weapon
		return

	if arms_severed:
		# Both arms gone → can only headbutt, very weak
		attack_damage = 8.0
		if _halberd_visual and is_instance_valid(_halberd_visual):
			_halberd_visual.visible = false
		if _current_state != "retreat":
			_enter_state("retreat")
		return

	# Legs lost → static obstacle with shield still active
	var both_legs_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)
	if both_legs_severed:
		move_speed = 0.0
		# Shield wall stays active as a static barrier
		_in_shield_wall = true
		# Stay in engage if we have a target
		if _target != null and is_instance_valid(_target):
			if _current_state == "chase":
				_enter_state("engage")


# ---------------------------------------------------------------------------
# Boss command interface — called by The Consort
# ---------------------------------------------------------------------------

var _commanded_pos: Vector2 = Vector2.ZERO
var _commanded: bool = false
var _command_type: String = ""


func receive_command(cmd: String, target_pos: Vector2) -> void:
	_commanded = true
	_command_type = cmd
	_commanded_pos = target_pos
	match cmd:
		"shield_wall":
			_in_shield_wall = true
			if _shield_wall_visual and is_instance_valid(_shield_wall_visual):
				_shield_wall_visual.visible = true
		"surround":
			_in_shield_wall = false
			if _shield_wall_visual and is_instance_valid(_shield_wall_visual):
				_shield_wall_visual.visible = false
		"pinch":
			_in_shield_wall = false
			if _shield_wall_visual and is_instance_valid(_shield_wall_visual):
				_shield_wall_visual.visible = false
		"royal_guard":
			_in_shield_wall = false
			_enter_state("chase")
	if _current_state == "patrol":
		if _target == null or not is_instance_valid(_target):
			_target = get_tree().get_first_node_in_group("player")
		_enter_state("chase")
