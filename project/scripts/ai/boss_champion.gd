extends "res://scripts/ai/base_enemy.gd"

## Boss — The Champion (Floor 6: Arena/Wrath).
## Wave + Boss hybrid. Player fights 2 waves, then boss descends.
## Phases: Honour (100-50%), Glory (50-25%), Infamy (25-0%).
## Design doc: 14_BOSS_DESIGN.md section 7.

signal enemy_died(enemy)

enum BossState { WATCHING, WAVE, DESCENDING, FIGHTING }

var current_boss_state: BossState = BossState.WATCHING
var wave_number: int = 0
var max_waves: int = 2
var wave_enemies_remaining: int = 0
var _killed_enemy_ids: Dictionary = {}
var shield_hp: float = 80.0
var has_shield: bool = true

# Phase tracking
var _phase: int = 1
var _max_torso_hp: float = 300.0

# Attack timers
var _combo_step: int = 0
var _combo_timer: float = 0.0
var _whirlwind_timer: float = 0.0
var _whirlwind_active: bool = false
var _charge_timer: float = 0.0
var _charge_active: bool = false
var _charge_dir: Vector2 = Vector2.ZERO

# Enrage scaling (Phase 3)
var _current_damage_mult: float = 1.0

# Pattern variation (per-run via SeedManager)
var _phase1_patterns: Array[String] = ["combo", "shield_bash", "taunt", "spear_poke"]
var _phase2_patterns: Array[String] = ["whirlwind", "charge", "dual_strike", "weapon_throw"]
var _phase3_patterns: Array[String] = ["fist_flurry", "grab", "stomp", "rage_scream"]

# Summon scenes
var _gladiator_scene: PackedScene = null
var _berserker_scene: PackedScene = null

# Visual references
var _shield_visual: ColorRect = null
var _sword_visual: ColorRect = null
var _cape_visual: ColorRect = null

# Wave damage buff
var _wave_damage_buff: float = 0.0
var _immune: bool = false


func _ready() -> void:
	enemy_name = "The Champion"
	enemy_type = "boss"

	torso_hp = 300.0
	head_hp = 70.0
	arm_hp = 70.0
	leg_hp = 70.0
	move_speed = 140.0
	detection_range = 400.0
	attack_range = 60.0
	attack_damage = 25.0
	attack_speed = 0.7
	grab_strength = 4.0
	regen_speed_mult = 0.8
	aggression = 8.0
	coordination = 6.0

	_max_torso_hp = torso_hp

	add_to_group("boss")
	super._ready()
	_create_boss_visuals()

	# Pre-load summon scenes
	if ResourceLoader.exists("res://scenes/enemies/gladiator.tscn"):
		_gladiator_scene = load("res://scenes/enemies/gladiator.tscn")
	if ResourceLoader.exists("res://scenes/enemies/berserker.tscn"):
		_berserker_scene = load("res://scenes/enemies/berserker.tscn")

	# Start in watching state — immune until waves cleared
	_disabled = true
	_immune = true
	current_boss_state = BossState.WATCHING
	wave_number = 0
	enemy_died.connect(_on_wave_enemy_died)
	_setup_pattern_variation()
	_start_next_wave()


func _create_boss_visuals() -> void:
	# Shield
	_shield_visual = ColorRect.new()
	_shield_visual.name = "ShieldVisual"
	_shield_visual.size = Vector2(16, 28)
	_shield_visual.color = Color(0.855, 0.647, 0.125)  # #DAA520 gold
	_shield_visual.position = Vector2(-20.0, -14.0)
	_shield_visual.z_index = 1
	sprite.add_child(_shield_visual)

	# Greatsword
	_sword_visual = ColorRect.new()
	_sword_visual.name = "SwordVisual"
	_sword_visual.size = Vector2(5, 50)
	_sword_visual.color = Color(0.753, 0.753, 0.753)  # #C0C0C0 silver
	_sword_visual.position = Vector2(8.0, -35.0)
	_sword_visual.z_index = 1
	sprite.add_child(_sword_visual)

	# Cape
	_cape_visual = ColorRect.new()
	_cape_visual.name = "CapeVisual"
	_cape_visual.size = Vector2(24, 18)
	_cape_visual.color = Color(0.545, 0.0, 0.0)  # #8B0000 blood red
	_cape_visual.position = Vector2(-12.0, 10.0)
	_cape_visual.z_index = -1
	sprite.add_child(_cape_visual)


