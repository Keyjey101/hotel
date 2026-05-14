extends "res://scripts/ai/base_enemy.gd"

## Seductress enemy -- deception, decoy, lure. Floor 2 Lust.

var decoys: Array[Node2D] = []
var max_decoys: int = 2
var _kiss_on_cooldown: bool = false
var _retreating_to_guard: bool = false
var _base_aggression: float = 2.0

var _decoy_position_history: Array[Vector2] = []
var _decoy_history_timer: float = 0.0
const DECOY_DELAY: float = 0.3
var _rng: RandomNumberGenerator


func _ready() -> void:
	enemy_name = "Seductress"
	enemy_type = "seductress"

	torso_hp = 35.0
	head_hp = 15.0
	arm_hp = 10.0
	leg_hp = 10.0
	move_speed = 130.0
	detection_range = 250.0
	attack_range = 30.0
	attack_damage = 8.0
	attack_speed = 0.6
	grab_strength = 5.0
	regen_speed_mult = 1.3
	aggression = 2.0
	coordination = 7.0

	_base_aggression = aggression
	super._ready()
	_rng = RandomNumberGenerator.new()
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("get_seed_manager"):
		var sm = gm.get_seed_manager()
		if sm and sm.has_method("get_floor_rng"):
			_rng = sm.get_floor_rng(2)
		else:
			_rng.seed = hash("seductress")
	else:
		_rng.seed = hash("seductress")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_decoy_positions(delta)


func _enter_state(state_name: String) -> void:
	super._enter_state(state_name)
	if state_name in ["alert", "chase"]:
		_spawn_decoys()


# ---------------------------------------------------------------------------
# Mirror Decoy
# ---------------------------------------------------------------------------

func _spawn_decoys() -> void:
	if decoys.size() >= max_decoys:
		return
	var arms_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_ARM, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false)
	if arms_severed:
		return

	var count := mini(max_decoys - decoys.size(), _rng.randi_range(1, 2))
	_decoy_history_timer = 0.0

	for i in count:
		var decoy := ColorRect.new()
		decoy.size = Vector2(24.0, 36.0)
		decoy.color = Color(1.0, 0.412, 0.706, 0.8)
		decoy.position = -decoy.size / 2.0
		decoy.mouse_filter = Control.MOUSE_FILTER_IGNORE
		get_tree().current_scene.add_child(decoy)
		decoy.global_position = global_position
		decoys.append(decoy)


func _update_decoy_positions(delta: float) -> void:
	_decoy_history_timer += delta
	if _decoy_history_timer >= DECOY_DELAY:
		_decoy_history_timer = 0.0
		_decoy_position_history.append(global_position)
		var max_samples := int(DECOY_DELAY * 60.0)
		if _decoy_position_history.size() > max_samples:
			_decoy_position_history.pop_front()

	var legs_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)

	for decoy in decoys:
		if not is_instance_valid(decoy):
			continue
		var target_pos := global_position
		if _decoy_position_history.size() > 0:
			target_pos = _decoy_position_history[-1]
		if legs_severed:
			target_pos = global_position
		decoy.global_position = decoy.global_position.lerp(target_pos, 5.0 * delta)


func _on_decoy_hit(decoy: Node2D) -> void:
	if not is_instance_valid(self) or not is_instance_valid(decoy):
		return
	decoys.erase(decoy)
	# Re-check self validity before creating tween (parent may be freed between calls)
	if not is_instance_valid(self):
		if is_instance_valid(decoy):
			decoy.queue_free()
		return
	var tween := create_tween()
	tween.tween_property(decoy, "color:a", 0.0, 0.3)
	tween.tween_callback(decoy.queue_free)


# ---------------------------------------------------------------------------
# Lure (Kiss) / Retreat
# ---------------------------------------------------------------------------

func _state_alert(delta: float) -> void:
	super._state_alert(delta)


func _state_chase(delta: float) -> void:
	if _retreating_to_guard:
		_move_toward_bodyguard(delta)
		return

	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	if dist > 80.0:
		navigation.target_position = _target.global_position
		var next_pos := navigation.get_next_path_position()
		var dir := global_position.direction_to(next_pos)
		velocity = dir * move_speed * 0.5
		_direction = dir
	elif dist <= attack_range:
		_enter_state("engage")
	else:
		navigation.target_position = _target.global_position
		var next_pos := navigation.get_next_path_position()
		var dir := global_position.direction_to(next_pos)
		velocity = dir * move_speed
		_direction = dir


func _state_engage(delta: float) -> void:
	if not _target or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	var dist := global_position.distance_to(_target.global_position)

	if dist > 80.0:
		_enter_state("chase")
		return

	if dist <= attack_range and not _kiss_on_cooldown:
		_perform_kiss()
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)


func _perform_kiss() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	_kiss_on_cooldown = true
	EventBus.player_captured.emit()

	var cooldown_timer := get_tree().create_timer(3.0)
	cooldown_timer.timeout.connect(func() -> void:
		if not is_instance_valid(self): return
		_kiss_on_cooldown = false
	)

	_begin_retreat()


func _begin_retreat() -> void:
	_retreating_to_guard = true
	aggression = 0.0
	_enter_state("retreat")


func _state_retreat(delta: float) -> void:
	if not _retreating_to_guard:
		super._state_retreat(delta)
		return

	_move_toward_bodyguard(delta)


func _move_toward_bodyguard(delta: float) -> void:
	var guard := _find_nearest_bodyguard()
	if guard != null:
		navigation.target_position = guard.global_position
		var next_pos := navigation.get_next_path_position()
		var dir := global_position.direction_to(next_pos)
		velocity = dir * move_speed * 1.2
		_direction = dir

		if global_position.distance_to(guard.global_position) < 50.0:
			_retreating_to_guard = false
			aggression = _base_aggression
			_enter_state("alert")
	else:
		_retreating_to_guard = false
		aggression = _base_aggression
		var away_dir := global_position.direction_to(_target.global_position) * -1.0 if _target and is_instance_valid(_target) else Vector2.ZERO
		velocity = away_dir * move_speed * 0.7


func _find_nearest_bodyguard() -> Node2D:
	var best: Node2D = null
	var best_dist := 500.0
	var guards := get_tree().get_nodes_in_group("bodyguards")
	for g in guards:
		if not is_instance_valid(g):
			continue
		var dist := global_position.distance_to(g.global_position)
		if dist < best_dist:
			best = g
			best_dist = dist
	return best


# ---------------------------------------------------------------------------
# Mutilated overrides
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	var arms_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_ARM, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_ARM, false)
	var legs_severed: bool = severed_limbs.get(DamageZone.Zone.LEFT_LEG, false) and \
		severed_limbs.get(DamageZone.Zone.RIGHT_LEG, false)

	if arms_severed:
		for decoy in decoys:
			if is_instance_valid(decoy):
				var tween := create_tween()
				tween.tween_property(decoy, "color:a", 0.0, 0.3)
				tween.tween_callback(decoy.queue_free)
		decoys.clear()

	if arms_severed and _current_state != "retreat":
		_begin_retreat()
		return

	if legs_severed and _current_state != "retreat":
		_begin_retreat()
		return


func _perform_attack() -> void:
	_perform_kiss()
