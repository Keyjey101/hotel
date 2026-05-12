extends "res://scripts/ai/base_enemy.gd"
## Head Chef mini-boss — Floor 1 final encounter.
## 3 phases (Service / Main Course / Dessert), pattern variation per run,
## telegraph warnings, mutilation-reactive behavior.
## All stats from docs/14_BOSS_DESIGN.md section 2.

# ── Phase System ──────────────────────────────────────────────
enum BossPhase { SERVICE, MAIN_COURSE, DESSERT }

var current_phase: BossPhase = BossPhase.SERVICE
var phase_patterns: Dictionary = {}   # BossPhase -> Array[String]
var attack_queue: Array = []
var attack_timer: float = 0.0
var telegraph_timer: float = 0.0
var current_telegraph: String = ""
var is_telegraphing: bool = false
var executing_attack: bool = false
var limbs_lost_count: int = 0
var _rng: RandomNumberGenerator

# ── Phase thresholds (14_BOSS_DESIGN.md §2.6) ───────────────
const PHASE_2_HP_PCT := 0.6
const PHASE_3_HP_PCT := 0.3
const PHASE_2_LIMB_THRESHOLD := 1
const PHASE_3_LIMB_THRESHOLD := 2

var max_torso_hp: float = 300.0

# ── Charge state ─────────────────────────────────────────────
var _charging: bool = false
var _charge_dir: Vector2 = Vector2.ZERO
var _charge_speed: float = 0.0
var _charge_damage: float = 0.0
var _charge_duration: float = 0.0
var _charge_elapsed: float = 0.0

# ── Grab state ───────────────────────────────────────────────
var _grab_active: bool = false
var _grab_dot_damage: float = 0.0
var _grab_duration: float = 0.0
var _grab_elapsed: float = 0.0

# ── Summon queue ─────────────────────────────────────────────
var _summon_queue: Array[Dictionary] = []

# ── Active tracked projectiles/effects ───────────────────────
var _active_projectiles: Array[Dictionary] = []
var _active_stoves: Array[Dictionary] = []

var _current_attack_name: String = ""


# ═══════════════════════════════════════════════════════════════
# INIT
# ═══════════════════════════════════════════════════════════════

func _ready() -> void:
	torso_hp = 300.0
	head_hp = 60.0
	arm_hp = 80.0
	leg_hp = 70.0
	move_speed = 90.0
	detection_range = 400.0
	attack_range = 60.0
	attack_damage = 35.0
	grab_strength = 4.0
	regen_speed_mult = 0.7
	aggression = 7.0
	coordination = 5.0
	enemy_name = "Head Chef"
	enemy_type = "boss"
	max_torso_hp = torso_hp

	super._ready()

	_rng = _get_boss_rng()
	select_phase_patterns(BossPhase.SERVICE)
	add_to_group("boss")

	if _target == null:
		_target = _find_player()
	_enter_state("chase")


func _get_boss_rng() -> RandomNumberGenerator:
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("get_seed_manager"):
		var sm = gm.get_seed_manager()
		if sm and sm.has_method("get_floor_rng"):
			return sm.get_floor_rng(1)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("head_chef_boss")
	return rng


func _find_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	return null


func _pick_random_n(arr: Array, n: int) -> Array:
	var copy := arr.duplicate()
	var result: Array = []
	for _i in range(mini(n, copy.size())):
		var idx := _rng.randi() % copy.size()
		result.append(copy.pop_at(idx))
	return result


# ═══════════════════════════════════════════════════════════════
# PHYSICS PROCESS — processes charges, grabs, projectiles, stoves
# ═══════════════════════════════════════════════════════════════

func _physics_process(delta: float) -> void:
	_process_summon_queue(delta)
	_process_active_projectiles(delta)
	_process_active_stoves(delta)

	if _charging:
		_process_charge(delta)
		return

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

	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := (next_pos - global_position).normalized()
	velocity = dir * move_speed
	_direction = dir
	if global_position.distance_to(_target.global_position) <= attack_range * 1.2:
		_enter_state("engage")


