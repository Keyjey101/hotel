extends "res://scripts/ai/base_enemy.gd"
## The Gourmand — Floor 3 Banquet Hall boss (Gluttony).
## Consumption/growth system: eats corpses to grow bigger and stronger.
## 3 phases: Appetizer → Main Course → Digestif.
## All stats from docs/14_BOSS_DESIGN.md section 4.

# ── Phase System ──────────────────────────────────────────────
enum GourmandPhase { APPETIZER, MAIN_COURSE, DIGESTIF }

var current_phase: GourmandPhase = GourmandPhase.APPETIZER
var max_torso_hp: float = 350.0

# ── Consumption / Growth ──────────────────────────────────────
var corpses_eaten: int = 0
var growth_stage: int = 0  # 0=normal, 1=×1.5, 2=×2.0
var base_scale: float = 1.0
var base_damage: float = 25.0

# ── Corpse seeking ────────────────────────────────────────────
var _eating_corpse: StaticBody2D = null
var _eating_range: float = 20.0
var _corpse_detect_range: float = 120.0

# ── Attack system ─────────────────────────────────────────────
var attack_timer: float = 0.0
var is_telegraphing: bool = false
var telegraph_timer: float = 0.0
var executing_attack: bool = false
var _current_attack_name: String = ""
var _attack_patterns: Array[String] = []
var _rng: RandomNumberGenerator

# ── Belly Flop (Phase 2) ──────────────────────────────────────
var _is_flopping: bool = false
var _flop_target_pos: Vector2 = Vector2.ZERO
var _flop_height: float = 0.0
var _flop_elapsed: float = 0.0
const FLOP_DURATION: float = 0.6
const FLOP_MAX_HEIGHT: float = 120.0

# ── Rolling Charge (Phase 3) ──────────────────────────────────
var _is_charging: bool = false
var _charge_dir: Vector2 = Vector2.ZERO
var _charge_elapsed: float = 0.0
const CHARGE_SPEED: float = 300.0
const CHARGE_MAX_TIME: float = 2.0

# ── Grab (Phase 2) ────────────────────────────────────────────
var _grab_active: bool = false
var _grab_timer: float = 0.0
const GRAB_DURATION: float = 4.0
const GRAB_DPS: float = 10.0

# ── Summon system ─────────────────────────────────────────────
var _summon_timer: float = 15.0
var _summon_count: int = 0
const MAX_SUMMONS: int = 6

# ── Arena center ──────────────────────────────────────────────
var _arena_center: Vector2 = Vector2.ZERO


# ═══════════════════════════════════════════════════════════════
# INIT
# ═══════════════════════════════════════════════════════════════

func _ready() -> void:
	# Stats from 14_BOSS_DESIGN.md §4.1
	torso_hp = 350.0
	head_hp = 60.0
	arm_hp = 60.0
	leg_hp = 60.0
	move_speed = 60.0
	detection_range = 300.0
	attack_range = 55.0
	attack_damage = 25.0
	attack_speed = 0.5
	grab_strength = 6.0
	regen_speed_mult = 0.5
	aggression = 7.0
	coordination = 3.0
	enemy_name = "The Gourmand"
	enemy_type = "boss"
	max_torso_hp = torso_hp
	base_damage = attack_damage

	super._ready()

	_rng = _get_boss_rng()
	add_to_group("boss")
	_arena_center = global_position

	_select_phase_patterns()
	if _target == null:
		_target = _find_player()
	_enter_state("chase")


func _get_boss_rng() -> RandomNumberGenerator:
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("get_seed_manager"):
		var sm = gm.get_seed_manager()
		if sm and sm.has_method("get_floor_rng"):
			return sm.get_floor_rng(3)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("gourmand_boss")
	return rng


func _find_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	return null


# ═══════════════════════════════════════════════════════════════
# PHYSICS PROCESS
# ═══════════════════════════════════════════════════════════════

func _physics_process(delta: float) -> void:
	# Handle rolling charge movement
	if _is_charging:
		_process_charge(delta)
		return

	# Handle belly flop arc
	if _is_flopping:
		_process_flop(delta)
		return

	# Summon timer
	if _summon_timer > 0.0:
		_summon_timer -= delta

	# Grab DPS
	if _grab_active:
		_process_grab(delta)
		return

	super._physics_process(delta)


