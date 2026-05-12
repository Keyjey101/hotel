extends "res://scripts/ai/base_enemy.gd"

## Boss — The Curator (Floor 7: Observatory/Envy).
## Weapon theft mechanic. 3 phases: Acquisition, Collection, Exhibition.
## Design doc: 14_BOSS_DESIGN.md section 8.

# Phase tracking
var _phase: int = 1
var _max_torso_hp: float = 250.0

# Weapon theft
var _stolen_weapon = null  # WeaponData reference
var _steal_cooldown: float = 0.0
var _steal_cooldown_max: float = 8.0
var _stealing: bool = false
var _steal_timer: float = 0.0

# Invisibility / phase
var _invisible: bool = false
var _invisible_timer: float = 0.0
var _phase_cooldown: float = 0.0
var _phase_cooldown_max: float = 5.0
var _is_phasing: bool = false
var _phase_timer: float = 0.0
var _original_collision_mask: int = 0

# Shadow bolt
var _bolt_cooldown: float = 0.0
var _bolt_cooldown_max: float = 2.5

# Summon
var _summon_cooldown: float = 0.0
var _summon_cooldown_max: float = 25.0
var _spy_scene: PackedScene = null

# Phase 2 display case (decorative)
var _display_weapons: Array[ColorRect] = []

# Phase 3 — shadow realm
var _shadow_realm_active: bool = false
var _shadow_realm_overlay: ColorRect = null
var _shadow_clone: CharacterBody2D = null
var _clone_scene: PackedScene = null

# Clone flag — set before add_child to skip full boss initialization
var is_clone: bool = false

# Mutilation
var _arms_lost: int = 0
var _legs_lost: int = 0

# Drop stolen weapon on damage chance
var _drop_weapon_on_hit_chance: float = 0.5


func _ready() -> void:
	if is_clone:
		return

	enemy_name = "The Curator"
	enemy_type = "boss"

	torso_hp = 250.0
	head_hp = 45.0
	arm_hp = 45.0
	leg_hp = 45.0
	move_speed = 130.0
	detection_range = 400.0
	attack_range = 50.0
	attack_damage = 15.0
	attack_speed = 0.7
	grab_strength = 5.0
	regen_speed_mult = 1.1
	aggression = 6.0
	coordination = 7.0

	_max_torso_hp = torso_hp
	_original_collision_mask = collision_mask

	add_to_group("boss")
	super._ready()

	# Pre-load summon scenes
	if ResourceLoader.exists("res://scenes/enemies/spy.tscn"):
		_spy_scene = load("res://scenes/enemies/spy.tscn")


# ---------------------------------------------------------------------------
# Physics
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if _disabled:
		_disabled_timer -= delta
		if _disabled_timer <= 0.0:
			_disabled = false
			_enter_state("chase")
		return

	if _stunned:
		_stun_timer -= delta
		if _stun_timer <= 0.0:
			_stunned = false
		velocity = _knockback_vel * 0.9
		_knockback_vel *= 0.9
		move_and_slide()
		_process_regen(delta)
		return

	# Tick cooldowns
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_steal_cooldown = maxf(0.0, _steal_cooldown - delta)
	_bolt_cooldown = maxf(0.0, _bolt_cooldown - delta)
	_summon_cooldown = maxf(0.0, _summon_cooldown - delta)
	_phase_cooldown = maxf(0.0, _phase_cooldown - delta)
	_state_timer -= delta

	# Steal animation lock
	if _stealing:
		_steal_timer -= delta
		if _steal_timer <= 0.0:
			_execute_steal()
		velocity = Vector2.ZERO
		move_and_slide()
		_process_regen(delta)
		return

	# Phase through walls movement
	if _is_phasing:
		_phase_timer -= delta
		if _target and is_instance_valid(_target):
			var dir := global_position.direction_to(_target.global_position)
			velocity = dir * move_speed * 1.3
			_direction = dir
		_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
		velocity += _knockback_vel
		move_and_slide()
		if _phase_timer <= 0.0:
			_end_phase()
		_process_regen(delta)
		return

	# Invisibility timer
	if _invisible:
		_invisible_timer -= delta
		if _invisible_timer <= 0.0:
			_decloak()

	# Update phase
	_update_phase()

	# Phase-specific behaviors
	_process_phase_behaviors(delta)

	_process_state(delta)
	_process_regen(delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	velocity += _knockback_vel

	move_and_slide()

	# Keep shadow realm overlay centered on boss
	if _shadow_realm_overlay and is_instance_valid(_shadow_realm_overlay):
		_shadow_realm_overlay.global_position = global_position - Vector2(100, 100)


# ---------------------------------------------------------------------------
# Phase management
# ---------------------------------------------------------------------------

func _update_phase() -> void:
	var hp_pct: float = float(limb_health[DamageZone.Zone.TORSO]) / _max_torso_hp
	var new_phase: int

	if hp_pct > 0.5:
		new_phase = 1
	elif hp_pct > 0.25:
		new_phase = 2
	else:
		new_phase = 3

	if new_phase != _phase:
		_phase = new_phase
		_on_phase_changed()


func _on_phase_changed() -> void:
	match _phase:
		2:
			_steal_cooldown_max = 5.0
			_create_display_case()
		3:
			_steal_cooldown_max = 4.0
			_create_shadow_realm()
			_create_shadow_clone()


func _process_phase_behaviors(delta: float) -> void:
	# Periodic invisibility (Phase 1+)
	if _phase >= 1 and not _invisible and not _is_phasing:
		if randf() < 0.003:  # ~every 6s at 60fps
			_go_invisible(3.0)

	# Summon Spy (Phase 1+)
	if _summon_cooldown <= 0.0 and _phase >= 1:
		_summon_spy()
		_summon_cooldown = _summon_cooldown_max

	# Shadow bolt (when at range and not invisible)
	if _bolt_cooldown <= 0.0 and not _invisible and _target and is_instance_valid(_target):
		var dist := global_position.distance_to(_target.global_position)
		if dist > attack_range * 1.5:
			_fire_shadow_bolt()
			_bolt_cooldown = _bolt_cooldown_max


# ---------------------------------------------------------------------------
# Invisibility
# ---------------------------------------------------------------------------

func _go_invisible(duration: float) -> void:
	_invisible = true
	_invisible_timer = duration
	sprite.modulate.a = 0.2


func _decloak() -> void:
	_invisible = false
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, 0.3)