# ---------------------------------------------------------------------------
# Physics
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	match current_boss_state:
		BossState.WATCHING:
			_process_watching(delta)
			return
		BossState.DESCENDING:
			_process_descending(delta)
			return
		BossState.FIGHTING:
			_update_phase()
			_update_enrage_scaling()
			_process_whirlwind(delta)
			_process_charge(delta)
			super._physics_process(delta)


# ---------------------------------------------------------------------------
# Pattern variation (SeedManager)
# ---------------------------------------------------------------------------

var _rng: RandomNumberGenerator = null


func _get_rng() -> RandomNumberGenerator:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
		if GameManager.seed_manager != null:
			_rng.seed = GameManager.seed_manager.get_seed() + hash("champion")
	return _rng


func _setup_pattern_variation() -> void:
	# Select 3 of 4 patterns per phase (one always included)
	# Uses SeedManager for per-run determinism
	var rng := RandomNumberGenerator.new()
	if GameManager.seed_manager != null:
		rng = GameManager.seed_manager.get_room_rng(6, 0)

	_phase1_patterns = _select_patterns(["combo", "shield_bash", "taunt", "spear_poke"], "combo", rng)
	_phase2_patterns = _select_patterns(["whirlwind", "charge", "dual_strike", "weapon_throw"], "charge", rng)
	_phase3_patterns = _select_patterns(["fist_flurry", "grab", "stomp", "rage_scream"], "grab", rng)


