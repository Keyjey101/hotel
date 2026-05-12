extends "res://scripts/ai/base_enemy.gd"

## BossSister — Floor 9 narrative encounter.
## NOT a standard boss fight. Dialogue + choice encounter with optional combat.
## 3 phases: Recognition (auto dialogue) → Confrontation (player choice) → Resolution.

# ── Phase tracking ──
var _encounter_phase: int = 0  # 0=not started, 1=recognition, 2=confrontation, 3=resolution
var _max_torso_hp: float = 350.0

# ── Choice tracking ──
var _player_chose_fight: bool = false
var _player_chose_listen: bool = false
var _player_chose_embrace: bool = false
var _sister_damage_dealt: float = 0.0
var _player_embraced: bool = false
var _sister_spared: bool = false
var _sister_killed: bool = false
var _ending_triggered: bool = false

# ── Dialogue system ──
var _dialogue_queue: Array[Dictionary] = []  # [{text, duration}]
var _showing_dialogue: bool = false
var _dialogue_label: Label = null

# ── Choice labels ──
var _choice_labels: Array[Label] = []
var _choice_made: bool = false

# ── Hesitation mechanic ──
var _hesitation_thresholds: Array[float] = [0.8, 0.6, 0.4, 0.2]
var _hesitation_texts: Array[String] = [
	"Why are you doing this?",
	"I'm still your sister.",
	"Please.",
]
var _hesitating: bool = false
var _hesitation_timer: float = 0.0
var _next_hesitation_idx: int = 0
var _player_attack_pause_timer: float = 0.0

# ── Run count dialogue ──
var _run_count: int = 1

# ── Combat ──
var _player_weapon_copies: Array = []
var _attack_with_copies: bool = false


func _ready() -> void:
	enemy_name = "The Sister"
	enemy_type = "boss"

	torso_hp = 350.0
	head_hp = 60.0
	arm_hp = 60.0
	leg_hp = 60.0
	move_speed = 160.0
	detection_range = 500.0  # Large — she sees player from start
	attack_range = 50.0
	attack_damage = 20.0
	attack_speed = 0.8
	grab_strength = 0.0
	regen_speed_mult = 1.3
	aggression = 3.0  # Low — she doesn't want to fight
	coordination = 5.0

	_max_torso_hp = torso_hp

	add_to_group("boss")
	add_to_group("sister")

	# Read run count for dialogue variation
	var records: Dictionary = SaveManager.load_records()
	_run_count = int(records.get("total_runs", 1)) + 1  # +1 because current run hasn't been counted yet

	super._ready()