# ---------------------------------------------------------------------------
# Phase through walls
# ---------------------------------------------------------------------------

func _try_phase() -> void:
	if _is_phasing or _phase_cooldown > 0.0:
		return
	if _target == null or not is_instance_valid(_target):
		return

	_is_phasing = true
	_phase_timer = 1.0
	# Remove environment collision layer
	collision_mask = _original_collision_mask & ~(1 << 6)  # Remove bit 7 (layer 7)
	sprite.modulate = Color(0.5, 0.3, 0.7, 0.5)
	_phase_cooldown = _phase_cooldown_max


func _end_phase() -> void:
	_is_phasing = false
	collision_mask = _original_collision_mask
	sprite.modulate = Color.WHITE


# ---------------------------------------------------------------------------
# Weapon theft
# ---------------------------------------------------------------------------

func _attempt_steal() -> void:
	if _steal_cooldown > 0.0 or _stealing:
		return
	if _arms_lost >= 2:
		return
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > 40.0:
		return

	_stealing = true
	_steal_timer = 0.8  # Grab animation duration


func _execute_steal() -> void:
	_stealing = false

	if _target == null or not is_instance_valid(_target):
		return

	# Access player's weapon manager
	var wm = _target.get("weapon_manager")
	if wm == null:
		return

	var equipped = wm.get("equipped")
	if equipped == null:
		return

	var active_slot: int = wm.get("active_slot", 0)

	if _phase >= 3:
		_steal_both(wm, equipped)
	else:
		_steal_single(wm, equipped, active_slot)


func _steal_single(wm, equipped, slot: int) -> void:
	var weapon = equipped[slot]
	if weapon == null:
		# Try other slot
		var other := 0 if slot == 1 else 1
		weapon = equipped[other]
		if weapon == null:
			return
		slot = other

	_stolen_weapon = weapon
	equipped[slot] = null
	wm.set("_ammo", [wm.get("_ammo")[0], wm.get("_ammo")[1]])  # Trigger update
	EventBus.weapon_dropped.emit(_stolen_weapon)
	_steal_cooldown = _steal_cooldown_max


func _steal_both(wm, equipped) -> void:
	# Try to steal BOTH weapons
	var first_weapon = null
	var second_weapon = null
	for i in range(equipped.size()):
		if equipped[i] != null:
			if first_weapon == null:
				first_weapon = equipped[i]
			else:
				second_weapon = equipped[i]
			equipped[i] = null
	_stolen_weapon = first_weapon
	EventBus.weapon_dropped.emit(_stolen_weapon)
	if second_weapon != null:
		EventBus.weapon_dropped.emit(second_weapon)
	_steal_cooldown = _steal_cooldown_max


func _use_stolen_weapon() -> void:
	if _stolen_weapon == null or _target == null or not is_instance_valid(_target):
		return

	var damage: float = _stolen_weapon.get("damage") if _stolen_weapon.get("damage") != null else 15.0
	if _phase >= 2:
		damage *= 1.3  # +30% bonus in Phase 2

	var dir := global_position.direction_to(_target.global_position)

	if _target.has_method("receive_damage"):
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 30.0, dir * -1.0)


