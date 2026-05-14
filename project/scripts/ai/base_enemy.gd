extends CharacterBody2D

## BaseEnemy — Base class for all enemies.
## Handles HP, per-limb damage, regeneration, state machine, and AI.

# Node references (set in scene)
@onready var sprite: Sprite2D = %Sprite
@onready var navigation: NavigationAgent2D = %NavigationAgent
@onready var hitbox: Area2D = %Hitbox
@onready var hurtbox_manager: Node2D = %HurtboxManager
@onready var detection_area: Area2D = %DetectionArea
@onready var anim_player: AnimationPlayer = %AnimPlayer

# Enemy identity
@export var enemy_name: String = "Enemy"
@export var enemy_type: String = "base"

# Base stats (overridden by subtypes)
@export_group("Base Stats")
@export var torso_hp: float = 70.0
@export var head_hp: float = 25.0
@export var arm_hp: float = 20.0
@export var leg_hp: float = 22.0
@export var move_speed: float = 120.0
@export var detection_range: float = 250.0
@export var attack_range: float = 45.0
@export var attack_damage: float = 15.0
@export var attack_speed: float = 0.8
@export var grab_strength: float = 3.0
@export var regen_speed_mult: float = 1.0
@export var aggression: float = 5.0
@export var coordination: float = 5.0

# Runtime state
var limb_health: Dictionary = {}
var severed_limbs: Dictionary = {}   # zone -> bool
var regen_timers: Dictionary = {}    # zone -> {current, max, paused}
var base_regen_time: float = 30.0

var _current_state: String = "patrol"
var _state_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _target: Node2D = null
var _stunned: bool = false
var _stun_timer: float = 0.0
var _disabled: bool = false
var _disabled_timer: float = 0.0
var _alerted: bool = false
var _patrol_points: Array[Vector2] = []
var _patrol_index: int = 0
var _direction: Vector2 = Vector2.DOWN
var _knockback_vel: Vector2 = Vector2.ZERO
var _initial_move_speed: float = 0.0
var _alert_sfx_played: bool = false
var _regen_sfx_played: bool = false
var _detection_lost_timer: SceneTreeTimer = null
var _detection_lost_callback: Callable
var _hurt_tween: Tween = null


func _ready() -> void:
	_initial_move_speed = move_speed
	_load_sprite()
	_init_health()
	_connect_signals()
	_enter_state("patrol")



func _load_sprite() -> void:
	if enemy_type == "" or enemy_type == "base":
		return
	var asset_name := ""
	if enemy_type == "boss":
		# Bosses use enemy_name for sprite lookup
		var name_key := enemy_name.to_lower().replace(" ", "_")
		if name_key.begins_with("the_"):
			name_key = name_key.substr(4)
		asset_name = "enemy_%s.png" % name_key
	else:
		asset_name = "enemy_%s.png" % enemy_type.to_lower()
	var asset_path := "res://assets/sprites/characters/enemies/" + asset_name
	if ResourceLoader.exists(asset_path):
		sprite.texture = load(asset_path)
		sprite.region_enabled = false

func _init_health() -> void:
	limb_health = {
		DamageZone.Zone.HEAD: head_hp,
		DamageZone.Zone.LEFT_ARM: arm_hp,
		DamageZone.Zone.RIGHT_ARM: arm_hp,
		DamageZone.Zone.LEFT_LEG: leg_hp,
		DamageZone.Zone.RIGHT_LEG: leg_hp,
		DamageZone.Zone.TORSO: torso_hp,
	}
	severed_limbs = {
		DamageZone.Zone.HEAD: false,
		DamageZone.Zone.LEFT_ARM: false,
		DamageZone.Zone.RIGHT_ARM: false,
		DamageZone.Zone.LEFT_LEG: false,
		DamageZone.Zone.RIGHT_LEG: false,
	}
	# Regen timers per limb
	for zone in DamageZone.all_limbs():
		regen_timers[zone] = {"current": 0.0, "max": base_regen_time / regen_speed_mult, "paused": false}


func _connect_signals() -> void:
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)


# ============================================================
# Physics / Update
# ============================================================

func _physics_process(delta: float) -> void:
	if _disabled:
		_disabled_timer -= delta
		_process_regen(delta)
		if _disabled_timer <= 0.0:
			_disabled = false
			_enter_state("patrol")
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

	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_state_timer -= delta

	# State logic
	_process_state(delta)
	_process_regen(delta)

	# Apply knockback decay
	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	velocity += _knockback_vel

	move_and_slide()