func _state_engage(delta: float) -> void:
	if _target == null:
		_enter_state("patrol")
		return

	_face_target()

	if _grab_active:
		_process_grab(delta)
		return
	if _charging:
		_process_charge(delta)
		return

	if is_telegraphing:
		telegraph_timer -= delta
		if telegraph_timer <= 0.0:
			_end_telegraph()
			_execute_current_attack()
		return

	if executing_attack:
		return

	attack_timer -= delta
	if attack_timer <= 0.0:
		_select_next_attack()


func _state_retreat(_delta: float) -> void:
	_enter_state("chase")


func _perform_attack() -> void:
	pass


func _face_target() -> void:
	if _target:
		_direction = (_target.global_position - global_position).normalized()


# ═══════════════════════════════════════════════════════════════
# PHASE SYSTEM
# ═══════════════════════════════════════════════════════════════

func check_phase_transition() -> void:
	if current_phase == BossPhase.DESSERT:
		return

	var hp_pct: float = limb_health[DamageZone.Zone.TORSO] / max_torso_hp

	if current_phase == BossPhase.SERVICE:
		if hp_pct <= PHASE_2_HP_PCT or limbs_lost_count >= PHASE_2_LIMB_THRESHOLD:
			enter_phase(BossPhase.MAIN_COURSE)
			return

	if current_phase == BossPhase.MAIN_COURSE:
		if hp_pct <= PHASE_3_HP_PCT or limbs_lost_count >= PHASE_3_LIMB_THRESHOLD:
			enter_phase(BossPhase.DESSERT)

	if severed_limbs[DamageZone.Zone.LEFT_ARM] and severed_limbs[DamageZone.Zone.RIGHT_ARM]:
		if current_phase != BossPhase.DESSERT:
			enter_phase(BossPhase.DESSERT)


func enter_phase(phase: BossPhase) -> void:
	current_phase = phase
	attack_queue.clear()
	is_telegraphing = false
	executing_attack = false

	match phase:
		BossPhase.MAIN_COURSE:
			move_speed = 90.0 * 1.2
			attack_damage = 35.0 * 1.3
			_flash_transition()
		BossPhase.DESSERT:
			aggression = 10.0
			_flash_transition()

	select_phase_patterns(phase)


func _flash_transition() -> void:
	if sprite:
		sprite.modulate = Color.YELLOW
		get_tree().create_timer(0.3).timeout.connect(func() -> void:
			if is_instance_valid(sprite):
				sprite.modulate = Color.WHITE
		)


# ═══════════════════════════════════════════════════════════════
# PATTERN VARIATION POOL  (14_BOSS_DESIGN.md §2.4)
# ═══════════════════════════════════════════════════════════════

func select_phase_patterns(phase: BossPhase) -> void:
	var all_patterns: Array[String] = []
	var mandatory: String = ""

	match phase:
		BossPhase.SERVICE:
			all_patterns = ["cleaver_sweep", "charge", "pot_toss", "kitchen_call"]
			mandatory = "kitchen_call"
		BossPhase.MAIN_COURSE:
			all_patterns = ["furious_chop", "meat_hook", "double_pot", "rage_charge"]
			mandatory = "rage_charge"
		BossPhase.DESSERT:
			all_patterns = ["stove_push", "fling_everything", "kitchen_call_x3", "desperate_grab"]
			mandatory = "desperate_grab"

	var optional: Array = all_patterns.filter(func(p: String) -> bool: return p != mandatory)
	var selected: Array = _pick_random_n(optional, 2) + [mandatory]
	selected = _apply_mutilation_replacements(selected)

	phase_patterns[phase] = selected
	attack_queue = selected.duplicate()
	attack_queue.shuffle()