# ═══════════════════════════════════════════════════════════════
# STATE OVERRIDES
# ═══════════════════════════════════════════════════════════════

func _state_patrol(_delta: float) -> void:
	_enter_state("chase")


func _state_alert(_delta: float) -> void:
	_enter_state("chase")


func _state_chase(delta: float) -> void:
	if _target == null:
		_target = _find_player()
		if _target == null:
			return

	# Priority: eat nearby corpse > chase player
	if _has_nearby_corpse(_corpse_detect_range) and corpses_eaten < 6:
		_move_to_corpse(delta)
		return

	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := (next_pos - global_position).normalized()
	velocity = dir * move_speed
	_direction = dir
	move_and_slide()

	if global_position.distance_to(_target.global_position) <= attack_range * 1.2:
		_enter_state("engage")


func _state_engage(delta: float) -> void:
	if _target == null:
		_enter_state("chase")
		return

	_face_target()

	if _grab_active:
		_process_grab(delta)
		return

	if is_telegraphing:
		telegraph_timer -= delta
		if telegraph_timer <= 0.0:
			_end_telegraph()
			_execute_current_attack()
		return

	if executing_attack:
		return

	# Priority: eat nearby corpse
	if _has_nearby_corpse(_corpse_detect_range) and corpses_eaten < 6:
		_move_to_corpse(delta)
		return

	attack_timer -= delta
	if attack_timer <= 0.0:
		_select_next_attack()
		return

	# Stay close to player
	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		navigation.target_position = _target.global_position
		var next_pos := navigation.get_next_path_position()
		var dir := (next_pos - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()


func _state_retreat(_delta: float) -> void:
	_enter_state("chase")


func _perform_attack() -> void:
	pass


func _face_target() -> void:
	if _target:
		_direction = (_target.global_position - global_position).normalized()


# ═══════════════════════════════════════════════════════════════
# CONSUMPTION SYSTEM  (14_BOSS_DESIGN.md §4.2)
# ═══════════════════════════════════════════════════════════════

func _has_nearby_corpse(range_px: float) -> bool:
	var corpses := get_tree().get_nodes_in_group("corpses")
	for corpse in corpses:
		if not is_instance_valid(corpse):
			continue
		if corpse.is_consumed:
			continue
		var dist := global_position.distance_to(corpse.global_position)
		if dist < range_px:
			return true
	return false


func _move_to_corpse(delta: float) -> void:
	var nearest := _find_nearest_corpse(_corpse_detect_range)
	if nearest == null:
		return

	var dir := (nearest.global_position - global_position).normalized()
	velocity = dir * move_speed
	_direction = dir
	move_and_slide()

	# Check if close enough to eat
	var dist := global_position.distance_to(nearest.global_position)
	if dist < _eating_range:
		_eat_corpse(nearest)


func _find_nearest_corpse(range_px: float) -> StaticBody2D:
	var corpses := get_tree().get_nodes_in_group("corpses")
	var nearest: StaticBody2D = null
	var nearest_dist := range_px
	for corpse in corpses:
		if not is_instance_valid(corpse):
			continue
		if corpse.is_consumed:
			continue
		var dist := global_position.distance_to(corpse.global_position)
		if dist < nearest_dist:
			nearest = corpse
			nearest_dist = dist
	return nearest


func _eat_corpse(corpse: StaticBody2D) -> void:
	if corpse.is_consumed:
		return
	corpse.consume()
	corpses_eaten += 1
	_heal_from_eating(30.0)
	_apply_growth()
	check_phase_transition()


func _heal_from_eating(amount: float) -> void:
	limb_health[DamageZone.Zone.TORSO] = mini(
		limb_health[DamageZone.Zone.TORSO] + amount,
		max_torso_hp  # Cap at max (which includes growth bonuses)
	)


# ═══════════════════════════════════════════════════════════════
# GROWTH SYSTEM  (14_BOSS_DESIGN.md §4.3)
# ═══════════════════════════════════════════════════════════════

func _apply_growth() -> void:
	match corpses_eaten:
		2:  # Phase 2 threshold
			if growth_stage < 1:
				growth_stage = 1
				base_scale = 1.5
				scale = Vector2(1.5, 1.5)
				max_torso_hp += 100.0
				torso_hp += 100.0
				attack_damage = base_damage * 1.5
				_update_hurtbox_scale()
				_flash_growth()
		4:  # Phase 3 threshold
			if growth_stage < 2:
				growth_stage = 2
				base_scale = 2.0
				scale = Vector2(2.0, 2.0)
				max_torso_hp += 200.0
				torso_hp += 200.0
				attack_damage = base_damage * 2.0
				_update_hurtbox_scale()
				_flash_growth()


func _update_hurtbox_scale() -> void:
	# Hurtbox collision shapes scale with the node automatically
	# since they are children. But update HurtboxManager child scales
	# to keep proportions correct.
	var hm := get_node_or_null("HurtboxManager")
	if hm:
		for child in hm.get_children():
			if child is CollisionShape2D:
				# Shapes already scale with parent, no adjustment needed
				pass


func _flash_growth() -> void:
	if sprite:
		sprite.modulate = Color(1.0, 0.5, 0.0)  # orange flash
		get_tree().create_timer(0.4).timeout.connect(func() -> void:
			if is_instance_valid(sprite):
				sprite.modulate = Color.WHITE
		)


# ═══════════════════════════════════════════════════════════════
# PHASE SYSTEM  (14_BOSS_DESIGN.md §4.3)
# ═══════════════════════════════════════════════════════════════

func check_phase_transition() -> void:
	if current_phase == GourmandPhase.DIGESTIF:
		return

	var hp_pct: float = limb_health[DamageZone.Zone.TORSO] / max_torso_hp

	if current_phase == GourmandPhase.APPETIZER:
		if corpses_eaten >= 2:
			enter_phase(GourmandPhase.MAIN_COURSE)
			return

	if current_phase == GourmandPhase.MAIN_COURSE:
		if corpses_eaten >= 4 or hp_pct <= 0.3:
			enter_phase(GourmandPhase.DIGESTIF)


func enter_phase(phase: GourmandPhase) -> void:
	current_phase = phase
	attack_timer = 0.0
	is_telegraphing = false
	executing_attack = false

	match phase:
		GourmandPhase.MAIN_COURSE:
			_select_phase_patterns()
			_flash_growth()
		GourmandPhase.DIGESTIF:
			# Force growth to max if not already
			if growth_stage < 1:
				growth_stage = 1
				base_scale = 1.5
				scale = Vector2(1.5, 1.5)
				max_torso_hp += 100.0
				torso_hp += 100.0
				attack_damage = base_damage * 1.5
				_update_hurtbox_scale()
			if growth_stage < 2:
				growth_stage = 2
				base_scale = 2.0
				scale = Vector2(2.0, 2.0)
				max_torso_hp += 200.0
				torso_hp += 200.0
				attack_damage = base_damage * 2.0
				_update_hurtbox_scale()
			_select_phase_patterns()
			_flash_growth()


# ═══════════════════════════════════════════════════════════════
# PATTERN SELECTION
# ═══════════════════════════════════════════════════════════════

func _select_phase_patterns() -> void:
	match current_phase:
		GourmandPhase.APPETIZER:
			_attack_patterns = ["belly_bump", "vomit_spray"]
		GourmandPhase.MAIN_COURSE:
			_attack_patterns = ["belly_bump", "vomit_spray", "belly_flop", "grab_devour"]
		GourmandPhase.DIGESTIF:
			_attack_patterns = ["belly_bump", "rolling_charge", "acid_pool", "belly_flop"]
	attack_timer = 1.0


func _select_next_attack() -> void:
	if _attack_patterns.is_empty():
		_select_phase_patterns()
	_current_attack_name = _attack_patterns[_rng.randi() % _attack_patterns.size()]
	_start_telegraph(_current_attack_name, _get_telegraph_duration(_current_attack_name))


func _get_telegraph_duration(pattern: String) -> float:
	match pattern:
		"belly_bump":    return 0.3
		"vomit_spray":   return 0.5
		"belly_flop":    return 0.6
		"grab_devour":   return 0.4
		"rolling_charge": return 0.4
		"acid_pool":     return 0.5
		_:               return 0.4


# ═══════════════════════════════════════════════════════════════
# TELEGRAPH SYSTEM
# ═══════════════════════════════════════════════════════════════

func _start_telegraph(_pattern_name: String, duration: float) -> void:
	is_telegraphing = true
	telegraph_timer = duration
	if sprite:
		sprite.modulate = Color(1.0, 0.3, 0.0) if duration >= 0.4 else Color(1.0, 0.5, 0.2)


func _end_telegraph() -> void:
	is_telegraphing = false
	telegraph_timer = 0.0
	if sprite:
		sprite.modulate = Color.WHITE


func _execute_current_attack() -> void:
	executing_attack = true
	call(_current_attack_name)


func _finish_attack() -> void:
	executing_attack = false
	attack_timer = _get_attack_cooldown()


func _get_attack_cooldown() -> float:
	match current_phase:
		GourmandPhase.APPETIZER:    return 2.5
		GourmandPhase.MAIN_COURSE:  return 2.0
		GourmandPhase.DIGESTIF:     return 1.5
		_:                          return 2.5


# ═══════════════════════════════════════════════════════════════
# ATTACKS — PHASE 1: APPETIZER  (normal size)
# ═══════════════════════════════════════════════════════════════

func belly_bump() -> void:
	# Close range, 25 dmg, knockback 80px
	_create_melee_hitbox(attack_range, 25.0, 80.0)
	# Summon check
	_try_summon_enemy()


func vomit_spray() -> void:
	# Cone attack: 15 dmg + slow 30% for 3s
	# Create a hazard zone cone in front
	var zone_scene := load("res://scenes/combat/hazard_zone.tscn")
	if zone_scene == null:
		_finish_attack()
		return
	var zone = zone_scene.instantiate()
	zone.damage_per_second = 5.0
	zone.slow_factor = 0.7
	zone.duration = 3.0
	zone.zone_color = Color(0.333, 0.42, 0.184, 0.6)  # rot green
	zone.zone_radius = 48.0
	zone.global_position = global_position + _direction * 40.0
	get_tree().current_scene.call_deferred("add_child", zone)

	# Immediate cone damage
	var cone_area := Area2D.new()
	cone_area.collision_layer = 4
	cone_area.collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 55.0
	col.shape = shape
	cone_area.add_child(col)
	cone_area.global_position = global_position + _direction * 40.0
	get_tree().current_scene.add_child(cone_area)

	cone_area.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(15.0, _direction, 20.0)
	)
	get_tree().create_timer(0.3).timeout.connect(cone_area.queue_free)

	_finish_attack()


