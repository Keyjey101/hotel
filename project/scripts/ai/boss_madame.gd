extends "res://scripts/ai/base_enemy.gd"
## Madame mini-boss — Floor 2 Red Light District final encounter.
## 3 phases (Reflection / Shattered / True Face), mirror clone deception,
## breakable mirrors, teleport, bodyguard summon.
## All stats from docs/14_BOSS_DESIGN.md section 3.

# ── Phase System ──────────────────────────────────────────────
enum BossPhase { REFLECTION, SHATTERED, TRUE_FACE }

var current_phase: BossPhase = BossPhase.REFLECTION
var max_torso_hp: float = 250.0
var limbs_lost_count: int = 0

# ── Phase thresholds (14_BOSS_DESIGN.md §3.4) ───────────────
const PHASE_2_HP_PCT := 0.5
const PHASE_3_HP_PCT := 0.25
const PHASE_2_LIMB_THRESHOLD := 1
const PHASE_3_LIMB_THRESHOLD := 2

# ── Mirror Clone System ──────────────────────────────────────
var clones: Array[Node2D] = []
var max_clones: int = 2
var _position_history: Array[Vector2] = []
var _clone_history_timer: float = 0.0
const CLONE_DELAY: float = 0.3
const MAX_HISTORY: int = 18  # CLONE_DELAY * 60

# ── Mirror tracking ──────────────────────────────────────────
var _mirrors: Array[Node] = []  # breakable mirror objects in arena

# ── Teleport (Phase 2) ───────────────────────────────────────
var _teleport_cooldown: float = 0.0
const TELEPORT_COOLDOWN_BASE := 5.0

# ── Attack system ────────────────────────────────────────────
var attack_timer: float = 0.0
var is_telegraphing: bool = false
var telegraph_timer: float = 0.0
var executing_attack: bool = false
var _current_attack_name: String = ""
var _attack_patterns: Array[String] = []
var _rng: RandomNumberGenerator

# ── Bodyguard summon (Phase 3, once) ─────────────────────────
var _bodyguard_summoned: bool = false

# ── Shadow visual (real Madame identifier) ───────────────────
var _shadow_visual: ColorRect = null

# ── Arena center (for mirror placement / teleport) ───────────
var _arena_center: Vector2 = Vector2.ZERO

# ── Clone damage cooldown (Phase 2) ──────────────────────────
var _clone_damage_cooldowns: Dictionary = {}  # clone -> float


# ═══════════════════════════════════════════════════════════════
# INIT
# ═══════════════════════════════════════════════════════════════

func _ready() -> void:
	# Stats from 14_BOSS_DESIGN.md §3.1
	torso_hp = 250.0
	head_hp = 50.0
	arm_hp = 40.0
	leg_hp = 40.0
	move_speed = 150.0
	detection_range = 400.0
	attack_range = 40.0
	attack_damage = 15.0
	attack_speed = 0.6
	grab_strength = 5.0
	regen_speed_mult = 1.2
	aggression = 4.0
	coordination = 7.0
	enemy_name = "Madame"
	enemy_type = "boss"
	max_torso_hp = torso_hp

	super._ready()

	# Shadow indicator — real Madame has this, clones don't
	_shadow_visual = ColorRect.new()
	_shadow_visual.size = Vector2(20.0, 4.0)
	_shadow_visual.position = Vector2(-10.0, 20.0)
	_shadow_visual.color = Color(0.0, 0.0, 0.0, 0.3)
	add_child(_shadow_visual)

	_rng = _get_boss_rng()
	add_to_group("boss")

	_arena_center = global_position
	_create_arena_mirrors()
	_find_existing_mirrors()

	spawn_clones(max_clones)
	_select_phase_patterns()

	if _target == null:
		_target = _find_player()
	_enter_state("chase")


func _get_boss_rng() -> RandomNumberGenerator:
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("get_seed_manager"):
		var sm = gm.get_seed_manager()
		if sm and sm.has_method("get_floor_rng"):
			return sm.get_floor_rng(2)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("madame_boss")
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
	_update_position_history(delta)
	_update_clone_positions(delta)
	_update_clone_damage_cooldowns(delta)

	if _teleport_cooldown > 0.0:
		_teleport_cooldown -= delta

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
	move_and_slide()

	if global_position.distance_to(_target.global_position) <= attack_range * 1.2:
		_enter_state("engage")


func _state_engage(delta: float) -> void:
	if _target == null:
		_enter_state("patrol")
		return

	_face_target()

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

	# Teleport in Phase 2
	if current_phase == BossPhase.SHATTERED:
		_try_teleport()


