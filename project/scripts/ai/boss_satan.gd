extends "res://scripts/ai/base_enemy.gd"

## BossSatan — Floor 9 final boss.
## 3 phases: The Interview (400HP) → The Audit (500HP) → Bankruptcy (600HP).
## Reality warping, time slow, weapon steal, shrinking arena.
## Human in a perfect suit — the horror is normalcy.

# ── Phase tracking ──
var _phase: int = 1
var _phase_hp_thresholds: Array[float] = [1.0, 0.0, 0.0]  # Set in _ready
var _max_phase_hp: float = 400.0
var _phase_2_start_hp: float = 0.0

# Phase HP pools (simplified: single HP bar, phase transitions at thresholds)
var _phase_1_hp: float = 400.0
var _phase_2_hp: float = 500.0
var _phase_3_hp: float = 600.0

# ── Cooldowns ──
var _handshake_cooldown: float = 0.0
var _contract_cooldown: float = 0.0
var _dismiss_cooldown: float = 0.0
var _summon_cooldown: float = 0.0
var _warp_cooldown: float = 0.0
var _time_slow_cooldown: float = 0.0
var _steal_cooldown: float = 0.0
var _liquidation_cooldown: float = 0.0
var _void_touch_cooldown: float = 0.0
var _collapse_cooldown: float = 0.0
var _market_crash_cooldown: float = 0.0
var _dialogue_timer: float = 8.0

# ── Weapon theft ──
var _stolen_weapon = null
var _stealing: bool = false
var _steal_timer: float = 0.0

# ── Arena hazard zones ──
var _liquidation_zones: Array[HazardZone] = []
var _safe_zone: CollisionShape2D = null
var _collapse_active: bool = false
var _collapse_radius: float = 200.0

# ── Final offer ──
var _final_offer_shown: bool = false
var _offer_state: String = ""
var _offer_timer: float = 0.0
var _rng := RandomNumberGenerator.new()
var _final_choice_made: bool = false
var _dialogue_label: Label = null

# ── Sister ally ──
var _sister_ally: CharacterBody2D = null

# ── Demon scene ──
var _demon_scene: PackedScene = null

# ── Phase 1 dialogue pool ──
var _p1_dialogue: Array[String] = [
	"Your sister made the right choice.",
	"Immortality isn't free. Someone has to pay.",
	"You're doing exactly what I expected.",
]

# ── Phase 2 dialogue pool ──
var _p2_dialogue: Array[String] = [
	"You think this is about GOOD and EVIL?",
	"It's about PROFIT.",
	"EVERYTHING has a cost.",
]

# ── Phase 3 dialogue pool ──
var _p3_dialogue: Array[String] = [
	"You cannot afford to walk away.",
	"THE MARKET NEVER CLOSES.",
	"I own your debt. I own YOU.",
]


func _ready() -> void:
	enemy_name = "Satan"
	enemy_type = "boss"

	# Start at Phase 1 stats — total HP is sum of all phases
	torso_hp = _phase_1_hp + _phase_2_hp + _phase_3_hp
	head_hp = 80.0
	arm_hp = 60.0
	leg_hp = 60.0
	move_speed = 120.0
	detection_range = 500.0
	attack_range = 50.0
	attack_damage = 20.0
	attack_speed = 0.8
	grab_strength = 0.0
	regen_speed_mult = 1.0
	aggression = 5.0
	coordination = 5.0

	_max_phase_hp = torso_hp  # Total: 1500

	add_to_group("boss")

	# Pre-load demon scene
	if ResourceLoader.exists("res://scenes/enemies/demon.tscn"):
		_demon_scene = load("res://scenes/enemies/demon.tscn")

	# Check if Sister was spared — spawn as ally
	if GameManager.run_state and GameManager.run_state.run_meta.get("sister_spared", false):
		_spawn_sister_ally()

	_rng.seed = hash("satan") + (GameManager.seed_manager.get_seed() if GameManager.seed_manager else 0)

	super._ready()