# ============================================================
# Damage System
# ============================================================

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if _disabled:
		return

	# Apply damage to zone (fallback to TORSO for unknown zones)
	if not limb_health.has(zone):
		zone = DamageZone.Zone.TORSO
	limb_health[zone] -= damage

	# Pause regen on this zone
	_pause_regen(zone, 2.0)

	# Check if limb should sever
	if DamageZone.is_limb(zone) and limb_health[zone] <= 0.0 and not severed_limbs[zone]:
		_sever_limb(zone)
	elif limb_health[zone] < 0.0:
		limb_health[zone] = 0.0

	# Check torso death
	if zone == DamageZone.Zone.TORSO and limb_health[DamageZone.Zone.TORSO] <= 0.0:
		_disable_enemy()
		return

	# Knockback
	if knockback_force > 0.0:
		_knockback_vel = knockback_dir * knockback_force * 5.0

	# Stun check
	if zone == DamageZone.Zone.HEAD:
		apply_stun(0.5)

	# Visual feedback
	_flash_hurt()

	AudioManager.SFXPlayer.play_sfx_with_pitch("enemy_hurt", randf_range(0.8, 1.2))

	# Blood splash on every hit
	GoreSystem.spawn_blood_splash(global_position, knockback_dir)

	# Hit stop on significant limb damage
	if DamageZone.is_limb(zone) and damage > 15.0:
		ScreenEffects.hit_stop(0.05)

	# Alert on damage
	if not _alerted:
		_alert_nearby()

	EventBus.enemy_damaged.emit(self, zone, damage)

	# State transition — only alert if still alive and in patrol
	if not _disabled and _current_state == "patrol":
		_enter_state("alert")


func _sever_limb(zone: int) -> void:
	severed_limbs[zone] = true
	limb_health[zone] = 0.0

	# Spawn severed limb entity
	GoreSystem.spawn_severed_limb(global_position, zone, self)

	# Start extended regen timer for the severed limb
	var next_regen_time := (base_regen_time / regen_speed_mult) * 3.0
	regen_timers[zone] = {"current": 0.0, "max": next_regen_time, "paused": false}

	# Adjust behavior based on lost limb
	_on_limb_lost(zone)

	# Enhanced screen effects on sever
	ScreenEffects.shake(6.0, 0.2)
	ScreenEffects.flash(Color(1.0, 0.0, 0.0), 0.1, 0.5)
	ScreenEffects.zoom(1.15, 0.05, 0.03, 0.15)

	EventBus.enemy_limb_severed.emit(self, zone)

	# Check if fully disabled
	var all_severed := true
	for z in DamageZone.all_limbs():
		if not severed_limbs[z]:
			all_severed = false
			break

	if all_severed and limb_health[DamageZone.Zone.TORSO] <= torso_hp * 0.3:
		if _disabled:
			return
		_disable_enemy()


func _on_limb_lost(zone: int) -> void:
	# Speed adjustment
	var lost_legs := 0
	if severed_limbs[DamageZone.Zone.LEFT_LEG]: lost_legs += 1
	if severed_limbs[DamageZone.Zone.RIGHT_LEG]: lost_legs += 1
	match lost_legs:
		1: move_speed = _initial_move_speed * 0.5
		2: move_speed = _initial_move_speed * 0.15

	# Arm effects
	if DamageZone.is_arm(zone):
		# Lose weapon if arm lost
		pass  # Handled by subtype

	# State behavior change
	match _current_state:
		"engage", "chase":
			_evaluate_mutilated_behavior()


func _on_limb_recovered(zone: int) -> void:
	# Virtual: subclasses override to restore visual and stat effects
	pass

func _evaluate_mutilated_behavior() -> void:
	var arms_lost := int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + int(severed_limbs[DamageZone.Zone.RIGHT_ARM])
	var legs_lost := int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + int(severed_limbs[DamageZone.Zone.RIGHT_LEG])

	if arms_lost >= 2 and legs_lost >= 2:
		_enter_state("retreat")
	elif legs_lost >= 2:
		# Immobile but can still attack ranged
		if aggression > 5.0:
			_enter_state("engage")
		else:
			_enter_state("retreat")
	elif arms_lost >= 2:
		_enter_state("retreat")


# ============================================================
# Regeneration System
# ============================================================