# ---------------------------------------------------------------------------
# Custom physics — no standard patrol/chase until combat phase
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if _disabled:
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
	_phase_cooldown_tick(delta)

	# Hesitation timer
	if _hesitating:
		_hesitation_timer -= delta
		if _hesitation_timer <= 0.0:
			_hesitating = false
		velocity = Vector2.ZERO
		move_and_slide()
		_process_regen(delta)
		return

	# Player stopped attacking check (for spare detection)
	if _player_chose_fight and not _sister_killed:
		_player_attack_pause_timer += delta

	match _encounter_phase:
		0:
			# Not started — stand still
			velocity = Vector2.ZERO
		1:
			_process_recognition(delta)
		2:
			_process_confrontation(delta)
		3:
			if _player_chose_fight:
				_process_combat(delta)
			else:
				velocity = Vector2.ZERO

	_process_regen(delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	velocity += _knockback_vel
	move_and_slide()


func _phase_cooldown_tick(delta: float) -> void:
	pass  # Placeholder


# ---------------------------------------------------------------------------
# Phase 1 — Recognition (auto dialogue)
# ---------------------------------------------------------------------------

func start_encounter() -> void:
	if _encounter_phase != 0:
		return
	_encounter_phase = 1

	# Build dialogue queue based on run count
	var opening_line := _get_opening_line()
	_dialogue_queue = [
		{"text": opening_line, "duration": 2.0},
		{"text": "I was like you once. Scared. Angry. Then I understood.", "duration": 3.0},
		{"text": "I volunteered. I WANTED this.", "duration": 3.0},
	]
	_process_dialogue_queue()


func _get_opening_line() -> String:
	if _run_count <= 1:
		return "How did you find me? You need to leave."
	elif _run_count == 2:
		return "You came back. I knew you would."
	elif _run_count >= 3 and _run_count < 5:
		return "You keep dying. I keep watching."
	else:
		return "I remember all of them. Every time you've come for me."


func _process_recognition(_delta: float) -> void:
	velocity = Vector2.ZERO
	# Dialogue is handled by _process_dialogue_queue
	if _dialogue_queue.is_empty() and not _showing_dialogue:
		_enter_confrontation()


# ---------------------------------------------------------------------------
# Phase 2 — Confrontation (player choice)
# ---------------------------------------------------------------------------

func _enter_confrontation() -> void:
	_encounter_phase = 2
	_show_choices()


func _show_choices() -> void:
	_clear_choice_labels()

	var choice_texts: Array[String] = [
		"[1] ATTACK — Fight her",
		"[2] LISTEN — Hear her out",
		"[3] EMBRACE — Approach without weapon",
	]

	for i in range(choice_texts.size()):
		var label := Label.new()
		label.text = choice_texts[i]
		label.position = Vector2(80, 140 + i * 20)
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.8))
		label.z_index = 100
		get_tree().current_scene.add_child(label)
		_choice_labels.append(label)


func _process_confrontation(_delta: float) -> void:
	velocity = Vector2.ZERO

	if _choice_made:
		return

	# Check for input
	if Input.is_action_just_pressed("attack") or Input.is_key_pressed(KEY_1):
		_choose_fight()
	elif Input.is_key_pressed(KEY_2):
		_choose_listen()
	elif Input.is_key_pressed(KEY_3):
		_choose_embrace()


func _choose_fight() -> void:
	_choice_made = true
	_player_chose_fight = true
	_clear_choice_labels()
	_show_dialogue("So be it.", 2.0)
	_encounter_phase = 3
	aggression = 8.0
	# Copy player's weapons
	_copy_player_weapons()
	await get_tree().create_timer(2.0).timeout
	_enter_state("chase")


func _choose_listen() -> void:
	_choice_made = true
	_player_chose_listen = true
	_clear_choice_labels()
	_start_listen_path()


func _choose_embrace() -> void:
	_choice_made = true
	_player_chose_embrace = true
	_clear_choice_labels()
	_start_embrace_path()


# ---------------------------------------------------------------------------
# Combat Path (ATTACK)
# ---------------------------------------------------------------------------

func _copy_player_weapons() -> void:
	# Copy player's equipped weapon data for mirror attacks
	_attack_with_copies = false
	if GameManager.run_state == null:
		return
	var ws: Array = GameManager.run_state.weapon_slots
	for w in ws:
		if w != null:
			_player_weapon_copies.append(w)
			_attack_with_copies = true


func _process_combat(delta: float) -> void:
	if not is_instance_valid(_target):
		return

	var hp_pct := limb_health[DamageZone.Zone.TORSO] / _max_torso_hp

	# Check hesitation thresholds
	if _next_hesitation_idx < _hesitation_thresholds.size():
		var threshold := _hesitation_thresholds[_next_hesitation_idx]
		if hp_pct <= threshold:
			_start_hesitation()
			return

	# Check if HP < 10% — Sister stops fighting
	if hp_pct < 0.1 and not _sister_spared:
		velocity = Vector2.ZERO
		# Wait for player to decide
		if _player_attack_pause_timer >= 3.0:
			# Player stopped attacking → spare
			_sister_spared = true
			_show_dialogue("You're still you.", 3.0)
			# Signal ending B path
			GameManager.run_state.mini_boss_defeated[9] = true
			GameManager.run_state.run_meta["sister_spared"] = true if GameManager.run_state else null
			EventBus.mini_boss_defeated.emit(9)
		return

	_process_state(delta)