# ---------------------------------------------------------------------------
# Physics
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

	# Steal animation lock
	if _stealing:
		_steal_timer -= delta
		if _steal_timer <= 0.0:
			_execute_steal()
		velocity = Vector2.ZERO
		move_and_slide()
		_process_regen(delta)
		return

	# Tick cooldowns
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_state_timer -= delta
	_handshake_cooldown = maxf(0.0, _handshake_cooldown - delta)
	_contract_cooldown = maxf(0.0, _contract_cooldown - delta)
	_dismiss_cooldown = maxf(0.0, _dismiss_cooldown - delta)
	_summon_cooldown = maxf(0.0, _summon_cooldown - delta)
	_warp_cooldown = maxf(0.0, _warp_cooldown - delta)
	_time_slow_cooldown = maxf(0.0, _time_slow_cooldown - delta)
	_steal_cooldown = maxf(0.0, _steal_cooldown - delta)
	_liquidation_cooldown = maxf(0.0, _liquidation_cooldown - delta)
	_void_touch_cooldown = maxf(0.0, _void_touch_cooldown - delta)
	_collapse_cooldown = maxf(0.0, _collapse_cooldown - delta)
	_market_crash_cooldown = maxf(0.0, _market_crash_cooldown - delta)
	_dialogue_timer -= delta

	# Update phase
	_update_phase()

	# Phase-specific behaviors
	_process_phase_behaviors(delta)

	# Process offer state machine
	if _offer_state != "":
		_process_offer_state(delta)

	# Normal state processing
	_process_state(delta)
	_process_regen(delta)

	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 500.0 * delta)
	velocity += _knockback_vel

	move_and_slide()


# ---------------------------------------------------------------------------
# Phase management
# ---------------------------------------------------------------------------

func _update_phase() -> void:
	var current_hp := limb_health[DamageZone.Zone.TORSO]
	var denominator := _max_phase_hp
	if _phase >= 2 and _phase_2_start_hp > 0.0:
		denominator = _phase_2_start_hp
	var hp_pct := current_hp / denominator
	var new_phase: int
	if hp_pct > 0.66:
		new_phase = 1
	elif hp_pct > 0.33:
		new_phase = 2
	else:
		new_phase = 3
	if new_phase != _phase:
		_phase = new_phase
		_on_phase_changed()


func _on_phase_changed() -> void:
	match _phase:
		2:
			move_speed = 150.0
			regen_speed_mult = 1.5
			_phase_2_start_hp = limb_health[DamageZone.Zone.TORSO]
			sprite.modulate = Color(0.1, 0.1, 0.1, 1.0)
		3:
			move_speed = 180.0
			regen_speed_mult = 2.0
			sprite.modulate = Color(0.04, 0.04, 0.04, 1.0)


func _process_phase_behaviors(delta: float) -> void:
	match _phase:
		1:
			_process_phase_1(delta)
		2:
			_process_phase_2(delta)
		3:
			_process_phase_3(delta)

	# Dialogue between attacks
	if _dialogue_timer <= 0.0:
		_show_random_dialogue()
		_dialogue_timer = 8.0

	# Final offer at 10% HP
	var hp := limb_health[DamageZone.Zone.TORSO]
	var total_hp := _phase_1_hp + _phase_2_hp + _phase_3_hp
	if hp <= total_hp * 0.1 and not _final_offer_shown and _phase == 3:
		_show_final_offer()


# ---------------------------------------------------------------------------
# Phase 1 — "The Interview"
# ---------------------------------------------------------------------------

func _process_phase_1(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)

	# Handshake trap
	if dist < 60.0 and _handshake_cooldown <= 0.0:
		_handshake()
		_handshake_cooldown = 8.0
		return

	# Contract throw
	if _contract_cooldown <= 0.0 and dist > 80.0:
		_throw_contract()
		_contract_cooldown = 6.0
		return

	# Dismiss (knockback wave)
	if _dismiss_cooldown <= 0.0 and dist < 120.0:
		_dismiss()
		_dismiss_cooldown = 10.0
		return

	# Summon Demon
	if _summon_cooldown <= 0.0:
		_summon_demon(1)
		_summon_cooldown = 20.0