func _process_regen(delta: float) -> void:
	# Blood Pact: enemies regen 40% faster if player has the artifact
	var blood_pact_mult := 1.0
	if GameManager.run_state:
		blood_pact_mult += GameManager.run_state.get_artifact_stat("enemy_regen_speed_mult", 0.0)

	for zone in regen_timers:
		# Severed limbs have extended regen timers that will restore them
		var timer: Dictionary = regen_timers[zone]

		# Handle pause
		if timer.paused:
			timer.current -= delta
			if timer.current <= 0.0:
				timer.paused = false
			continue

		# Tick regen
		timer.max -= delta * regen_speed_mult * blood_pact_mult

		# Legs regen faster when both lost
		if DamageZone.is_leg(zone):
			var legs_lost := int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + int(severed_limbs[DamageZone.Zone.RIGHT_LEG])
			if legs_lost >= 2:
				timer.max -= delta * 0.3  # Extra speed

		if timer.max <= 0.0:
			_regenerate_limb(zone)


func _regenerate_limb(zone: int) -> void:
	# Gate: severed limbs require 3x longer regen timer on next cycle
	var was_severed: bool = severed_limbs.get(zone, false)
	var max_hp := _get_max_limb_hp(zone)
	limb_health[zone] = max_hp
	severed_limbs[zone] = false
	# Severed limbs get a much longer regen cooldown
	var next_regen_time := base_regen_time / regen_speed_mult
	if was_severed:
		next_regen_time *= 3.0
	regen_timers[zone] = {"current": 0.0, "max": next_regen_time, "paused": false}

	if not _regen_sfx_played:
		AudioManager.SFXPlayer.play_sfx("enemy_regen")
		_regen_sfx_played = true
		get_tree().create_timer(2.0).timeout.connect(func():
			if is_instance_valid(self):
				_regen_sfx_played = false
		)

	# Restore speed
	var legs_lost := int(severed_limbs[DamageZone.Zone.LEFT_LEG]) + int(severed_limbs[DamageZone.Zone.RIGHT_LEG])
	match legs_lost:
		0: move_speed = _get_base_speed()
		1: move_speed = _get_base_speed() * 0.5
		2: move_speed = _get_base_speed() * 0.15

	EventBus.enemy_fully_regenerated.emit(self)

	# Virtual: subclasses can override to restore visuals and stats
	_on_limb_recovered(zone)


func _pause_regen(zone: int, duration: float) -> void:
	if regen_timers.has(zone):
		regen_timers[zone].paused = true
		regen_timers[zone].current = duration


func _get_max_limb_hp(zone: int) -> float:
	match zone:
		DamageZone.Zone.HEAD: return head_hp
		DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM: return arm_hp
		DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG: return leg_hp
		_: return 20.0


func _get_base_speed() -> float:
	if _initial_move_speed > 0.0:
		return _initial_move_speed
	return move_speed


# ============================================================
# State Machine
# ============================================================

func _enter_state(state_name: String) -> void:
	_exit_state()
	_current_state = state_name
	_state_timer = _get_state_duration(state_name)

	match state_name:
		"patrol":
			_patrol_index = 0
			_alert_sfx_played = false
			_regen_sfx_played = false
		"alert":
			_alerted = true
			if not _alert_sfx_played:
				AudioManager.SFXPlayer.play_sfx("enemy_alert")
				_alert_sfx_played = true
			_alert_nearby()
		"chase":
			if _target:
				navigation.target_position = _target.global_position
		"engage":
			pass
		"retreat":
			pass


func _exit_state() -> void:
	match _current_state:
		"chase":
			navigation.target_position = global_position


func _process_state(delta: float) -> void:
	match _current_state:
		"patrol": _state_patrol(delta)
		"alert": _state_alert(delta)
		"chase": _state_chase(delta)
		"engage": _state_engage(delta)
		"retreat": _state_retreat(delta)


func _state_patrol(_delta: float) -> void:
	if _patrol_points.is_empty():
		velocity = Vector2.ZERO
		return

	var target_pos := _patrol_points[_patrol_index]
	var dir := global_position.direction_to(target_pos)
	velocity = dir * move_speed * 0.5  # Slow patrol

	if global_position.distance_to(target_pos) < 10.0:
		_patrol_index = (_patrol_index + 1) % _patrol_points.size()


func _state_alert(delta: float) -> void:
	velocity = Vector2.ZERO
	if _state_timer <= 0.0:
		if _target:
			_enter_state("chase")
		else:
			_enter_state("patrol")