func _start_hesitation() -> void:
	_hesitating = true
	_hesitation_timer = 1.5
	velocity = Vector2.ZERO
	var text := _hesitation_texts[_next_hesitation_idx % _hesitation_texts.size()]
	_show_dialogue(text, 1.5)
	_next_hesitation_idx += 1


func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var damage := attack_damage
	if _attack_with_copies and not _player_weapon_copies.is_empty():
		var w = _player_weapon_copies[0]
		if w and w.get("damage") != null:
			damage = float(w.get("damage"))

	if _target.has_method("receive_damage"):
		var dir := global_position.direction_to(_target.global_position)
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 20.0, dir * -1.0)


func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	# Track damage dealt to Sister (for ending determination)
	_sister_damage_dealt += damage
	_player_attack_pause_timer = 0.0  # Reset — player IS attacking

	# Check if killed
	if zone == DamageZone.Zone.TORSO:
		var hp_after := limb_health[DamageZone.Zone.TORSO] - damage
		if hp_after <= 0.0:
			_sister_killed = true
			_show_dialogue("I forgive you.", 2.0)
			# Signal ending A path
			if GameManager.run_state:
				GameManager.run_state.mini_boss_defeated[9] = true
				GameManager.run_state.run_meta["sister_killed"] = true
			super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)
			EventBus.mini_boss_defeated.emit(9)
			return

	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


# ---------------------------------------------------------------------------
# Listen Path
# ---------------------------------------------------------------------------

func _start_listen_path() -> void:
	_encounter_phase = 3

	# Check Void Contract — blocks Ending C
	if GameManager.run_state and GameManager.run_state.has_artifact("Void Contract"):
		_show_dialogue("You signed the contract. No revelation for you.", 3.0)
		await get_tree().create_timer(3.0).timeout
		# Force combat
		_player_chose_fight = true
		_player_chose_listen = false
		aggression = 8.0
		_copy_player_weapons()
		_enter_state("chase")
		return

	# Truth dialogue
	var truth_dialogue: Array[Dictionary] = [
		{"text": "You came here to save her.", "duration": 3.0},
		{"text": "But you were never outside. You were always inside.", "duration": 3.0},
		{"text": "The Hotel doesn't have guests. It has inmates.", "duration": 3.0},
		{"text": "And you... you were the first.", "duration": 3.0},
	]
	_dialogue_queue = truth_dialogue
	_process_dialogue_queue()

	# Wait for dialogue to finish, then trigger Ending C
	await get_tree().create_timer(13.0).timeout
	_trigger_ending("c")


# ---------------------------------------------------------------------------
# Embrace Path
# ---------------------------------------------------------------------------

func _start_embrace_path() -> void:
	_encounter_phase = 3

	# Sister stabs player — lose 50% HP
	_show_dialogue("I'm sorry.", 1.0)
	await get_tree().create_timer(1.0).timeout

	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("receive_damage"):
		var hp := GameManager.run_state.player_hp if GameManager.run_state else 100.0
		var stab_damage := hp * 0.5
		player.receive_damage(stab_damage, DamageZone.Zone.TORSO, false)

	# Check if player survives
	await get_tree().create_timer(0.5).timeout
	var current_hp := GameManager.run_state.player_hp if GameManager.run_state else 0.0
	if current_hp > 0.0:
		_player_embraced = true
		# Hidden path opens → Ending D
		_trigger_ending("d")
	else:
		# Player died from the stab
		GameManager.handle_player_death()


# ---------------------------------------------------------------------------
# Dialogue system
# ---------------------------------------------------------------------------