func _handshake() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var dist := global_position.distance_to(_target.global_position)
	if dist < 30.0:
		# Grab and drain
		if _target.has_method("receive_damage"):
			_target.receive_damage(30.0, DamageZone.Zone.TORSO, false)


func _throw_contract() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dir := global_position.direction_to(_target.global_position)
	var bolt := Area2D.new()
	bolt.name = "ContractBolt"
	bolt.add_to_group("enemy_hitbox")

	var shape := CircleShape2D.new()
	shape.radius = 8.0
	var col := CollisionShape2D.new()
	col.shape = shape
	bolt.add_child(col)

	var visual := ColorRect.new()
	visual.size = Vector2(10, 6)
	visual.position = Vector2(-5, -3)
	visual.color = Color(0.95, 0.95, 0.85)  # Paper white
	bolt.add_child(visual)

	bolt.global_position = global_position
	bolt.set_meta("direction", dir)
	bolt.set_meta("speed", 250.0)
	bolt.set_meta("damage", 20.0)
	bolt.set_meta("source", self)
	bolt.set_meta("applies_fine_print", true)

	if get_tree().current_scene:
		get_tree().current_scene.add_child(bolt)
	_move_projectile(bolt)


func _dismiss() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	# Radial knockback pulse
	var dir := global_position.direction_to(_target.global_position)
	if _target.has_method("receive_damage"):
		_target.receive_damage(15.0, DamageZone.Zone.TORSO, false, 200.0, dir * -1.0)


func _summon_demon(count: int) -> void:
	if _demon_scene == null:
		return
	for i in range(count):
		var demon := _demon_scene.instantiate() as CharacterBody2D
		if demon == null:
			continue
		demon.global_position = global_position + Vector2(_rng.randf_range(-80, 80), _rng.randf_range(-80, 80))
		get_tree().current_scene.add_child(demon)


# ---------------------------------------------------------------------------
# Phase 2 — "The Audit"
# ---------------------------------------------------------------------------

func _process_phase_2(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)

	# Reality warp — move obstacle nodes
	if _warp_cooldown <= 0.0:
		_reality_warp()
		_warp_cooldown = 10.0

	# Time slow for player
	if _time_slow_cooldown <= 0.0:
		_fiscal_year()
		_time_slow_cooldown = 15.0

	# Weapon steal
	if _steal_cooldown <= 0.0 and _stolen_weapon == null:
		_attempt_steal()
		_steal_cooldown = 12.0

	# Liquidation — floor damage zones
	if _liquidation_cooldown <= 0.0:
		_liquidation()
		_liquidation_cooldown = 8.0

	# Summon 2 Demons
	if _summon_cooldown <= 0.0:
		_summon_demon(2)
		_summon_cooldown = 25.0


func _reality_warp() -> void:
	# Move obstacle nodes in the scene (tween positions)
	var obstacles := get_tree().get_nodes_in_group("obstacle")
	for obs in obstacles:
		if is_instance_valid(obs) and obs is Node2D:
			var tween := obs.create_tween()
			var new_pos := Vector2(_rng.randf_range(50, 500), _rng.randf_range(50, 400))
			tween.tween_property(obs, "position", new_pos, 1.0)


func _fiscal_year() -> void:
	if _target == null or not is_instance_valid(_target):
		return
	if _target.has_method("apply_slow"):
		_target.apply_slow(0.5, 3.0)


func _attempt_steal() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > 40.0:
		return

	_stealing = true
	_steal_timer = 0.8


func _execute_steal() -> void:
	_stealing = false
	if _target == null or not is_instance_valid(_target):
		return

	var wm = _target.get("weapon_manager")
	if wm == null:
		return

	var equipped = wm.get("equipped")
	if equipped == null:
		return

	var active_slot: int = wm.get("active_slot", 0)
	var weapon = equipped[active_slot]
	if weapon == null:
		var other := 0 if active_slot == 1 else 1
		weapon = equipped[other]
		if weapon == null:
			return

	_stolen_weapon = weapon
	equipped[active_slot] = null
	_steal_cooldown = 15.0