func _state_chase(_delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * move_speed
	_direction = dir

	# Check if in attack range
	if global_position.distance_to(_target.global_position) <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO

	# Face target
	_direction = global_position.direction_to(_target.global_position)

	# Attack if cooldown ready
	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	# Check if target moved out of range
	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		_enter_state("chase")


func _state_retreat(_delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var away_dir := global_position.direction_to(_target.global_position) * -1.0
	velocity = away_dir * move_speed * 0.7

	# Re-check target validity before distance check
	if not is_instance_valid(_target):
		_enter_state("patrol")
		return

	# Stop retreating if far enough
	if global_position.distance_to(_target.global_position) > detection_range * 1.5:
		_enter_state("patrol")


func _get_state_duration(state: String) -> float:
	match state:
		"alert": return 1.0
		"patrol": return 999.0
		"chase": return 999.0
		"engage": return 999.0
		"retreat": return 5.0
		_: return 1.0


# ============================================================
# Combat
# ============================================================

func _perform_attack() -> void:
	# Override in subtypes
	pass


func get_attack_damage() -> float:
	return attack_damage


func apply_stun(duration: float) -> void:
	_stunned = true
	_stun_timer = duration


func drop_weapon() -> void:
	# If this enemy conceptually holds a weapon, null it out
	# Subtypes with weapon tracking should override this
	pass


func _deal_melee_damage_to_player() -> void:
	# Check for player within attack radius and apply damage
	if _target == null or not is_instance_valid(_target):
		return
	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 1.2:
		return
	var knockback_dir := global_position.direction_to(_target.global_position)
	if _target.has_method("take_damage"):
		_target.take_damage(attack_damage, knockback_dir, 15.0)
	elif _target.has_method("receive_damage"):
		_target.receive_damage(attack_damage, DamageZone.Zone.TORSO, false, 15.0, knockback_dir)


func _disable_enemy() -> void:
	if _disabled:
		return
	_disabled = true
	_disabled_timer = 60.0  # Full regen takes 60-90s
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE
	AudioManager.SFXPlayer.play_sfx_2d("enemy_death", global_position, 5.0)
	ScreenEffects.flash(Color(1.0, 0.2, 0.2), 0.08, 0.3)
	EventBus.enemy_disabled.emit(self)


func is_disabled() -> bool:
	return _disabled


func is_patrolling() -> bool:
	return _current_state == "patrol"


func _alert_nearby() -> void:
	# Alert enemies in radius
	var bodies := detection_area.get_overlapping_bodies()
	for body in bodies:
		if body == self:
			continue
		if body.has_method("on_nearby_alert") and body.is_patrolling():
			body.on_nearby_alert(global_position)


func on_nearby_alert(_source_pos: Vector2) -> void:
	if not _alerted:
		_alerted = true
		_enter_state("alert")


# ============================================================
# Detection
# ============================================================

func _on_detection_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if _detection_lost_timer != null:
			if _detection_lost_callback.is_valid():
				_detection_lost_timer.timeout.disconnect(_detection_lost_callback)
			_detection_lost_timer = null
		if not _alerted:
			_target = body
			_enter_state("alert")


func _on_detection_exited(body: Node2D) -> void:
	if body == _target:
		# Don't immediately forget — keep target for a grace period
		# Target will be cleared only if truly lost (e.g. far away or scene change)
		if _current_state in ["chase", "engage"]:
			if _detection_lost_timer != null:
				if _detection_lost_callback.is_valid():
					_detection_lost_timer.timeout.disconnect(_detection_lost_callback)
			_detection_lost_timer = get_tree().create_timer(1.5)
			_detection_lost_callback = func():
				_detection_lost_timer = null
				if _target == null or not is_instance_valid(_target) or global_position.distance_to(_target.global_position) > detection_range * 1.5:
					_target = null
					if _current_state in ["chase", "engage"]:
						_enter_state("patrol")
			_detection_lost_timer.timeout.connect(_detection_lost_callback)


# ============================================================
# Visual
# ============================================================

func _flash_hurt() -> void:
	sprite.modulate = Color(2.0, 0.5, 0.5, 1.0)
	if _hurt_tween and _hurt_tween.is_valid():
		_hurt_tween.kill()
	_hurt_tween = create_tween()
	_hurt_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


func set_patrol_points(points: Array[Vector2]) -> void:
	_patrol_points = points


func _exit_tree() -> void:
	if detection_area and detection_area.body_entered.is_connected(_on_detection_entered):
		detection_area.body_entered.disconnect(_on_detection_entered)
	if detection_area and detection_area.body_exited.is_connected(_on_detection_exited):
		detection_area.body_exited.disconnect(_on_detection_exited)