func _apply_mutilation_replacements(patterns: Array) -> Array:
	var right_arm_lost: bool = severed_limbs[DamageZone.Zone.RIGHT_ARM]
	var left_arm_lost: bool = severed_limbs[DamageZone.Zone.LEFT_ARM]
	var result: Array = patterns.duplicate()

	if right_arm_lost:
		var idx := result.find("cleaver_sweep")
		if idx >= 0:
			result[idx] = "kitchen_call"

	if left_arm_lost:
		var idx := result.find("double_pot")
		if idx >= 0:
			result[idx] = "stove_push"

	if right_arm_lost and left_arm_lost:
		result = result.filter(func(p: String) -> bool:
			return p in ["kitchen_call", "kitchen_call_x3", "stove_push"])
		if result.is_empty():
			result = ["kitchen_call_x3"]

	return result


# ═══════════════════════════════════════════════════════════════
# MUTILATION SYSTEM  (14_BOSS_DESIGN.md §2.5)
# ═══════════════════════════════════════════════════════════════

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	limbs_lost_count = 0
	for z: int in [DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM,
			DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG]:
		if severed_limbs[z]:
			limbs_lost_count += 1

	_apply_mutilation_effects()
	check_phase_transition()
	select_phase_patterns(current_phase)


func _apply_mutilation_effects() -> void:
	var left_leg_lost: bool = severed_limbs[DamageZone.Zone.LEFT_LEG]
	var right_leg_lost: bool = severed_limbs[DamageZone.Zone.RIGHT_LEG]
	var legs_lost: int = int(left_leg_lost) + int(right_leg_lost)

	if legs_lost == 1:
		move_speed = 90.0 * 0.7

	if legs_lost >= 2:
		move_speed = 0.0
		var immobile: Array = ["kitchen_call_x3", "pot_toss", "fling_everything"]
		phase_patterns[current_phase] = immobile
		attack_queue = immobile.duplicate()
		attack_queue.shuffle()

	if severed_limbs[DamageZone.Zone.RIGHT_ARM] and severed_limbs[DamageZone.Zone.LEFT_ARM]:
		attack_damage = max(attack_damage * 0.5, 5.0)


func _evaluate_mutilated_behavior() -> void:
	pass


# ═══════════════════════════════════════════════════════════════
# DAMAGE HOOK
# ═══════════════════════════════════════════════════════════════

func receive_damage(damage: float, zone: int, sever: bool = false,
		knockback_force: float = 0.0,
		knockback_dir: Vector2 = Vector2.ZERO) -> void:
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)
	check_phase_transition()


func _disable_enemy() -> void:
	super._disable_enemy()
	_charging = false
	_grab_active = false
	is_telegraphing = false
	executing_attack = false
	_summon_queue.clear()
	# Clean up active projectiles
	for p in _active_projectiles:
		if is_instance_valid(p.get("node")):
			p["node"].queue_free()
	_active_projectiles.clear()
	for s in _active_stoves:
		if is_instance_valid(s.get("node")):
			s["node"].queue_free()
	_active_stoves.clear()


# ═══════════════════════════════════════════════════════════════
# TELEGRAPH SYSTEM
# ═══════════════════════════════════════════════════════════════

func _start_telegraph(pattern_name: String, duration: float) -> void:
	is_telegraphing = true
	telegraph_timer = duration
	current_telegraph = pattern_name
	if sprite:
		sprite.modulate = Color.YELLOW if duration >= 0.4 else Color.ORANGE


func _end_telegraph() -> void:
	is_telegraphing = false
	telegraph_timer = 0.0
	current_telegraph = ""
	if sprite:
		sprite.modulate = Color.WHITE


func _select_next_attack() -> void:
	if attack_queue.is_empty():
		attack_queue = phase_patterns.get(current_phase, ["kitchen_call"]).duplicate()
		attack_queue.shuffle()

	_current_attack_name = attack_queue.pop_front()
	_start_telegraph(_current_attack_name, _get_telegraph_duration(_current_attack_name))