# ═══════════════════════════════════════════════════════════════
# ATTACKS — PHASE 2: MAIN COURSE  (size ×1.5)
# ═══════════════════════════════════════════════════════════════

func belly_flop() -> void:
	# Jump to player position, AoE shockwave on landing
	if _target == null:
		_finish_attack()
		return
	_is_flopping = true
	_flop_target_pos = _target.global_position
	_flop_elapsed = 0.0
	_flop_height = 0.0
	# Disable collision during jump
	collision_mask = 0


func _process_flop(delta: float) -> void:
	_flop_elapsed += delta
	var t := _flop_elapsed / FLOP_DURATION

	if t >= 1.0:
		# Land
		global_position = _flop_target_pos
		_is_flopping = false
		collision_mask = 7  # Restore default
		_flop_height = 0.0

		# AoE shockwave: 30 dmg + knockdown
		var impact_area := Area2D.new()
		impact_area.collision_layer = 4
		impact_area.collision_mask = 1
		var col := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 80.0
		col.shape = shape
		impact_area.add_child(col)
		impact_area.global_position = global_position
		get_tree().current_scene.add_child(impact_area)

		impact_area.body_entered.connect(func(body: Node2D) -> void:
			if body.is_in_group("player") and body.has_method("take_damage"):
				body.take_damage(30.0, (body.global_position - global_position).normalized(), 50.0)
				if body.has_method("apply_stun"):
					body.apply_stun(0.8)
		)
		get_tree().create_timer(0.3).timeout.connect(impact_area.queue_free)

		# Visual impact
		if sprite:
			sprite.offset.y = 0.0
		_finish_attack()
		return

	# Arc movement
	var start_pos := global_position
	global_position = start_pos.lerp(_flop_target_pos, t)
	_flop_height = sin(t * PI) * FLOP_MAX_HEIGHT

	# Visual offset for jump arc
	if sprite:
		sprite.offset.y = -_flop_height


