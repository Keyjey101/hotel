extends "res://scripts/ai/base_enemy.gd"

## Taster enemy — Floor 3 Gluttony. Poison-themed attacker.
## Design doc: 11_ENEMY_DESIGN.md section 3.2

# Poison Blood (retaliation)
var _last_attacker_pos: Vector2 = Vector2.ZERO

# Embrace (poison grab)
var _grab_active: bool = false
var _grab_duration: float = 4.0
var _grab_timer: float = 0.0
var _embrace_base_dps: float = 8.0
var _embrace_poison_dps: float = 16.0
var _grab_dps_accumulator: float = 0.0
const GRAB_DPS_INTERVAL: float = 0.25

const HAZARD_SCENE := preload("res://scenes/combat/hazard_zone.tscn")


func _ready() -> void:
	enemy_name = "Taster"
	enemy_type = "taster"

	torso_hp = 45.0
	head_hp = 12.0
	arm_hp = 10.0
	leg_hp = 10.0
	move_speed = 150.0
	detection_range = 220.0
	attack_range = 35.0
	attack_damage = 8.0
	attack_speed = 0.8
	grab_strength = 3.0
	regen_speed_mult = 1.4
	aggression = 7.0
	coordination = 3.0

	super._ready()

	# Green tint overlay
	_create_green_tint()


# ---------------------------------------------------------------------------
# Visual: green poison tint overlay
# ---------------------------------------------------------------------------

func _create_green_tint() -> void:
	var tint := ColorRect.new()
	tint.name = "PoisonTint"
	tint.color = Color(0.0, 1.0, 0.0, 0.15)
	# Match sprite bounds from the PlaceholderSprite
	tint.offset_left = -11.0
	tint.offset_top = -18.0
	tint.offset_right = 11.0
	tint.offset_bottom = 18.0
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.add_child(tint)


# ---------------------------------------------------------------------------
# Poison Blood — retaliatory poison splash on melee hits
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	# Store attacker position before super processes the hit
	_last_attacker_pos = _get_attacker_position()

	# Let base class handle the damage
	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)

	# If still alive (not disabled by the hit), check for poison retaliation
	if _disabled:
		return

	# Poison Blood: melee attacks within 60px trigger poison splash
	var dist_to_attacker: float = global_position.distance_to(_last_attacker_pos)
	if dist_to_attacker <= 60.0:
		_spawn_poison_splash()


func _get_attacker_position() -> Vector2:
	# Try to find the player (most likely attacker) as a simplified approach
	if _target != null and is_instance_valid(_target):
		return _target.global_position
	# Fallback: check player group
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0].global_position
	return global_position + Vector2.UP * 100.0  # far away = no splash


func _spawn_poison_splash() -> void:
	# Poison cloud at Taster's position
	_spawn_poison_cloud(global_position, 3.0, 30.0, 5.0)

	# Green particle splash visual
	_spawn_poison_particles(global_position)