func _drop_stolen_weapon() -> void:
	if _stolen_weapon == null:
		return
	# Emit weapon_dropped so player can pick it up
	EventBus.weapon_dropped.emit(_stolen_weapon)
	_stolen_weapon = null


# ---------------------------------------------------------------------------
# Shadow bolt (ranged projectile)
# ---------------------------------------------------------------------------

func _fire_shadow_bolt() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dir := global_position.direction_to(_target.global_position)
	var bolt := Area2D.new()
	bolt.name = "ShadowBolt"
	bolt.position = Vector2.ZERO
	bolt.add_to_group("enemy_hitbox")

	var shape := CircleShape2D.new()
	shape.radius = 6.0
	var col := CollisionShape2D.new()
	col.shape = shape
	bolt.add_child(col)

	var visual := ColorRect.new()
	visual.size = Vector2(8, 8)
	visual.position = Vector2(-4, -4)
	visual.color = Color(0.4, 0.1, 0.6, 0.9)
	bolt.add_child(visual)

	# Store direction and speed
	bolt.set_meta("direction", dir)
	bolt.set_meta("speed", 300.0)
	bolt.set_meta("damage", 20.0)
	bolt.set_meta("source", self)

	get_tree().current_scene.add_child(bolt)
	bolt.global_position = global_position

	# Move the bolt via scene tree timer
	_move_projectile(bolt)


func _move_projectile(bolt: Area2D) -> void:
	var speed: float = bolt.get_meta("speed", 300.0)
	var dir: Vector2 = bolt.get_meta("direction", Vector2.RIGHT)
	var damage: float = bolt.get_meta("damage", 20.0)
	var source = bolt.get_meta("source")

	var lifetime := 3.0
	var elapsed := 0.0

	while is_instance_valid(bolt) and is_instance_valid(self) and elapsed < lifetime:
		await get_tree().process_frame
		if not is_instance_valid(self): return
		if not is_instance_valid(source):
			if is_instance_valid(bolt):
				bolt.queue_free()
			return
		elapsed += get_process_delta_time()
		bolt.global_position += dir * speed * get_process_delta_time()

		# Check if hit player
		var bodies := bolt.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player") and body.has_method("receive_damage"):
				body.receive_damage(damage, DamageZone.Zone.TORSO, false)
				if is_instance_valid(bolt):
					bolt.queue_free()
				return

	if is_instance_valid(bolt):
		bolt.queue_free()


# ---------------------------------------------------------------------------
# Summon Spy
# ---------------------------------------------------------------------------

func _summon_spy() -> void:
	if _spy_scene == null:
		return

	var spy := _spy_scene.instantiate() as CharacterBody2D
	if spy == null:
		return

	spy.global_position = global_position + Vector2(randf_range(-80, 80), randf_range(-80, 80))
	get_tree().current_scene.add_child(spy)


# ---------------------------------------------------------------------------
# Phase 2 — Display Case (decorative)
# ---------------------------------------------------------------------------

func _create_display_case() -> void:
	# 4 decorative "stolen weapons" on walls — flavor only
	var colors := [
		Color(0.8, 0.8, 0.8, 0.6),
		Color(0.6, 0.6, 0.8, 0.6),
		Color(0.8, 0.6, 0.6, 0.6),
		Color(0.6, 0.8, 0.6, 0.6),
	]
	var room := _find_room_instance()
	if room == null:
		return
	var size := room.room_bounds.size

	for i in range(4):
		var weapon_vis := ColorRect.new()
		weapon_vis.name = "DisplayWeapon%d" % i
		weapon_vis.size = Vector2(12, 4)
		weapon_vis.color = colors[i]
		match i:
			0: weapon_vis.position = Vector2(size.x * 0.25, 20.0)
			1: weapon_vis.position = Vector2(size.x * 0.75, 20.0)
			2: weapon_vis.position = Vector2(20.0, size.y * 0.5)
			3: weapon_vis.position = Vector2(size.x - 32.0, size.y * 0.5)
		room.add_child(weapon_vis)
		_display_weapons.append(weapon_vis)


# ---------------------------------------------------------------------------
# Phase 3 — Shadow Realm
# ---------------------------------------------------------------------------

func _create_shadow_realm() -> void:
	if _shadow_realm_active:
		return
	_shadow_realm_active = true

	# Dark overlay around Curator (100px radius)
	_shadow_realm_overlay = ColorRect.new()
	_shadow_realm_overlay.name = "ShadowRealm"
	_shadow_realm_overlay.color = Color(0, 0, 0, 0.7)
	_shadow_realm_overlay.size = Vector2(200, 200)
	_shadow_realm_overlay.z_index = 10
	_shadow_realm_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().current_scene.add_child(_shadow_realm_overlay)
	_shadow_realm_overlay.global_position = global_position - Vector2(100, 100)