func _state_retreat(_delta: float) -> void:
	_enter_state("chase")


func _perform_attack() -> void:
	pass


func _face_target() -> void:
	if _target:
		_direction = (_target.global_position - global_position).normalized()


# ═══════════════════════════════════════════════════════════════
# PHASE SYSTEM  (14_BOSS_DESIGN.md §3.4)
# ═══════════════════════════════════════════════════════════════

func check_phase_transition() -> void:
	if current_phase == BossPhase.TRUE_FACE:
		return

	var hp_pct: float = limb_health[DamageZone.Zone.TORSO] / max_torso_hp

	if current_phase == BossPhase.REFLECTION:
		if hp_pct <= PHASE_2_HP_PCT or limbs_lost_count >= PHASE_2_LIMB_THRESHOLD:
			enter_phase(BossPhase.SHATTERED)
			return

	if current_phase == BossPhase.SHATTERED:
		if hp_pct <= PHASE_3_HP_PCT or limbs_lost_count >= PHASE_3_LIMB_THRESHOLD:
			enter_phase(BossPhase.TRUE_FACE)

	# Both arms severed → immediate Phase 3
	if severed_limbs[DamageZone.Zone.LEFT_ARM] and severed_limbs[DamageZone.Zone.RIGHT_ARM]:
		if current_phase != BossPhase.TRUE_FACE:
			enter_phase(BossPhase.TRUE_FACE)


func enter_phase(phase: BossPhase) -> void:
	current_phase = phase
	attack_timer = 0.0
	is_telegraphing = false
	executing_attack = false

	match phase:
		BossPhase.SHATTERED:
			max_clones = 3
			_spawn_extra_clones()
			_select_phase_patterns()
			_flash_transition()
		BossPhase.TRUE_FACE:
			_break_all_mirrors()
			max_clones = 0
			_clear_all_clones()
			move_speed = 150.0 * 1.4
			aggression = 10.0
			_select_phase_patterns()
			_flash_transition()
			if not _bodyguard_summoned:
				_summon_bodyguard()


func _flash_transition() -> void:
	if sprite:
		sprite.modulate = Color(1.0, 0.102, 0.427)  # hot pink flash
		get_tree().create_timer(0.3).timeout.connect(func() -> void:
			if is_instance_valid(sprite):
				sprite.modulate = Color.WHITE
		)


# ═══════════════════════════════════════════════════════════════
# PATTERN SELECTION
# ═══════════════════════════════════════════════════════════════

func _select_phase_patterns() -> void:
	match current_phase:
		BossPhase.REFLECTION:
			_attack_patterns = ["kiss", "dagger_swipe"]
		BossPhase.SHATTERED:
			_attack_patterns = ["kiss", "dagger_swipe", "mirror_shard_throw"]
		BossPhase.TRUE_FACE:
			_attack_patterns = ["dash_attack", "scream"]
	attack_timer = 1.0


func _select_next_attack() -> void:
	if _attack_patterns.is_empty():
		_select_phase_patterns()
	_current_attack_name = _attack_patterns[_rng.randi() % _attack_patterns.size()]
	_start_telegraph(_current_attack_name, _get_telegraph_duration(_current_attack_name))


func _get_telegraph_duration(pattern: String) -> float:
	match pattern:
		"kiss":               return 0.4
		"dagger_swipe":       return 0.3
		"mirror_shard_throw": return 0.6
		"dash_attack":        return 0.3
		"scream":             return 0.5
		_:                    return 0.4


# ═══════════════════════════════════════════════════════════════
# TELEGRAPH SYSTEM
# ═══════════════════════════════════════════════════════════════

func _start_telegraph(pattern_name: String, duration: float) -> void:
	is_telegraphing = true
	telegraph_timer = duration
	if sprite:
		sprite.modulate = Color(1.0, 0.8, 0.4) if duration >= 0.4 else Color(1.0, 0.5, 0.2)


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
		BossPhase.REFLECTION:  return 2.0
		BossPhase.SHATTERED:   return 1.5
		BossPhase.TRUE_FACE:   return 1.0
		_:                     return 2.0


# ═══════════════════════════════════════════════════════════════
# MIRROR CLONE SYSTEM  (14_BOSS_DESIGN.md §3.3)
# ═══════════════════════════════════════════════════════════════

func spawn_clones(count: int) -> void:
	for i in range(count):
		if clones.size() >= max_clones:
			break
		var clone := _create_clone()
		if clone:
			clones.append(clone)