func _spawn_poison_particles(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	for i in range(6):
		var particle := ColorRect.new()
		particle.size = Vector2(3.0, 3.0)
		particle.color = Color(0.0, 1.0, 0.0, 0.8)
		particle.position = pos - particle.size * 0.5
		particle.z_index = 10
		parent.add_child(particle)

		# Scatter outward
		var spread_dir := Vector2(randf() - 0.5, randf() - 0.5).normalized()
		var spread_dist := randf_range(12.0, 28.0)
		var tween := particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", pos + spread_dir * spread_dist - particle.size * 0.5, 0.4)
		tween.tween_property(particle, "color", Color(0.0, 1.0, 0.0, 0.0), 0.5)
		tween.chain().tween_callback(particle.queue_free)


# ---------------------------------------------------------------------------
# Embrace — poison grab (engage behavior)
# ---------------------------------------------------------------------------

func _state_engage(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_release_grab()
		_enter_state("patrol")
		return

	# While grab is active, deal damage over time
	if _grab_active:
		_grab_timer -= delta
		var dps := _embrace_base_dps
		if _is_target_poisoned():
			dps = _embrace_poison_dps
		_grab_dps_accumulator += delta
		if _grab_dps_accumulator >= GRAB_DPS_INTERVAL:
			var tick_damage := dps * _grab_dps_accumulator
			_grab_dps_accumulator = 0.0
			if _target.has_method("receive_damage"):
				_target.receive_damage(tick_damage, DamageZone.Zone.TORSO, false)

		# Auto-release after duration
		if _grab_timer <= 0.0:
			_release_grab()
		return

	# Move toward player for grab attempt
	var dist := global_position.distance_to(_target.global_position)
	_direction = global_position.direction_to(_target.global_position)

	if dist > attack_range:
		# Close the gap
		velocity = _direction * move_speed
	else:
		# In range — attempt grab
		velocity = Vector2.ZERO
		_attempt_embrace_grab()

	# Re-check range after movement
	if _target and is_instance_valid(_target):
		if global_position.distance_to(_target.global_position) > attack_range * 2.5:
			_enter_state("chase")


func _attempt_embrace_grab() -> void:
	if _grab_active:
		return
	if _target == null or not is_instance_valid(_target):
		return
	# Roll against grab_strength
	var roll := randf() * 10.0
	if roll <= grab_strength:
		_grab_active = true
		_grab_timer = _grab_duration
		EventBus.player_captured.emit()
		# Stun/slow handled by player script listening to player_captured


func _release_grab() -> void:
	_grab_active = false
	_grab_timer = 0.0
	_grab_dps_accumulator = 0.0


func _is_target_poisoned() -> bool:
	# Simplified: check if a HazardZone owned by this Taster is overlapping the player
	# Check if any active poison zone overlaps the target
	if _target == null or not is_instance_valid(_target):
		return false
	var zones := get_tree().get_nodes_in_group("hazard_zone")
	for zone in zones:
		if zone is Area2D:
			var overlapping: Array = zone.get_overlapping_bodies()
			if _target in overlapping:
				return true
	return false


# ---------------------------------------------------------------------------
# Corpse Burst — death explosion (poison cloud on disable)
# ---------------------------------------------------------------------------

func _disable_enemy() -> void:
	# Spawn big poison cloud BEFORE calling super (which sets _disabled)
	_spawn_poison_cloud(global_position, 5.0, 60.0, 5.0)

	# Death burst visual
	_spawn_death_burst_visual()

	# Release grab if active
	_release_grab()

	super._disable_enemy()


func _spawn_death_burst_visual() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var circle := ColorRect.new()
	circle.name = "DeathBurst"
	circle.color = Color(0.0, 1.0, 0.0, 0.4)
	circle.z_index = 5
	circle.size = Vector2(8.0, 8.0)
	circle.position = global_position - circle.size * 0.5
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(circle)

	var tween := circle.create_tween()
	tween.set_parallel(true)
	# Expand to 120x120 (radius 60 * 2)
	tween.tween_property(circle, "size", Vector2(120.0, 120.0), 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(circle, "position", global_position - Vector2(60.0, 60.0), 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(circle, "color", Color(0.0, 1.0, 0.0, 0.0), 1.0)
	tween.chain().tween_callback(circle.queue_free)


# ---------------------------------------------------------------------------
# Mutilated — severed limbs leave poison pools
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	# Small poison pool at limb position
	_spawn_poison_cloud(global_position, 2.0, 24.0, 10.0)

	# Blood effect (poison-colored)
	if is_instance_valid(GoreSystem):
		GoreSystem.spawn_blood_splash(global_position, _direction)

	# Check full dismemberment — big poison pool
	var all_severed := true
	for z in DamageZone.all_limbs():
		if not severed_limbs[z]:
			all_severed = false
			break
	if all_severed:
		_spawn_poison_cloud(global_position, 3.0, 48.0, 10.0)


# ---------------------------------------------------------------------------
# Helper: spawn a HazardZone poison cloud
# ---------------------------------------------------------------------------

func _spawn_poison_cloud(pos: Vector2, dps: float, radius: float, dur: float) -> void:
	var zone: Area2D = HAZARD_SCENE.instantiate()
	zone.damage_per_second = dps
	zone.slow_factor = 1.0
	zone.duration = dur
	zone.zone_color = Color(0.0, 1.0, 0.0)
	zone.zone_radius = radius
	zone.add_to_group("hazard_zone")
	var parent := get_parent()
	if parent:
		parent.call_deferred("add_child", zone)
		zone.set_deferred("global_position", pos)


# ---------------------------------------------------------------------------
# Override mutilated behavior — Taster is aggressive, never retreats
# ---------------------------------------------------------------------------

func _evaluate_mutilated_behavior() -> void:
	# Taster is highly aggressive (7.0) — keeps fighting no matter what
	pass


# ---------------------------------------------------------------------------
# Attack override
# ---------------------------------------------------------------------------

func _perform_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	if _target == null:
		return
	_attack_cooldown = 1.0 / attack_speed
	_deal_melee_damage_to_player()


func get_enemy_type() -> String:
	return enemy_type