func _show_dialogue(text: String, duration: float) -> void:
	# Create or reuse dialogue label
	if _dialogue_label and is_instance_valid(_dialogue_label):
		_dialogue_label.queue_free()

	_dialogue_label = Label.new()
	_dialogue_label.text = text
	_dialogue_label.position = Vector2(60, 200)
	_dialogue_label.add_theme_font_size_override("font_size", 8)
	_dialogue_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.8))
	_dialogue_label.z_index = 100
	_dialogue_label.modulate.a = 0.0
	get_tree().current_scene.add_child(_dialogue_label)

	# Tween alpha in → hold → alpha out
	var tween := create_tween()
	tween.tween_property(_dialogue_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(_dialogue_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		if is_instance_valid(_dialogue_label):
			_dialogue_label.queue_free()
			_dialogue_label = null
	)


func _process_dialogue_queue() -> void:
	if _dialogue_queue.is_empty():
		return

	_showing_dialogue = true
	var entry: Dictionary = _dialogue_queue.pop_front()
	var text: String = entry["text"]
	var duration: float = entry["duration"]

	_show_dialogue(text, duration)

	# Wait then process next
	var total_time := duration + 0.6  # include fade in/out
	get_tree().create_timer(total_time).timeout.connect(func():
		_showing_dialogue = false
		_process_dialogue_queue()
	)


func _clear_dialogue() -> void:
	if _dialogue_label and is_instance_valid(_dialogue_label):
		_dialogue_label.queue_free()
		_dialogue_label = null
	_dialogue_queue.clear()
	_showing_dialogue = false


func _clear_choice_labels() -> void:
	for label in _choice_labels:
		if is_instance_valid(label):
			label.queue_free()
	_choice_labels.clear()


# ---------------------------------------------------------------------------
# Detection override — auto-start encounter instead of chasing
# ---------------------------------------------------------------------------

func _on_detection_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _encounter_phase == 0:
		_target = body
		start_encounter()


# ---------------------------------------------------------------------------
# Death override
# ---------------------------------------------------------------------------

func _disable_enemy() -> void:
	_clear_dialogue()
	_clear_choice_labels()

	if not _sister_killed:
		# Spared or non-combat path
		_sister_spared = true
		# Track if player never attacked her
		if _sister_damage_dealt <= 0.0 and GameManager.run_state:
			GameManager.run_state.run_meta["sister_never_attacked"] = true

	EventBus.enemy_disabled.emit(self)


# ---------------------------------------------------------------------------
# Ending trigger
# ---------------------------------------------------------------------------

func _trigger_ending(ending_id: String) -> void:
	if _ending_triggered:
		return
	_ending_triggered = true

	_clear_dialogue()
	_clear_choice_labels()

	if GameManager.run_state:
		GameManager.run_state.mini_boss_defeated[9] = true
		GameManager.run_state.run_meta["ending_id"] = ending_id
		match ending_id:
			"c":
				GameManager.run_state.run_meta["sister_never_attacked"] = true
			"d":
				GameManager.run_state.run_meta["player_embraced"] = true

	EventBus.mini_boss_defeated.emit(9)

	# Ending C/D bypass Satan fight entirely
	if ending_id in ["c", "d"]:
		GameManager.trigger_ending(ending_id)
	else:
		# A/B proceed to Satan fight
		GameManager.handle_floor_completed(9)


# ---------------------------------------------------------------------------
# Sister as ally (called by boss_satan.gd)
# ---------------------------------------------------------------------------

func become_ally() -> void:
	# Reset for ally role in Satan fight
	_encounter_phase = 3
	_sister_spared = true
	aggression = 9.0
	attack_damage = 25.0
	torso_hp = 200.0
	_max_torso_hp = 200.0
	limb_health[DamageZone.Zone.TORSO] = 200.0
	_player_chose_fight = false
	add_to_group("sister_ally")
	remove_from_group("enemy")
	_enter_state("chase")


# ---------------------------------------------------------------------------
# State overrides for combat mode
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
	if not _player_chose_fight and not is_in_group("sister_ally"):
		return  # No chasing during non-combat phases

	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	navigation.target_position = _target.global_position
	var next_pos := navigation.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * move_speed
	_direction = dir

	if global_position.distance_to(_target.global_position) <= attack_range:
		_enter_state("engage")


func _state_engage(_delta: float) -> void:
	if not _player_chose_fight and not is_in_group("sister_ally"):
		return

	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	if _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		_enter_state("chase")