func _create_clone() -> Node2D:
	var clone := Node2D.new()
	clone.set_meta("is_clone", true)

	# Visual: same as Madame but no shadow
	var visual := ColorRect.new()
	visual.size = Vector2(28.0, 40.0)
	visual.position = -visual.size / 2.0
	visual.color = Color(1.0, 0.102, 0.427, 0.9)  # hot pink
	clone.add_child(visual)

	# Hit detection: shatters when player touches
	var hit_area := Area2D.new()
	hit_area.collision_layer = 0
	hit_area.collision_mask = 1  # detect player body
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 18.0
	col.shape = shape
	hit_area.add_child(col)
	clone.add_child(hit_area)
	hit_area.body_entered.connect(_on_clone_body_entered.bind(clone))

	var parent := get_parent()
	if parent:
		parent.add_child(clone)
	clone.global_position = global_position + Vector2(_rng.randf_range(-50, 50), _rng.randf_range(-50, 50))
	_clone_damage_cooldowns[clone] = 0.0
	return clone


func _spawn_extra_clones() -> void:
	var needed := max_clones - clones.size()
	if needed > 0:
		spawn_clones(needed)


func _update_position_history(delta: float) -> void:
	_clone_history_timer += delta
	if _clone_history_timer >= CLONE_DELAY:
		_clone_history_timer = 0.0
		_position_history.append(global_position)
		if _position_history.size() > MAX_HISTORY:
			_position_history.pop_front()


func _update_clone_positions(delta: float) -> void:
	for clone in clones:
		if not is_instance_valid(clone):
			continue
		var target_pos := global_position
		if _position_history.size() > 0:
			target_pos = _position_history[0]
		clone.global_position = clone.global_position.lerp(target_pos, 5.0 * delta)

		# Phase 2: clone deals damage on proximity
		if current_phase == BossPhase.SHATTERED:
			_try_clone_damage(clone)


func _update_clone_damage_cooldowns(delta: float) -> void:
	var to_remove: Array = []
	for clone in _clone_damage_cooldowns:
		if not is_instance_valid(clone):
			to_remove.append(clone)
			continue
		_clone_damage_cooldowns[clone] = _clone_damage_cooldowns[clone] - delta
	for clone in to_remove:
		_clone_damage_cooldowns.erase(clone)


func _try_clone_damage(clone: Node2D) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var cd: float = _clone_damage_cooldowns.get(clone, 0.0)
	if cd > 0.0:
		return
	var dist := clone.global_position.distance_to(_target.global_position)
	if dist < 30.0:
		if _target.has_method("take_damage"):
			_target.take_damage(5.0)
		_clone_damage_cooldowns[clone] = 1.5  # cooldown before next damage


func _on_clone_body_entered(body: Node2D, clone: Node2D) -> void:
	if body.is_in_group("player"):
		_shatter_clone(clone)


func _shatter_clone(clone: Node2D) -> void:
	clones.erase(clone)
	_clone_damage_cooldowns.erase(clone)
	if not is_instance_valid(clone):
		return
	var visual_node: Node = clone.get_child(0) if clone.get_child_count() > 0 else null
	if visual_node is CanvasItem:
		var tween := get_tree().create_tween()
		tween.tween_property(visual_node, "modulate:a", 0.0, 0.3)
		tween.tween_callback(clone.queue_free)
	else:
		clone.queue_free()


func _clear_all_clones() -> void:
	for clone in clones:
		if is_instance_valid(clone):
			_shatter_clone(clone)
	clones.clear()
	_clone_damage_cooldowns.clear()


# ═══════════════════════════════════════════════════════════════
# MIRROR SYSTEM
# ═══════════════════════════════════════════════════════════════

func _create_arena_mirrors() -> void:
	# 6 large mirrors on walls (relative to arena center = boss spawn)
	var large_offsets := [
		Vector2(-200.0, -80.0),
		Vector2(-200.0, 80.0),
		Vector2(200.0, -80.0),
		Vector2(200.0, 80.0),
		Vector2(-80.0, -160.0),
		Vector2(80.0, -160.0),
	]
	for offset in large_offsets:
		var mirror := _create_mirror_object(false)
		mirror.global_position = _arena_center + offset
		get_parent().add_child(mirror)
		mirror.mirror_broken.connect(_on_mirror_broken)
		_mirrors.append(mirror)

	# 4 small vanity mirrors (scattered, don't affect clone count)
	var small_offsets := [
		Vector2(-60.0, 60.0),
		Vector2(60.0, 60.0),
		Vector2(-120.0, 0.0),
		Vector2(120.0, 0.0),
	]
	for offset in small_offsets:
		var mirror := _create_mirror_object(true)
		mirror.global_position = _arena_center + offset
		get_parent().add_child(mirror)
		# Small mirrors don't connect to _on_mirror_broken (no clone reduction)