func _select_patterns(all: Array[String], required: String, rng: RandomNumberGenerator) -> Array[String]:
	var result: Array[String] = [required]
	var optional: Array[String] = []
	for p in all:
		if p != required:
			optional.append(p)
	# Shuffle and pick 2 using seeded RNG (Fisher-Yates)
	for i in range(optional.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = optional[i]
		optional[i] = optional[j]
		optional[j] = tmp
	result.append(optional[0])
	result.append(optional[1])
	return result


# ---------------------------------------------------------------------------
# Wave system
# ---------------------------------------------------------------------------

func _start_next_wave() -> void:
	wave_number += 1
	if wave_number > max_waves:
		_start_descent()
		return

	print("[Champion] Wave %d begins!" % wave_number)

	# Buff wave enemies: +15% damage cumulative per wave
	_wave_damage_buff = (wave_number - 1) * 0.15

	_spawn_wave_enemies(wave_number)


func _spawn_wave_enemies(wave: int) -> void:
	var enemies_to_spawn: Array[Dictionary] = []

	match wave:
		1:
			enemies_to_spawn.append({"type": "gladiator", "count": 1})
			enemies_to_spawn.append({"type": "berserker", "count": 1})
		2:
			enemies_to_spawn.append({"type": "gladiator", "count": 2})
			enemies_to_spawn.append({"type": "berserker", "count": 2})

	wave_enemies_remaining = 0
	for group in enemies_to_spawn:
		wave_enemies_remaining += group["count"]

		for i in range(group["count"]):
			var scene: PackedScene = null
			if group["type"] == "gladiator" and _gladiator_scene != null:
				scene = _gladiator_scene
			elif group["type"] == "berserker" and _berserker_scene != null:
				scene = _berserker_scene

				if scene != null:
					var enemy := scene.instantiate() as CharacterBody2D
					if enemy != null:
						enemy.global_position = global_position + Vector2(_get_rng().randf_range(-100, 100), _get_rng().randf_range(-80, 80))
						# Apply wave damage buff
						if "attack_damage" in enemy:
							enemy.attack_damage *= (1.0 + _wave_damage_buff)
						# Connect death via EventBus.enemy_disabled (one-shot per enemy)
						EventBus.enemy_disabled.connect(func(_e: CharacterBody2D) -> void:
							if is_instance_valid(enemy) and _e == enemy:
								enemy_died.emit(enemy)
						, Object.CONNECT_ONE_SHOT)
					get_tree().current_scene.add_child(enemy)
			else:
				print("[Champion] Wave enemy scene not found: %s" % group["type"])


func _on_wave_enemy_died(enemy: CharacterBody2D) -> void:
	var id := enemy.get_instance_id()
	if _killed_enemy_ids.has(id):
		return
	_killed_enemy_ids[id] = true
	wave_enemies_remaining -= 1
	if wave_enemies_remaining <= 0:
		_killed_enemy_ids.clear()
		print("[Champion] Wave %d cleared!" % wave_number)
		_start_next_wave()


func _process_watching(_delta: float) -> void:
	# Boss sits on throne, watching. Doesn't move or fight.
	velocity = Vector2.ZERO
	# Face player if visible
	if _target and is_instance_valid(_target):
		_direction = global_position.direction_to(_target.global_position)


# ---------------------------------------------------------------------------
# Descent transition
# ---------------------------------------------------------------------------

func _start_descent() -> void:
	current_boss_state = BossState.DESCENDING
	print("[Champion] The Champion descends!")
	# Screen shake
	_screen_shake(0.3)


func _process_descending(delta: float) -> void:
	# Move from throne position to center of arena
	var center := _find_arena_center()
	var dir := global_position.direction_to(center)
	velocity = dir * move_speed * 1.5

	if global_position.distance_to(center) < 10.0:
		velocity = Vector2.ZERO
		current_boss_state = BossState.FIGHTING
		_disabled = false
		_immune = false
		_enter_state("chase")
		print("[Champion] Boss fight begins!")


func _find_arena_center() -> Vector2:
	var room := _find_room_instance()
	if room:
		return room.global_position + room.room_bounds.size * 0.5
	return global_position


func _find_room_instance() -> RoomInstance:
	var node := get_parent()
	while node != null:
		if node is RoomInstance:
			return node
		node = node.get_parent()
	return null


func _screen_shake(duration: float) -> void:
	var camera := get_tree().get_first_node_in_group("camera")
	if camera and camera is Camera2D:
		var cam := camera as Camera2D
		var tween := create_tween()
		tween.tween_property(cam, "offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.05)
		tween.tween_property(cam, "offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.05)
		tween.tween_property(cam, "offset", Vector2(randf_range(-4, 4), randf_range(-4, 4)), 0.05)
		tween.tween_property(cam, "offset", Vector2.ZERO, 0.05)


# ---------------------------------------------------------------------------
# Phase management
# ---------------------------------------------------------------------------

func _update_phase() -> void:
	var hp_pct: float = float(limb_health[DamageZone.Zone.TORSO]) / _max_torso_hp
	var limbs_lost := _count_lost_limbs()
	var new_phase: int

	if hp_pct > 0.5 and not (has_shield and shield_hp <= 0.0):
		new_phase = 1
	elif hp_pct > 0.25 and limbs_lost < 2:
		new_phase = 2
	else:
		new_phase = 3

	if new_phase != _phase:
		_phase = new_phase
		_on_phase_changed()


func _count_lost_limbs() -> int:
	var count := 0
	for zone in [DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM, DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG]:
		if severed_limbs.get(zone, false):
			count += 1
	return count


func _on_phase_changed() -> void:
	match _phase:
		2:
			_drop_shield()
		3:
			_throw_swords()


func _update_enrage_scaling() -> void:
	if _phase >= 3:
		var hp_pct: float = float(limb_health[DamageZone.Zone.TORSO]) / _max_torso_hp
		_current_damage_mult = 1.0 + (1.0 - hp_pct)


# ---------------------------------------------------------------------------
# Phase 1 — Honour: Greatsword combo + Shield Block
# ---------------------------------------------------------------------------

func _state_engage(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	_direction = global_position.direction_to(_target.global_position)
	velocity = Vector2.ZERO

	# Greatsword combo
	if _attack_cooldown <= 0.0:
		_perform_combo_attack()
		_attack_cooldown = attack_speed

	# Arena taunt (visual)
	if _phase == 1 and randf() < 0.01:
		_screen_shake(0.1)

	var dist := global_position.distance_to(_target.global_position)
	if dist > attack_range * 2.0:
		_enter_state("chase")


func _perform_combo_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var damages := [20.0, 25.0, 30.0]
	var damage: float = damages[_combo_step] * _current_damage_mult

	if _target.has_method("receive_damage"):
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 25.0, global_position.direction_to(_target.global_position))

	_combo_step += 1
	if _combo_step >= 3:
		_combo_step = 0


# ---------------------------------------------------------------------------
# Phase 2 — Glory: Whirlwind + Charge
# ---------------------------------------------------------------------------

func _drop_shield() -> void:
	has_shield = false
	if _shield_visual and is_instance_valid(_shield_visual):
		_shield_visual.queue_free()
		_shield_visual = null
	# Add second sword visual
	if _sword_visual and is_instance_valid(_sword_visual):
		var second_sword := ColorRect.new()
		second_sword.name = "SwordVisual2"
		second_sword.size = Vector2(5, 50)
		second_sword.color = Color(0.753, 0.753, 0.753)
		second_sword.position = Vector2(-16.0, -35.0)
		second_sword.z_index = 1
		sprite.add_child(second_sword)


func _state_chase(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	# Phase 2+: Whirlwind if available
	if _phase >= 2 and _whirlwind_timer <= 0.0 and dist <= 80.0 and not _whirlwind_active:
		_start_whirlwind()
		return

	# Phase 2+: Charge
	if _phase >= 2 and _charge_timer <= 0.0 and dist > 80.0 and dist < 200.0 and not _charge_active:
		_start_charge()
		return

	super._state_chase(delta)


# ---------------------------------------------------------------------------
# Whirlwind
# ---------------------------------------------------------------------------

func _start_whirlwind() -> void:
	_whirlwind_active = true
	_whirlwind_timer = 1.5
	print("[Champion] WHIRLWIND!")


func _process_whirlwind(delta: float) -> void:
	if not _whirlwind_active:
		return
	_whirlwind_timer -= delta

	# Spin and deal AoE damage
	velocity = Vector2.ZERO
	if sprite:
		sprite.rotation += 10.0 * delta

	# AoE damage every 0.3s
	if _target and is_instance_valid(_target):
		var dist := global_position.distance_to(_target.global_position)
		if dist <= 80.0 and _attack_cooldown <= 0.0:
			if _target.has_method("receive_damage"):
				_target.receive_damage(35.0 * _current_damage_mult, DamageZone.Zone.TORSO, false, 30.0, global_position.direction_to(_target.global_position))
			_attack_cooldown = 0.3

	if _whirlwind_timer <= 0.0:
		_whirlwind_active = false
		if sprite:
			sprite.rotation = 0.0
		_whirlwind_timer = 8.0


# ---------------------------------------------------------------------------
# Charge
# ---------------------------------------------------------------------------

func _start_charge() -> void:
	_charge_active = true
	_charge_timer = 1.0
	if _target and is_instance_valid(_target):
		_charge_dir = global_position.direction_to(_target.global_position)
	else:
		_charge_dir = _direction


func _process_charge(delta: float) -> void:
	if not _charge_active:
		return
	_charge_timer -= delta

	velocity = _charge_dir * move_speed * 2.5

	# Check if hit player
	if _target and is_instance_valid(_target):
		if global_position.distance_to(_target.global_position) <= 40.0:
			if _target.has_method("receive_damage"):
				_target.receive_damage(40.0 * _current_damage_mult, DamageZone.Zone.TORSO, false, 120.0, _charge_dir)
			_charge_active = false
			_charge_timer = 6.0
			return

	if _charge_timer <= 0.0:
		_charge_active = false
		_charge_timer = 8.0


# ---------------------------------------------------------------------------
# Phase 3 — Infamy: Bare fists, grab, enrage
# ---------------------------------------------------------------------------

func _throw_swords() -> void:
	if _sword_visual and is_instance_valid(_sword_visual):
		_sword_visual.queue_free()
		_sword_visual = null
	# Remove any swords too
	for child in sprite.get_children():
		if child is ColorRect and child.name.begins_with("SwordVisual"):
			child.queue_free()


func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	var dir_to_target := global_position.direction_to(_target.global_position)

	if _phase >= 3:
		# Bare fists — fast, high damage, ×2.0 limb damage
		var damage := 30.0 * _current_damage_mult
		if _target.has_method("receive_damage"):
			_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 30.0, dir_to_target * -1.0)

		# Grab attempt (Phase 3)
		if dist <= 50.0 and _get_rng().randf() < 0.3:
			_perform_grab_throw()
	else:
		# Standard attack from base
		super._perform_attack()


func _perform_grab_throw() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	# 40 dmg + reposition player
	if _target.has_method("receive_damage"):
		_target.receive_damage(40.0 * _current_damage_mult, DamageZone.Zone.TORSO, false, 150.0, global_position.direction_to(_target.global_position))


# ---------------------------------------------------------------------------
# Shield block (absorbs frontal damage)
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if current_boss_state != BossState.FIGHTING or _immune:
		return

	# Shield block
	if has_shield and shield_hp > 0.0 and knockback_dir != Vector2.ZERO:
		var facing_dir := _direction.normalized()
		var incoming_dir := knockback_dir.normalized() if knockback_dir != Vector2.ZERO else -facing_dir
		var dot := facing_dir.dot(incoming_dir)
		if dot < 0.0:
			# Frontal hit — shield absorbs
			shield_hp -= damage
			print("[Champion] Shield absorbs %.0f damage (HP: %.0f)" % [damage, shield_hp])
			if shield_hp <= 0.0:
				_drop_shield()
			EventBus.enemy_damaged.emit(self, zone, 0.0)
			return

	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


# ---------------------------------------------------------------------------
# Mutilation overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	# Champion stays aggressive regardless of limb loss
	if _current_state in ["patrol", "retreat"]:
		_enter_state("chase")


func _evaluate_mutilated_behavior() -> void:
	# Champion NEVER retreats
	if _current_state in ["patrol", "retreat"]:
		_enter_state("chase")