func _use_stolen_weapon() -> void:
	if _stolen_weapon == null or _target == null or not is_instance_valid(_target):
		return

	var damage: float = 20.0
	if _stolen_weapon.get("damage") != null:
		damage = float(_stolen_weapon.get("damage"))

	var dir := global_position.direction_to(_target.global_position)
	if _target.has_method("receive_damage"):
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 30.0, dir * -1.0)


func _liquidation() -> void:
	# Create 2 damage zones (telegraphed 1s warning, then 20 dmg/s)
	for i in range(2):
		var pos := Vector2(_rng.randf_range(60, 500), _rng.randf_range(60, 400))

		# Warning flash
		var warning := ColorRect.new()
		warning.size = Vector2(80, 80)
		warning.position = pos - Vector2(40, 40)
		warning.color = Color(1.0, 0.0, 0.0, 0.3)
		warning.z_index = -1
		get_tree().current_scene.add_child(warning)

		# Activate hazard after 1s warning
		get_tree().create_timer(1.0).timeout.connect(func():
			if is_instance_valid(warning):
				warning.queue_free()
			var hz: HazardZone
			if ResourceLoader.exists("res://scenes/combat/hazard_zone.tscn"):
				hz = load("res://scenes/combat/hazard_zone.tscn").instantiate()
			else:
				hz = HazardZone.new()
			hz.damage_per_second = 20.0
			hz.slow_factor = 1.0
			hz.duration = 5.0
			hz.zone_color = Color(0.5, 0.0, 0.0, 0.4)
			hz.zone_radius = 40.0
			hz.global_position = pos
			if get_tree().current_scene:
				get_tree().current_scene.add_child(hz)
			_liquidation_zones.append(hz)
		)


# ---------------------------------------------------------------------------
# Phase 3 — "Bankruptcy"
# ---------------------------------------------------------------------------