func grab_devour() -> void:
	# Grab player → 10 dmg/s, player can break free
	# If enemy nearby → eat THEM instead
	if _target == null:
		_finish_attack()
		return

	# Check for nearby enemy to eat first
	var nearest_enemy := _find_nearest_enemy(80.0)
	if nearest_enemy != null:
		# Eat enemy instead of grabbing player
		nearest_enemy._disable_enemy()
		corpses_eaten += 1
		_heal_from_eating(30.0)
		_apply_growth()
		check_phase_transition()
		_finish_attack()
		return

	# Grab player
	var dist := global_position.distance_to(_target.global_position)
	if dist < attack_range * 1.5:
		_grab_active = true
		_grab_timer = GRAB_DURATION
		EventBus.player_captured.emit()
	else:
		_finish_attack()


func _process_grab(delta: float) -> void:
	_grab_timer -= delta
	if _grab_timer <= 0.0 or _target == null:
		_release_grab()
		return

	# Deal DPS to player
	if _target.has_method("take_damage"):
		_target.take_damage(GRAB_DPS * delta)

	# Stay close
	if _target:
		var dir := (_target.global_position - global_position).normalized()
		velocity = dir * move_speed * 0.5
		move_and_slide()


func _release_grab() -> void:
	_grab_active = false
	_grab_timer = 0.0
	_finish_attack()