func _create_shadow_clone() -> void:
	# Clone = same scene with reduced stats
	if not ResourceLoader.exists("res://scenes/bosses/boss_curator.tscn"):
		return
	var scene := load("res://scenes/bosses/boss_curator.tscn")
	if scene == null:
		return

	_clone_scene = scene
	_shadow_clone = scene.instantiate() as CharacterBody2D
	if _shadow_clone == null:
		return

	# Mark as clone BEFORE add_child so _ready can skip boss initialization
	_shadow_clone.is_clone = true
	# Reduce clone stats
	_shadow_clone.set("torso_hp", 80.0)
	_shadow_clone.set("attack_damage", 5.0)  # 25% of Curator's
	_shadow_clone.set("move_speed", 100.0)
	_shadow_clone.modulate.a = 0.5
	_shadow_clone.global_position = global_position + Vector2(60, 0)
	# Set clone to chase state with player target
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_shadow_clone.set("_target", players[0])
	get_tree().current_scene.add_child(_shadow_clone)
	_shadow_clone.call("_enter_state", "chase")


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	# Phase through walls if path is blocked
	if _phase >= 2 and _phase_cooldown <= 0.0 and dist > 100.0:
		_try_phase()

	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * move_speed
	_direction = dir

	# Attempt weapon steal when close
	if dist <= 40.0 and _steal_cooldown <= 0.0 and not _stealing:
		_attempt_steal()
		_enter_state("engage")
		return

	if dist <= attack_range:
		_enter_state("engage")


func _state_engage(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	# Use stolen weapon if available
	if _stolen_weapon != null and _attack_cooldown <= 0.0:
		_use_stolen_weapon()
		_attack_cooldown = attack_speed * 1.5
	elif _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	# Attempt steal
	if _steal_cooldown <= 0.0 and not _stealing:
		var dist := global_position.distance_to(_target.global_position)
		if dist <= 40.0:
			_attempt_steal()

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.5:
		_enter_state("chase")


func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var damage := attack_damage
	if _phase >= 3:
		damage = 30.0  # Desperate melee

	if _target.has_method("receive_damage"):
		var dir := global_position.direction_to(_target.global_position)
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 25.0, dir * -1.0)


# ---------------------------------------------------------------------------
# Damage override — drop stolen weapon on hit
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	# Reveal if invisible
	if _invisible:
		_decloak()

	# 50% chance to drop stolen weapon
	if _stolen_weapon != null and randf() < _drop_weapon_on_hit_chance:
		_drop_stolen_weapon()

	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


# ---------------------------------------------------------------------------
# Death
# ---------------------------------------------------------------------------

func _disable_enemy() -> void:
	# Drop stolen weapon on death
	if _stolen_weapon != null:
		_drop_stolen_weapon()

	# Clean up shadow realm overlay
	if _shadow_realm_overlay and is_instance_valid(_shadow_realm_overlay):
		_shadow_realm_overlay.queue_free()
		_shadow_realm_overlay = null

	# Clean up shadow clone
	if _shadow_clone and is_instance_valid(_shadow_clone):
		_shadow_clone.queue_free()
		_shadow_clone = null

	# Clean up display weapons
	for dw in _display_weapons:
		if is_instance_valid(dw):
			dw.queue_free()
	_display_weapons.clear()

	EventBus.mini_boss_defeated.emit(7)
	super._disable_enemy()


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
		if _arms_lost >= 2:
			# No steal, switch to shadow bolt spam
			_steal_cooldown_max = 999999.0
			_bolt_cooldown_max = 1.0

	if DamageZone.is_leg(zone):
		_legs_lost = int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + \
			int(severed_limbs[DamageZone.Zone.RIGHT_LEG])
		if _legs_lost >= 1:
			_phase_cooldown_max = 2.0

	# Full mutilate: dissolve
	if _arms_lost >= 2 and _legs_lost >= 2:
		# Slow dissolve
		var tween := create_tween()
		tween.tween_property(sprite, "modulate:a", 0.3, 2.0)


func _evaluate_mutilated_behavior() -> void:
	# Curator stays aggressive — no retreat
	if _current_state in ["patrol", "retreat"]:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

func _find_room_instance() -> RoomInstance:
	var node := get_parent()
	while node != null:
		if node is RoomInstance:
			return node
		node = node.get_parent()
	return null


func get_attack_damage() -> float:
	if _stolen_weapon != null:
		var dmg = _stolen_weapon.get("damage")
		if dmg != null:
			var result: float = float(dmg)
			if _phase >= 2:
				result *= 1.3
			return result
	if _phase >= 3:
		return 30.0
	return attack_damage
