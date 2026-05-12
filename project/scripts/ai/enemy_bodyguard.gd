extends "res://scripts/ai/base_enemy.gd"

## Bodyguard enemy — shielded protector of VIP enemies.
## Design doc: 11_ENEMY_DESIGN.md section 3.1

# Shield system
var shield_hp: float = 60.0
var shield_max_hp: float = 60.0
var has_shield: bool = true
var _shield_visual: ColorRect

# Protect target tracking
var _protect_target: Node2D = null
var _protect_repositioning: bool = false


func _ready() -> void:
	# Override identity
	enemy_name = "Bodyguard"
	enemy_type = "bodyguard"

	# Override stats from design doc §3.1
	torso_hp = 100.0
	head_hp = 30.0
	arm_hp = 28.0
	leg_hp = 28.0
	move_speed = 110.0
	detection_range = 200.0
	attack_range = 45.0
	attack_damage = 20.0
	attack_speed = 0.7
	grab_strength = 8.0
	regen_speed_mult = 0.8
	aggression = 5.0
	coordination = 7.0

	super._ready()

	# Create shield visual (after super so sprite exists)
	_create_shield_visual()

	# Connect to protect target damage signal
	EventBus.enemy_damaged.connect(_on_any_enemy_damaged)


func _exit_tree() -> void:
	if EventBus.enemy_damaged.is_connected(_on_any_enemy_damaged):
		EventBus.enemy_damaged.disconnect(_on_any_enemy_damaged)


func _create_shield_visual() -> void:
	_shield_visual = ColorRect.new()
	_shield_visual.name = "ShieldVisual"
	_shield_visual.size = Vector2(12.0, 28.0)
	_shield_visual.color = Color(0.533, 0.533, 0.533, 1.0)  # #888888 metallic grey
	# Offset forward from enemy center
	_shield_visual.position = Vector2(14.0, -14.0)
	_shield_visual.z_index = 1
	sprite.add_child(_shield_visual)


func get_enemy_type() -> String:
	return enemy_type


# ---------------------------------------------------------------------------
# Damage — Shield Block override
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if _disabled:
		return

	# Shield block: check if damage is frontal
	if has_shield and knockback_dir != Vector2.ZERO:
		var facing_dir := _direction.normalized()
		var incoming_dir := knockback_dir.normalized()
		# Dot product > 0 means the knockback direction points the same way
		# as our facing — i.e. the attack comes from the front
		var dot := facing_dir.dot(incoming_dir)
		if dot > 0.0:
			# Shield absorbs the damage
			shield_hp -= damage
			if shield_hp <= 0.0:
				_break_shield()
			# Shield fully blocks this hit — no HP damage applied
			_flash_hurt()
			EventBus.enemy_damaged.emit(self, zone, 0.0)
			return

	# Normal damage path (behind/side hits, or no shield)
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


func _break_shield() -> void:
	has_shield = false
	shield_hp = 0.0
	if _shield_visual and is_instance_valid(_shield_visual):
		_shield_visual.queue_free()
		_shield_visual = null


# ---------------------------------------------------------------------------
# State overrides — Protect behavior
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	# Check for protect target that needs repositioning
	if _update_protect_behavior(delta):
		return
	super._state_chase(delta)


func _state_engage(delta: float) -> void:
	# Check for protect target that needs repositioning
	if _update_protect_behavior(delta):
		return
	super._state_engage(delta)


func _update_protect_behavior(_delta: float) -> bool:
	# Find best protect target
	var target := _find_protect_target()
	if target == null or not is_instance_valid(target):
		_protect_target = null
		_protect_repositioning = false
		return false

	_protect_target = target

	# If protect target exists and player is detected, reposition between them
	if _target != null and is_instance_valid(_target):
		var dist_to_target := global_position.distance_to(target.global_position)
		var dist_protect_to_player := target.global_position.distance_to(_target.global_position)

		# Reposition if protect target is threatened (player within 150px of protect target)
		if dist_protect_to_player < 150.0:
			_protect_repositioning = true
			var midpoint := (target.global_position + _target.global_position) * 0.5
			navigation.target_position = midpoint
			var next_pos := navigation.get_next_path_position()
			var dir := global_position.direction_to(next_pos)
			velocity = dir * move_speed
			_direction = dir
			return true
		else:
			_protect_repositioning = false

	return false


func _find_protect_target() -> Node2D:
	# Priority: Seductress > Cultist
	var seductress := _find_nearest_in_group("seductresses")
	if seductress != null:
		return seductress
	var cultist := _find_nearest_in_group("cultists")
	if cultist != null:
		return cultist
	return null


func _find_nearest_in_group(group_name: String) -> Node2D:
	var best: Node2D = null
	var best_dist := 500.0  # Max protect range
	var nodes := get_tree().get_nodes_in_group(group_name)
	for node in nodes:
		if not is_instance_valid(node) or node == self:
			continue
		var dist := global_position.distance_to(node.global_position)
		if dist < best_dist:
			best = node
			best_dist = dist
	return best


func _on_any_enemy_damaged(enemy: Node2D, _zone: int, _damage: float) -> void:
	# If our protect target was hit, force reposition
	if _protect_target != null and enemy == _protect_target:
		_protect_repositioning = true


# ---------------------------------------------------------------------------
# Attack — Shield Bash
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	if _target == null or not is_instance_valid(_target):
		return

	_attack_cooldown = 1.0 / attack_speed

	# Shield Bash: knockback 100px + stun 0.5s
	var dir_to_target := global_position.direction_to(_target.global_position)

	# Apply damage
	if _target.has_method("receive_damage"):
		_target.receive_damage(attack_damage, 0, false, 100.0, dir_to_target * -1.0)

	# Apply stun to player if they support it
	if _target.has_method("apply_stun"):
		_target.apply_stun(0.5)


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)
	var damage_zones = load("res://scripts/combat/damage_zones.gd")

	# Right arm lost (shield arm) → drop shield immediately
	if zone == damage_zones.DamageZone.RIGHT_ARM:
		if has_shield:
			_break_shield()
		return

	# Left arm lost → continues bash and grab with one hand (no special change)
	if zone == damage_zones.DamageZone.LEFT_ARM:
		return

	# Both legs lost → sit, hold shield up as static barrier
	var both_legs_severed: bool = severed_limbs.get(damage_zones.DamageZone.LEFT_LEG, false) and \
		severed_limbs.get(damage_zones.DamageZone.RIGHT_LEG, false)
	if both_legs_severed:
		move_speed = 0.0
		# Remain in engage if we have a target — act as static shield barrier
		if _target != null and is_instance_valid(_target):
			if _current_state == "chase":
				_enter_state("engage")
		return