func _process_phase_3(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return

	# Void touch
	if _void_touch_cooldown <= 0.0:
		_void_touch()
		_void_touch_cooldown = 6.0

	# Economic collapse — shrinking safe zone
	if not _collapse_active and _collapse_cooldown <= 0.0:
		_start_economic_collapse()
		_collapse_cooldown = 20.0

	# Market crash — projectiles from all directions
	if _market_crash_cooldown <= 0.0:
		_market_crash()
		_market_crash_cooldown = 12.0


func _void_touch() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var dist := global_position.distance_to(_target.global_position)
	if dist > 60.0:
		return

	# 50 damage + desecrate (no heal for 5s)
	if _target.has_method("receive_damage"):
		_target.receive_damage(50.0, DamageZone.Zone.TORSO, false)

	# Disable player healing for 5s via meta flag
	_target.set_meta("desecrated", true)
	var _desecrate_target := _target
	get_tree().create_timer(5.0).timeout.connect(func():
		if is_instance_valid(_desecrate_target):
			_desecrate_target.set_meta("desecrated", false)
	)


func _start_economic_collapse() -> void:
	_collapse_active = true
	_collapse_radius = 200.0

	# Shrink safe zone over 10 seconds
	var tween := create_tween()
	tween.tween_property(self, "_collapse_radius", 50.0, 10.0)
	tween.tween_callback(func(): _collapse_active = false)


func _market_crash() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	# 8 projectiles in a circle around player, fly toward center
	var center := _target.global_position
	var count := 8
	var radius := 150.0

	for i in range(count):
		var angle := (TAU * i) / count
		var start_pos := center + Vector2(cos(angle), sin(angle)) * radius

		var bolt := Area2D.new()
		bolt.name = "MarketCrashBolt"
		bolt.add_to_group("enemy_hitbox")

		var shape := CircleShape2D.new()
		shape.radius = 5.0
		var col := CollisionShape2D.new()
		col.shape = shape
		bolt.add_child(col)

		var visual := ColorRect.new()
		visual.size = Vector2(6, 6)
		visual.position = Vector2(-3, -3)
		visual.color = Color(1.0, 0.0, 0.0)
		bolt.add_child(visual)

		bolt.global_position = start_pos
		var dir := start_pos.direction_to(center)
		bolt.set_meta("direction", dir)
		bolt.set_meta("speed", 180.0)
		bolt.set_meta("damage", 15.0)
		bolt.set_meta("source", self)

		if get_tree().current_scene:
			get_tree().current_scene.add_child(bolt)
		_move_projectile(bolt)


# ---------------------------------------------------------------------------
# Projectile system
# ---------------------------------------------------------------------------

func _move_projectile(bolt: Area2D) -> void:
	var speed: float = bolt.get_meta("speed", 250.0)
	var damage: float = bolt.get_meta("damage", 20.0)
	var lifetime := 4.0
	var elapsed := 0.0

	while is_instance_valid(bolt) and elapsed < lifetime:
		await get_tree().physics_frame
		if not is_instance_valid(bolt):
			return
		if not is_instance_valid(self):
			if is_instance_valid(bolt):
				bolt.queue_free()
			return
		var frame_delta: float = get_physics_process_delta_time()
		elapsed += frame_delta

		var dir: Vector2 = bolt.get_meta("direction", Vector2.RIGHT)
		# Homing for contracts
		if bolt.get_meta("applies_fine_print", false):
			if _target and is_instance_valid(_target):
				dir = bolt.global_position.direction_to(_target.global_position)
				bolt.set_meta("direction", dir)

		bolt.global_position += dir * speed * frame_delta

		var bodies := bolt.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player") and body.has_method("receive_damage"):
				body.receive_damage(damage, DamageZone.Zone.TORSO, false)
				# Fine print: speed reduction
				if bolt.get_meta("applies_fine_print", false):
					if body.has_method("apply_slow"):
						body.apply_slow(0.85, 5.0)
				if is_instance_valid(bolt):
					bolt.queue_free()
				return

	if is_instance_valid(bolt):
		bolt.queue_free()


# ---------------------------------------------------------------------------
# Final offer at 10% HP
# ---------------------------------------------------------------------------

func _show_final_offer() -> void:
	_final_offer_shown = true
	velocity = Vector2.ZERO
	_offer_state = "showing_text"
	_offer_timer = 3.0
	_show_dialogue_text("Join the board. End this.", 3.0)


func _on_accept_deal() -> void:
	# Ending D variant
	GameManager.trigger_ending("d")


func _on_reject_deal() -> void:
	# Continue fighting
	_show_dialogue_text("Disappointing.", 1.0)


func _process_offer_state(delta: float) -> void:
	match _offer_state:
		"showing_text":
			_offer_timer -= delta
			if _offer_timer <= 0.0:
				_offer_state = "showing_dialog"
				var dialog_scene := preload("res://scenes/ui/dialog_choice.tscn")
				var dialog := dialog_scene.instantiate()
				dialog.setup("Join the board. End this.", "[1] ACCEPT", "[2] REJECT", "accept", "reject")
				dialog.z_index = 100
				get_tree().current_scene.add_child(dialog)
				if not EventBus.dialog_choice_made.is_connected(_on_dialog_choice):
					EventBus.dialog_choice_made.connect(_on_dialog_choice)
		"showing_dialog":
			pass  # Waiting for signal


func _on_dialog_choice(choice: String) -> void:
	if EventBus.dialog_choice_made.is_connected(_on_dialog_choice):
		EventBus.dialog_choice_made.disconnect(_on_dialog_choice)
	_offer_state = ""
	match choice:
		"accept":
			_on_accept_deal()
		"reject":
			_on_reject_deal()


# ---------------------------------------------------------------------------
# Dialogue system
# ---------------------------------------------------------------------------

func _show_random_dialogue() -> void:
	var pool: Array[String] = _p1_dialogue if _phase == 1 else _p2_dialogue if _phase == 2 else _p3_dialogue
	var text := pool[_rng.randi() % pool.size()]
	_show_dialogue_text(text, 2.5)


func _show_dialogue_text(text: String, duration: float) -> void:
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

	var tween := create_tween()
	tween.tween_property(_dialogue_label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(_dialogue_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		if is_instance_valid(_dialogue_label):
			_dialogue_label.queue_free()
			_dialogue_label = null
	)


# ---------------------------------------------------------------------------
# Sister ally
# ---------------------------------------------------------------------------

func _spawn_sister_ally() -> void:
	if not ResourceLoader.exists("res://scenes/bosses/boss_sister.tscn"):
		return

	var scene := load("res://scenes/bosses/boss_sister.tscn")
	var ally := scene.instantiate() as CharacterBody2D
	if ally == null:
		return

	ally.global_position = global_position + Vector2(-80, 0)
	get_tree().current_scene.add_child(ally)

	# Configure as ally
	if ally.has_method("become_ally"):
		ally.become_ally()
		# Set target to Satan (self)
		ally.set("_target", self)
		_sister_ally = ally


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_chase(delta: float) -> void:
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
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	if _stolen_weapon != null and _attack_cooldown <= 0.0:
		_use_stolen_weapon()
		_attack_cooldown = attack_speed * 1.5
	elif _attack_cooldown <= 0.0:
		_perform_attack()
		_attack_cooldown = attack_speed

	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		_enter_state("chase")


func _perform_attack() -> void:
	if _target == null or not is_instance_valid(_target):
		return

	var damage := attack_damage
	if _phase >= 3:
		damage = 35.0

	if _target.has_method("receive_damage"):
		var dir := global_position.direction_to(_target.global_position)
		_target.receive_damage(damage, DamageZone.Zone.TORSO, false, 25.0, dir * -1.0)


# ---------------------------------------------------------------------------
# Damage override
# ---------------------------------------------------------------------------

func receive_damage(damage: float, zone: int, sever: bool, knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	# Damage flash: void reveals through skin
	sprite.modulate = Color(0.04, 0.04, 0.04)
	var restore_color := Color(0.1, 0.1, 0.1, 1.0) if _phase >= 2 else Color.WHITE
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", restore_color, 0.15)

	# Drop stolen weapon on hit
	if _stolen_weapon != null and _rng.randf() < 0.5:
		# Check if damage likely from player (has knockback)
		if knockback_force > 0.0:
			if _stolen_weapon is Resource:
				EventBus.weapon_dropped.emit(_stolen_weapon)
			_stolen_weapon = null

	super.receive_damage(damage, zone, sever, knockback_force, knockback_dir)


# ---------------------------------------------------------------------------
# Death override
# ---------------------------------------------------------------------------

func _disable_enemy() -> void:
	# Reality collapse — screen flash white → black
	var overlay := ColorRect.new()
	overlay.size = Vector2(640, 360)
	overlay.color = Color.WHITE
	overlay.z_index = 200
	get_tree().current_scene.add_child(overlay)

	var tween := overlay.create_tween()
	tween.tween_property(overlay, "color", Color.BLACK, 1.0)
	tween.tween_callback(func():
		if is_instance_valid(overlay):
			overlay.queue_free()
	)

	# Clean up
	if _dialogue_label and is_instance_valid(_dialogue_label):
		_dialogue_label.queue_free()
	if _sister_ally and is_instance_valid(_sister_ally):
		_sister_ally.queue_free()

	if EventBus.dialog_choice_made.is_connected(_on_dialog_choice):
		EventBus.dialog_choice_made.disconnect(_on_dialog_choice)

	# Determine ending
	EventBus.mini_boss_defeated.emit(9)
	# Let floor_manager handle ending via signal chain

	super._disable_enemy()


func _exit_tree() -> void:
	if EventBus.dialog_choice_made.is_connected(_on_dialog_choice):
		EventBus.dialog_choice_made.disconnect(_on_dialog_choice)


# ---------------------------------------------------------------------------
# Visual
# ---------------------------------------------------------------------------

func _flash_hurt() -> void:
	# Override: void flash instead of red
	sprite.modulate = Color(0.04, 0.04, 0.04, 1.0)
	var tween := create_tween()
	var base_color := Color(0.1, 0.1, 0.1, 1.0) if _phase >= 2 else Color.WHITE
	tween.tween_property(sprite, "modulate", base_color, 0.15)
