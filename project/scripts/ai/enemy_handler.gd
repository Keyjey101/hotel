extends "res://scripts/ai/base_enemy.gd"

## Handler enemy — slow, relentless, persistent grabber. The nightmare.
## Design doc: 11_ENEMY_DESIGN.md section 2.3

var _grab_active: bool = false
var _original_grab_strength: float = 10.0


func _ready() -> void:
	enemy_name = "Handler"
	enemy_type = "handler"

	torso_hp = 90.0
	head_hp = 30.0
	arm_hp = 30.0
	leg_hp = 25.0
	move_speed = 80.0
	detection_range = 180.0
	attack_range = 60.0
	attack_damage = 25.0
	attack_speed = 0.5
	grab_strength = 10.0
	regen_speed_mult = 0.7
	aggression = 5.0
	coordination = 4.0

	_original_grab_strength = grab_strength
	super._ready()


# ---------------------------------------------------------------------------
# Grab attempt — called from Engage when close to player
# ---------------------------------------------------------------------------

func grab_attempt() -> void:
	if _grab_active:
		return
	# Roll against grab_strength (10 = max, almost always succeeds)
	var roll := randf() * 10.0
	if roll <= grab_strength:
		_grab_active = true
		EventBus.player_captured.emit()
		# Player slowed 70% for 1.5s — handled by player script listening to signal
		# If another enemy nearby → emit drag signal (full drag in M4)
		get_tree().create_timer(1.5).timeout.connect(_release_grab)


func _release_grab() -> void:
	_grab_active = false


func _has_nearby_ally() -> bool:
	var enemies := get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if e == self:
			continue
		if global_position.distance_to(e.global_position) <= 100.0:
			return true
	return false


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	# Handler does NOT run — walks in a straight line, no random deviation
	if _target == null:
		_enter_state("patrol")
		return

	var direction := (_target.global_position - global_position).normalized()
	var dist := global_position.distance_to(_target.global_position)

	if dist <= attack_range:
		_enter_state("engage")
		return

	# Direct movement, no navigation noise
	velocity = direction * move_speed
	move_and_slide()


func _state_engage(delta: float) -> void:
	# Attempt grab when close
	if _target != null:
		var dist := global_position.distance_to(_target.global_position)
		if dist <= 45.0 and not _grab_active:
			grab_attempt()
	super._state_engage(delta)


# ---------------------------------------------------------------------------
# Persistent Mutilated — Handler keeps going no matter what
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)
	var damage_zones = load("res://scripts/combat/damage_zones.gd")

	# Lost one arm → grab_strength drops to 6.0, continues grab with one hand
	if zone == damage_zones.DamageZone.LEFT_ARM or zone == damage_zones.DamageZone.RIGHT_ARM:
		grab_strength = 6.0
		return

	# Lost both arms → bite attack (damage 8, grab_strength 3.0)
	var arms_severed: bool = severed_limbs.get(damage_zones.DamageZone.LEFT_ARM, false) and \
		severed_limbs.get(damage_zones.DamageZone.RIGHT_ARM, false)
	if arms_severed:
		attack_damage = 8.0
		grab_strength = 3.0
		attack_range = 30.0  # bite range
		return

	# Lost one leg → limps but DOES NOT STOP (speed * 0.7)
	if zone == damage_zones.DamageZone.LEFT_LEG or zone == damage_zones.DamageZone.RIGHT_LEG:
		# Base class already handles speed reduction; Handler just doesn't retreat
		return

	# Lost both legs → CRAWLS toward player (speed * 0.15)
	var legs_severed: bool = severed_limbs.get(damage_zones.DamageZone.LEFT_LEG, false) and \
		severed_limbs.get(damage_zones.DamageZone.RIGHT_LEG, false)
	if legs_severed:
		# Override the base class speed reduction to Handler-specific 0.15
		move_speed = 80.0 * 0.15
		return


func _evaluate_mutilated_behavior() -> void:
	# Handler NEVER retreats — override base evaluation
	# The base class might transition to retreat; Handler ignores that
	pass


func _perform_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	if _target == null:
		return
	_attack_cooldown = 1.0 / attack_speed
	_deal_melee_damage_to_player()


func get_enemy_type() -> String:
	return enemy_type