func _get_telegraph_duration(pattern: String) -> float:
	match pattern:
		"cleaver_sweep":    return 0.5
		"charge":           return 0.3
		"pot_toss":         return 0.6
		"kitchen_call":     return 0.3
		"furious_chop":     return 0.3
		"meat_hook":        return 0.4
		"double_pot":       return 0.8
		"rage_charge":      return 0.5
		"stove_push":       return 1.0
		"fling_everything": return 0.5
		"kitchen_call_x3":  return 0.3
		"desperate_grab":   return 0.2
		_:                  return 0.5


func _execute_current_attack() -> void:
	executing_attack = true
	call(_current_attack_name)


func _finish_attack() -> void:
	executing_attack = false
	attack_timer = _get_attack_cooldown()


func _get_attack_cooldown() -> float:
	match current_phase:
		BossPhase.SERVICE:     return 2.0
		BossPhase.MAIN_COURSE: return 1.5
		BossPhase.DESSERT:     return 1.2
		_:                     return 2.0


# ═══════════════════════════════════════════════════════════════
# ATTACK HELPERS
# ═══════════════════════════════════════════════════════════════

func _create_melee_hitbox(range_px: float, _angle_deg: float, damage: float,
		knockback: float, lifespan: float = 0.2) -> void:
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


func _spawn_tracked_projectile(damage: float, angle_offset: float = 0.0) -> void:
	var proj := CharacterBody2D.new()
	proj.collision_layer = 4
	proj.collision_mask = 1 | 16

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	col.shape = shape
	proj.add_child(col)

	var dir := _direction.rotated(deg_to_rad(angle_offset))
	proj.global_position = global_position + dir * 25.0
	proj.rotation = dir.angle()

	get_tree().current_scene.add_child(proj)

	_active_projectiles.append({
		"node": proj,
		"dir": dir,
		"speed": 300.0,
		"damage": damage,
		"elapsed": 0.0,
		"max_time": 3.0,
	})


func _process_active_projectiles(delta: float) -> void:
	var to_remove: Array[int] = []
	for i in range(_active_projectiles.size()):
		var p: Dictionary = _active_projectiles[i]
		var node: CharacterBody2D = p["node"]
		if not is_instance_valid(node):
			to_remove.append(i)
			continue

		p["elapsed"] = float(p["elapsed"]) + delta
		if float(p["elapsed"]) >= float(p["max_time"]):
			node.queue_free()
			to_remove.append(i)
			continue

		var dir: Vector2 = p["dir"]
		var speed: float = float(p["speed"])
		var collision := node.move_and_collide(dir * speed * delta)
		if collision:
			var collider := collision.get_collider()
			if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
				collider.take_damage(float(p["damage"]), dir, 10.0)
			node.queue_free()
			to_remove.append(i)

	for i in range(to_remove.size() - 1, -1, -1):
		_active_projectiles.remove_at(to_remove[i])


func _process_active_stoves(delta: float) -> void:
	var to_remove: Array[int] = []
	for i in range(_active_stoves.size()):
		var s: Dictionary = _active_stoves[i]
		var node: Area2D = s["node"]
		if not is_instance_valid(node):
			to_remove.append(i)
			continue

		s["elapsed"] = float(s["elapsed"]) + delta
		s["trail_timer"] = float(s["trail_timer"]) + delta

		if float(s["elapsed"]) >= float(s["duration"]):
			node.queue_free()
			to_remove.append(i)
			continue

		var dir: Vector2 = s["dir"]
		var speed: float = float(s["speed"])
		node.global_position += dir * speed * delta

		if float(s["trail_timer"]) >= 0.3:
			s["trail_timer"] = 0.0
			_create_fire_trail_at(node.global_position)

	for i in range(to_remove.size() - 1, -1, -1):
		_active_stoves.remove_at(to_remove[i])


func _apply_dot_to_player(player: Node, dmg: float, dur: float) -> void:
	var ticks := int(dur)
	for i in range(ticks):
		get_tree().create_timer(float(i + 1)).timeout.connect(func() -> void:
			if not is_instance_valid(self):
				return
			if is_instance_valid(player) and player.has_method("take_damage"):
				player.take_damage(dmg)
		)