func _find_nearest_enemy(range_px: float) -> Node:
	var enemies := get_tree().get_nodes_in_group("enemy")
	var nearest: Node = null
	var nearest_dist := range_px
	for enemy in enemies:
		if enemy == self:
			continue
		if not is_instance_valid(enemy):
			continue
		if enemy._disabled:
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	return nearest


# ═══════════════════════════════════════════════════════════════
# ATTACKS — PHASE 3: DIGESTIF  (size ×2)
# ═══════════════════════════════════════════════════════════════

func rolling_charge() -> void:
	# Roll toward player at 300 px/s, 50 dmg, continues until hitting wall or 2s
	if _target == null:
		_finish_attack()
		return
	_is_charging = true
	_charge_dir = (_target.global_position - global_position).normalized()
	_charge_elapsed = 0.0


func _process_charge(delta: float) -> void:
	_charge_elapsed += delta

	var collision := move_and_collide(_charge_dir * CHARGE_SPEED * delta)
	if collision:
		var collider := collision.get_collider()
		if collider:
			if collider.is_in_group("player") and collider.has_method("take_damage"):
				collider.take_damage(50.0, _charge_dir, 40.0)
			# Hit wall or obstacle → stop
			if collider is StaticBody2D:
				_end_charge()
				return

	# Knockback all entities in path
	_hit_entities_in_path()

	if _charge_elapsed >= CHARGE_MAX_TIME:
		_end_charge()


func _hit_entities_in_path() -> void:
	var space := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = global_position + _charge_dir * 20.0
	params.collision_mask = 1  # player layer
	var results := space.intersect_point(params)
	for result in results:
		var body: Node2D = result["collider"]
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(50.0, _charge_dir, 40.0)


func _end_charge() -> void:
	_is_charging = false
	_charge_elapsed = 0.0
	_finish_attack()


func acid_pool() -> void:
	# Persistent acid zone: 10 dmg/s, 6s, radius 48
	var zone_scene := load("res://scenes/combat/hazard_zone.tscn")
	if zone_scene == null:
		_finish_attack()
		return
	var zone = zone_scene.instantiate()
	zone.damage_per_second = 10.0
	zone.slow_factor = 1.0
	zone.duration = 6.0
	zone.zone_color = Color(0.333, 0.42, 0.184, 0.7)  # rot green #556B2F
	zone.zone_radius = 48.0
	zone.global_position = global_position + _direction * 30.0
	zone.add_to_group("hazard_zone")
	get_tree().current_scene.call_deferred("add_child", zone)

	_finish_attack()