func _create_mirror_object(is_small: bool) -> StaticBody2D:
	var mirror := StaticBody2D.new()
	mirror.add_to_group("mirrors")
	mirror.set_script(load("res://scripts/world/breakable_mirror.gd"))
	mirror.set_meta("is_small", is_small)

	var size := Vector2(8.0, 48.0) if not is_small else Vector2(6.0, 32.0)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	mirror.add_child(col)

	var visual := ColorRect.new()
	visual.size = size
	visual.position = -size / 2.0
	visual.color = Color(0.753, 0.753, 0.753, 0.8)  # #C0C0C0 silver
	mirror.add_child(visual)

	# Crack overlay (black, starts transparent)
	var crack := ColorRect.new()
	crack.size = size
	crack.position = -size / 2.0
	crack.color = Color(0.0, 0.0, 0.0, 0.0)
	crack.name = "CrackOverlay"
	mirror.add_child(crack)

	return mirror


func _find_existing_mirrors() -> void:
	# Also find any pre-placed mirrors in the room
	var mirror_nodes := get_tree().get_nodes_in_group("mirrors")
	for m in mirror_nodes:
		if is_instance_valid(m) and not _mirrors.has(m):
			if m.has_signal("mirror_broken"):
				m.mirror_broken.connect(_on_mirror_broken)
			_mirrors.append(m)


func _on_mirror_broken(mirror: StaticBody2D) -> void:
	_mirrors.erase(mirror)
	if not mirror.get_meta("is_small", false):
		# Large mirror broken → reduce max clones
		max_clones = maxi(0, max_clones - 1)
		while clones.size() > max_clones:
			var clone = clones.pop_back()
			if is_instance_valid(clone):
				_shatter_clone(clone)


func _break_all_mirrors() -> void:
	for mirror in _mirrors:
		if is_instance_valid(mirror) and not mirror.is_broken:
			mirror.take_damage(999.0)  # Force break
	_mirrors.clear()


# ═══════════════════════════════════════════════════════════════
# TELEPORT  (Phase 2 — instant position swap to intact mirror)
# ═══════════════════════════════════════════════════════════════

func _try_teleport() -> void:
	if _teleport_cooldown > 0.0:
		return
	var intact_mirrors := _mirrors.filter(
		func(m): return is_instance_valid(m) and not m.is_broken and not m.get_meta("is_small", false)
	)
	if intact_mirrors.is_empty():
		return
	var target = intact_mirrors[_rng.randi() % intact_mirrors.size()]
	# Instant position change near mirror
	global_position = target.global_position + Vector2(20.0, 0.0)
	_teleport_cooldown = TELEPORT_COOLDOWN_BASE


# ═══════════════════════════════════════════════════════════════
# ATTACKS — PHASE 1: REFLECTION  (100% – 50% HP)
# ═══════════════════════════════════════════════════════════════

func kiss() -> void:
	# Stun attack — dash to player, stun 1.5s
	if _target and is_instance_valid(_target):
		EventBus.player_captured.emit()
		# Brief dash toward player
		velocity = _direction * 200.0
		move_and_slide()
	_finish_attack()


func dagger_swipe() -> void:
	# 15 dmg melee arc 60°
	_create_melee_hitbox(45.0, 60.0, 15.0, 15.0)


# ═══════════════════════════════════════════════════════════════
# ATTACKS — PHASE 2: SHATTERED  (50% – 25% HP)
# ═══════════════════════════════════════════════════════════════

func mirror_shard_throw() -> void:
	# 20 dmg piercing projectile, leaves shard hazard on ground
	var proj := CharacterBody2D.new()
	proj.collision_layer = 4
	proj.collision_mask = 1 | 16

	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	proj.add_child(col)

	# Visual
	var vis := ColorRect.new()
	vis.size = Vector2(8.0, 8.0)
	vis.position = -vis.size / 2.0
	vis.color = Color(0.753, 0.753, 0.753, 1.0)  # silver shard
	proj.add_child(vis)

	var dir := _direction
	proj.global_position = global_position + dir * 25.0
	proj.rotation = dir.angle()
	get_tree().current_scene.add_child(proj)

	# Track projectile
	var data := {
		"node": proj,
		"dir": dir,
		"speed": 280.0,
		"damage": 20.0,
		"elapsed": 0.0,
		"max_time": 2.5,
		"piercing": true,
		"hit_players": [],
	}
	# Process manually via timer-based movement
	_process_shard_projectile(data)
	_finish_attack()