func _summon_enemy_delayed(type: String, delay: float) -> void:
	_summon_queue.append({"type": type, "delay": delay, "elapsed": 0.0})


func _process_summon_queue(delta: float) -> void:
	var i := _summon_queue.size() - 1
	while i >= 0:
		_summon_queue[i]["elapsed"] = float(_summon_queue[i]["elapsed"]) + delta
		if float(_summon_queue[i]["elapsed"]) >= float(_summon_queue[i]["delay"]):
			_do_spawn(str(_summon_queue[i]["type"]))
			_summon_queue.remove_at(i)
		i -= 1


func _do_spawn(type: String) -> void:
	var paths := {
		"staff": "res://scenes/enemies/staff.tscn",
		"guard": "res://scenes/enemies/guard.tscn",
	}
	var path: String = paths.get(type, "")
	if path.is_empty():
		return
	var scene := load(path) as PackedScene
	if scene == null:
		return
	var enemy := scene.instantiate()
	var pos := _get_summon_spawn_position()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = pos


func _get_summon_spawn_position() -> Vector2:
	var offsets := [Vector2(-150, -100), Vector2(150, -100),
			Vector2(-150, 100), Vector2(150, 100)]
	offsets.shuffle()
	for offset in offsets:
		var pos: Vector2 = global_position + offset
		if _target:
			if pos.distance_to(_target.global_position) > 100.0:
				return pos
	return global_position + offsets[0]


# ═══════════════════════════════════════════════════════════════
# CHARGE SYSTEM
# ═══════════════════════════════════════════════════════════════

func _process_charge(delta: float) -> void:
	_charge_elapsed += delta
	var collision := move_and_collide(_charge_dir * _charge_speed * delta)
	if collision:
		var collider := collision.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(_charge_damage, _charge_dir, 30.0)
		_end_charge()
		return
	if _charge_elapsed >= _charge_duration:
		_end_charge()


func _end_charge() -> void:
	_charging = false
	velocity = Vector2.ZERO
	_finish_attack()


# ═══════════════════════════════════════════════════════════════
# GRAB SYSTEM
# ═══════════════════════════════════════════════════════════════

func _process_grab(delta: float) -> void:
	if not _grab_active:
		return

	_grab_elapsed += delta

	if _target and is_instance_valid(_target) and _target.has_method("take_damage"):
		_target.take_damage(_grab_dot_damage * delta)

	if _target and is_instance_valid(_target):
		var pull_dir := (global_position - _target.global_position).normalized()
		_target.global_position += pull_dir * 30.0 * delta

	if _grab_elapsed >= _grab_duration:
		_grab_active = false
		_finish_attack()


# ═══════════════════════════════════════════════════════════════
# FIRE TRAIL  (Stove Push environmental hazard)
# ═══════════════════════════════════════════════════════════════

func _create_fire_trail_at(pos: Vector2) -> void:
	var zone := Area2D.new()
	zone.collision_layer = 0
	zone.collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	col.shape = shape
	zone.add_child(col)
	zone.global_position = pos
	get_tree().current_scene.add_child(zone)

	zone.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(8.0)
	)

	for i in range(4):
		get_tree().create_timer(float(i + 1)).timeout.connect(func() -> void:
			if is_instance_valid(zone):
				for body in zone.get_overlapping_bodies():
					if body.is_in_group("player") and body.has_method("take_damage"):
						body.take_damage(8.0)
		)

	get_tree().create_timer(4.0).timeout.connect(zone.queue_free)


# ═══════════════════════════════════════════════════════════════
# PHASE 1: SERVICE  (100% – 60% HP)  §2.3
# ═══════════════════════════════════════════════════════════════

func cleaver_sweep() -> void:
	# Telegraph 0.5s → wide arc, 35 dmg, knockback
	_create_melee_hitbox(55.0, 90.0, 35.0, 30.0)