# ═══════════════════════════════════════════════════════════════
# EAT OWN SEVERED LIMBS (Phase 3 only)
# ═══════════════════════════════════════════════════════════════

func try_eat_own_limb() -> void:
	if growth_stage < 2:
		return
	# Find nearest severed limb in gore system
	var gm := get_node_or_null("/root/GoreSystem")
	if gm == null:
		return
	if not gm.has("_active_limbs"):
		return
	var limbs: Array = gm._active_limbs
	var nearest_limb: RigidBody2D = null
	var nearest_dist := 80.0
	for limb in limbs:
		if not is_instance_valid(limb):
			continue
		var dist := global_position.distance_to(limb.global_position)
		if dist < nearest_dist:
			nearest_limb = limb
			nearest_dist = dist
	if nearest_limb:
		# Move to limb
		var dir := (nearest_limb.global_position - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()
		if global_position.distance_to(nearest_limb.global_position) < 20.0:
			nearest_limb.queue_free()
			_heal_from_eating(30.0)


# ═══════════════════════════════════════════════════════════════
# SUMMON SYSTEM
# ═══════════════════════════════════════════════════════════════

func _try_summon_enemy() -> void:
	if _summon_timer > 0.0:
		return
	if _summon_count >= MAX_SUMMONS:
		return

	var scene_path: String
	match current_phase:
		GourmandPhase.APPETIZER:
			scene_path = "res://scenes/enemies/staff.tscn"
			_summon_timer = 15.0
		GourmandPhase.MAIN_COURSE:
			scene_path = "res://scenes/enemies/taster.tscn"
			_summon_timer = 20.0
		GourmandPhase.DIGESTIF:
			scene_path = "res://scenes/enemies/staff.tscn"
			_summon_timer = 12.0
		_:
			_finish_attack()
			return

	var scene := load(scene_path) as PackedScene
	if scene == null:
		_finish_attack()
		return

	var enemy := scene.instantiate()
	var offset := Vector2(_rng.randf_range(-60, 60), _rng.randf_range(-60, 60))
	enemy.global_position = _arena_center + offset
	get_parent().call_deferred("add_child", enemy)
	_summon_count += 1
	_finish_attack()


# ═══════════════════════════════════════════════════════════════
# ATTACK HELPERS
# ═══════════════════════════════════════════════════════════════

func _create_melee_hitbox(range_px: float, damage: float, knockback: float, lifespan: float = 0.2) -> void:
	var area := Area2D.new()
	area.collision_layer = 4
	area.collision_mask = 1

	var shape := CircleShape2D.new()
	shape.radius = range_px
	var col := CollisionShape2D.new()
	col.shape = shape
	area.add_child(col)

	area.global_position = global_position + _direction * range_px * 0.5
	get_tree().current_scene.add_child(area)

	area.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(damage, _direction, knockback)
	)

	get_tree().create_timer(lifespan).timeout.connect(area.queue_free)
	_finish_attack()


# ═══════════════════════════════════════════════════════════════
# DAMAGE / MUTILATION HOOKS
# ═══════════════════════════════════════════════════════════════

func receive_damage(damage: float, zone: int, sever: bool = false,
		knockback_force: float = 0.0,
		knockback_dir: Vector2 = Vector2.ZERO) -> void:
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)
	check_phase_transition()

	# Phase 3: try to eat own limb when hurt
	if current_phase == GourmandPhase.DIGESTIF:
		try_eat_own_limb()


func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)
	check_phase_transition()
	_select_phase_patterns()

	# Phase 3: try to eat own severed limb
	if current_phase == GourmandPhase.DIGESTIF:
		try_eat_own_limb()


func _evaluate_mutilated_behavior() -> void:
	# Gourmand never retreats — always aggressive
	pass


func _disable_enemy() -> void:
	super._disable_enemy()
	is_telegraphing = false
	executing_attack = false
	_is_charging = false
	_is_flopping = false
	if _grab_active:
		_release_grab()