func _process_shard_projectile(data: Dictionary) -> void:
	var node: CharacterBody2D = data["node"]
	if not is_instance_valid(node):
		return
	var dir: Vector2 = data["dir"]
	var speed: float = data["speed"]

	# Use a timer-based approach for movement
	var timer := get_tree().create_timer(0.016)  # ~60fps
	var total_time := 0.0
	var max_time: float = data["max_time"]
	var damage: float = data["damage"]
	var has_hit := false

	# Repeated movement via SceneTreeTimer chain
	_continue_shard(node, dir, speed, damage, total_time, max_time)


func _continue_shard(node: CharacterBody2D, dir: Vector2, speed: float,
		damage: float, elapsed: float, max_time: float) -> void:
	if not is_instance_valid(node):
		return
	var delta := 0.016
	var collision := node.move_and_collide(dir * speed * delta)
	if collision:
		var collider := collision.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(damage, dir, 10.0)
		# Piercing: don't stop, but leave shard hazard
		_create_shard_hazard(node.global_position)
		node.queue_free()
		return
	elapsed += delta
	if elapsed >= max_time:
		_create_shard_hazard(node.global_position)
		node.queue_free()
		return
	get_tree().create_timer(delta).timeout.connect(
		_continue_shard.bind(node, dir, speed, damage, elapsed, max_time)
	)


func _create_shard_hazard(pos: Vector2) -> void:
	var zone := Area2D.new()
	zone.collision_layer = 0
	zone.collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12.0
	col.shape = shape
	zone.add_child(col)
	zone.global_position = pos

	var vis := ColorRect.new()
	vis.size = Vector2(10.0, 10.0)
	vis.position = -vis.size / 2.0
	vis.color = Color(0.753, 0.753, 0.753, 0.5)
	zone.add_child(vis)

	get_tree().current_scene.add_child(zone)

	zone.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(5.0)
	)
	get_tree().create_timer(5.0).timeout.connect(zone.queue_free)


# ═══════════════════════════════════════════════════════════════
# ATTACKS — PHASE 3: TRUE FACE  (25% – 0% HP)
# ═══════════════════════════════════════════════════════════════

func dash_attack() -> void:
	# 35 dmg fast lunge toward player
	velocity = _direction * 400.0
	var collision := move_and_collide(_direction * 400.0 * 0.016)
	if collision:
		var collider := collision.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(35.0, _direction, 30.0)
	# Also create hitbox along path
	_create_melee_hitbox(50.0, 90.0, 35.0, 30.0)


func scream() -> void:
	# AoE stun 1.0s in radius 80px
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 80.0
	col.shape = shape
	area.add_child(col)
	area.global_position = global_position
	get_tree().current_scene.add_child(area)

	area.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player"):
			if body.has_method("apply_stun"):
				body.apply_stun(1.0)
			elif body.has_method("take_damage"):
				body.take_damage(5.0)  # reduced damage if no stun method
	)

	# Visual pulse
	var pulse := ColorRect.new()
	pulse.size = Vector2(160.0, 160.0)
	pulse.position = -pulse.size / 2.0
	pulse.color = Color(1.0, 0.102, 0.427, 0.3)  # hot pink flash
	area.add_child(pulse)

	get_tree().create_timer(0.3).timeout.connect(area.queue_free)
	_finish_attack()


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


func _summon_bodyguard() -> void:
	_bodyguard_summoned = true
	var path := "res://scenes/enemies/bodyguard.tscn"
	var scene := load(path) as PackedScene
	if scene == null:
		return
	var bodyguard := scene.instantiate()
	var offset := Vector2(-120.0, -80.0)
	bodyguard.global_position = _arena_center + offset
	get_parent().add_child(bodyguard)


# ═══════════════════════════════════════════════════════════════
# MUTILATION SYSTEM  (14_BOSS_DESIGN.md §3.5)
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
	_select_phase_patterns()


func _apply_mutilation_effects() -> void:
	# Arm lost → fewer clones
	if severed_limbs[DamageZone.Zone.LEFT_ARM] or severed_limbs[DamageZone.Zone.RIGHT_ARM]:
		max_clones = maxi(0, max_clones - 1)
		while clones.size() > max_clones:
			var clone = clones.pop_back()
			if is_instance_valid(clone):
				_shatter_clone(clone)

	# Both arms → Phase 3 (handled in check_phase_transition)

	# Leg lost → teleport cooldown doubled
	if severed_limbs[DamageZone.Zone.LEFT_LEG] or severed_limbs[DamageZone.Zone.RIGHT_LEG]:
		_teleport_cooldown = TELEPORT_COOLDOWN_BASE * 2.0


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
	is_telegraphing = false
	executing_attack = false
	_clear_all_clones()