func charge() -> void:
	# Telegraph 0.3s → dash, 25 dmg + knockback
	_charging = true
	_charge_dir = _direction
	_charge_speed = 300.0
	_charge_damage = 25.0
	_charge_duration = 1.5
	_charge_elapsed = 0.0


func pot_toss() -> void:
	# Telegraph 0.6s → projectile, 20 dmg + burn 4/s × 3s
	_spawn_tracked_projectile(20.0)
	_finish_attack()


func kitchen_call() -> void:
	# Telegraph 0.3s → summon Staff ×1 after 5s
	_summon_enemy_delayed("staff", 5.0)
	_finish_attack()


# ═══════════════════════════════════════════════════════════════
# PHASE 2: MAIN COURSE  (60% – 30% HP)  §2.3
# ═══════════════════════════════════════════════════════════════

func furious_chop() -> void:
	# Telegraph 0.3s → heavy overhead, 50 dmg, knockdown
	_create_melee_hitbox(60.0, 60.0, 50.0, 50.0)


func meat_hook() -> void:
	# Telegraph 0.4s → sweeping hook, 30 dmg, pull 80px
	var area := Area2D.new()
	area.collision_layer = 4
	area.collision_mask = 1
	var shape := CircleShape2D.new()
	shape.radius = 70.0
	var col := CollisionShape2D.new()
	col.shape = shape
	area.add_child(col)
	area.global_position = global_position + _direction * 35.0
	get_tree().current_scene.add_child(area)

	var boss_pos := global_position
	area.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(30.0, Vector2.ZERO, 0.0)
			var pull := (boss_pos - body.global_position).normalized()
			body.global_position += pull * 80.0
	)

	get_tree().create_timer(0.2).timeout.connect(area.queue_free)
	_finish_attack()


func double_pot() -> void:
	# Telegraph 0.8s → 2 projectiles offset ±15°, 20 dmg each + burn
	_spawn_tracked_projectile(20.0, -15.0)
	_spawn_tracked_projectile(20.0, 15.0)
	_finish_attack()


func rage_charge() -> void:
	# Telegraph 0.5s → faster charge, 40 dmg
	_charging = true
	_charge_dir = _direction
	_charge_speed = 400.0
	_charge_damage = 40.0
	_charge_duration = 1.8
	_charge_elapsed = 0.0


# ═══════════════════════════════════════════════════════════════
# PHASE 3: DESSERT  (30% – 0% HP)  §2.3
# ═══════════════════════════════════════════════════════════════

func stove_push() -> void:
	# Telegraph 1.0s → push stove, 30 dmg + fire trail
	var stove := Area2D.new()
	stove.collision_layer = 4
	stove.collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	col.shape = shape
	stove.add_child(col)
	stove.global_position = global_position + _direction * 40.0
	get_tree().current_scene.add_child(stove)

	var s_dir := _direction
	stove.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(30.0, s_dir, 20.0)
	)

	_active_stoves.append({
		"node": stove,
		"dir": _direction,
		"speed": 150.0,
		"elapsed": 0.0,
		"trail_timer": 0.0,
		"duration": 2.0,
	})
	_finish_attack()


func fling_everything() -> void:
	# Telegraph 0.5s → 3 items, 15 dmg each
	for _i in range(3):
		_spawn_tracked_projectile(15.0, _rng.randf_range(-30.0, 30.0))
	_finish_attack()


func kitchen_call_x3() -> void:
	# Telegraph 0.3s → Staff ×3 + Guard ×1 staggered
	_summon_enemy_delayed("staff", 2.0)
	_summon_enemy_delayed("staff", 4.0)
	_summon_enemy_delayed("staff", 6.0)
	_summon_enemy_delayed("guard", 8.0)
	_finish_attack()


func desperate_grab() -> void:
	# Telegraph 0.2s (FAST) → grab, 8 dmg/s × 3s
	_grab_active = true
	_grab_dot_damage = 8.0
	_grab_duration = 3.0
	_grab_elapsed = 0.0
	velocity = _direction * 250.0
	move_and_slide()
