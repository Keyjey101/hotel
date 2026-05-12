extends "res://scripts/ai/base_enemy.gd"

## Chef enemy — throws oil slicks and hot pans, heavy cleaver melee.
## Design doc: 11_ENEMY_DESIGN.md section 3.2

# Ability cooldowns
var _oil_cooldown: float = 0.0
var _pan_cooldown: float = 0.0

# Wind-up state machine (avoids async/await in state chain)
var _windup_type: String = ""  # "", "oil", "pan", "cleaver"
var _windup_timer: float = 0.0
var _windup_target_pos: Vector2 = Vector2.ZERO

# Pan projectile tracking
var _active_pan_projectiles: Array[Dictionary] = []

# Mutilation state
var _arms_lost: int = 0


func _ready() -> void:
	enemy_name = "Chef"
	enemy_type = "chef"

	torso_hp = 75.0
	head_hp = 25.0
	arm_hp = 22.0
	leg_hp = 20.0
	move_speed = 95.0
	detection_range = 180.0
	attack_range = 50.0
	attack_damage = 35.0
	attack_speed = 0.9
	grab_strength = 4.0
	regen_speed_mult = 1.0
	aggression = 7.0
	coordination = 5.0

	add_to_group("chefs")
	super._ready()
	_create_chef_hat()


func _create_chef_hat() -> void:
	var hat := ColorRect.new()
	hat.size = Vector2(16, 8)
	hat.color = Color.WHITE
	hat.position = Vector2(-8, -25)
	hat.z_index = 1
	sprite.add_child(hat)


func _physics_process(delta: float) -> void:
	_tick_ability_cooldowns(delta)
	_process_windup(delta)
	_process_pan_projectiles(delta)
	super._physics_process(delta)


func _tick_ability_cooldowns(delta: float) -> void:
	if _oil_cooldown > 0.0:
		_oil_cooldown -= delta
	if _pan_cooldown > 0.0:
		_pan_cooldown -= delta


# ---------------------------------------------------------------------------
# Wind-up state machine — replaces async await with timer-based approach
# ---------------------------------------------------------------------------

func _process_windup(delta: float) -> void:
	if _windup_type == "":
		return

	_windup_timer -= delta
	if _windup_timer > 0.0:
		return

	# Wind-up complete — execute the action
	match _windup_type:
		"oil":
			if not _disabled and not _stunned:
				_throw_oil(_windup_target_pos)
			_oil_cooldown = randf_range(8.0, 12.0)
		"pan":
			if not _disabled and not _stunned:
				_spawn_pan_projectile(_windup_target_pos)
			_pan_cooldown = randf_range(10.0, 15.0)
		"cleaver":
			if not _disabled and not _stunned and _target != null and is_instance_valid(_target):
				_execute_cleaver_hit()

	_windup_type = ""
	sprite.modulate = Color.WHITE


func _start_windup(type: String, duration: float, target_pos: Vector2) -> void:
	_windup_type = type
	_windup_timer = duration
	_windup_target_pos = target_pos
	_telegraph_flash()


# ---------------------------------------------------------------------------
# State overrides
# ---------------------------------------------------------------------------

func _state_engage(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_enter_state("patrol")
		return

	velocity = Vector2.ZERO
	_direction = global_position.direction_to(_target.global_position)

	# Busy winding up — don't start new actions
	if _windup_type != "":
		return

	# Oil slick: every 8-12s
	if _oil_cooldown <= 0.0 and _arms_lost < 2:
		if _arms_lost == 1 and randf() > 0.5:
			_oil_cooldown = randf_range(3.0, 5.0)  # Failed throw
		else:
			_start_windup("oil", 0.4, _target.global_position)
			return

	# Pan toss: every 10-15s, within 80px
	if _pan_cooldown <= 0.0 and _arms_lost < 2:
		if global_position.distance_to(_target.global_position) <= 80.0:
			_start_windup("pan", 0.5, _target.global_position)
			return

	# Default: cleaver chop melee
	if _attack_cooldown <= 0.0:
		_start_windup("cleaver", 0.4, _target.global_position)
		_attack_cooldown = 1.0 / attack_speed
		return

	# Check if target moved out of range
	if global_position.distance_to(_target.global_position) > attack_range * 1.5:
		_enter_state("chase")


# ---------------------------------------------------------------------------
# Cleaver Chop — execute after windup
# ---------------------------------------------------------------------------

func _execute_cleaver_hit() -> void:
	var area := Area2D.new()
	area.collision_layer = 4
	area.collision_mask = 1

	var shape := CircleShape2D.new()
	shape.radius = attack_range
	var col := CollisionShape2D.new()
	col.shape = shape
	area.add_child(col)

	area.global_position = global_position + _direction * attack_range * 0.5
	get_tree().current_scene.add_child(area)

	area.body_entered.connect(func(body: Node2D) -> void:
		if body.is_in_group("player") and body.has_method("receive_damage"):
			body.receive_damage(attack_damage, DamageZone.Zone.TORSO, false, 25.0, _direction)
	)

	get_tree().create_timer(0.2).timeout.connect(area.queue_free)


func _perform_attack() -> void:
	# Fallback — normally handled via windup in _state_engage
	if _windup_type != "":
		return
	if _attack_cooldown > 0.0:
		return
	_start_windup("cleaver", 0.4, _target.global_position if _target else global_position)
	_attack_cooldown = 1.0 / attack_speed


# ---------------------------------------------------------------------------
# Oil Slick
# ---------------------------------------------------------------------------

func _throw_oil(target_pos: Vector2) -> void:
	var hazard_scene: PackedScene = load("res://scenes/combat/hazard_zone.tscn")
	if hazard_scene == null:
		return
	var zone: Area2D = hazard_scene.instantiate()

	zone.damage_per_second = 0.0
	zone.slow_factor = 0.3
	zone.duration = 5.0
	zone.zone_color = Color(0.227, 0.227, 0.0)
	zone.zone_radius = 64.0
	zone.global_position = target_pos

	get_tree().current_scene.add_child(zone)


# ---------------------------------------------------------------------------
# Pan Toss
# ---------------------------------------------------------------------------

func _spawn_pan_projectile(target_pos: Vector2) -> void:
	var dir := global_position.direction_to(target_pos)

	var pan := Node2D.new()
	pan.global_position = global_position + dir * 15.0

	var hit_area := Area2D.new()
	hit_area.collision_layer = 4
	hit_area.collision_mask = 1
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	col.shape = shape
	hit_area.add_child(col)
	pan.add_child(hit_area)

	var visual := ColorRect.new()
	visual.size = Vector2(12, 12)
	visual.position = Vector2(-6, -6)
	visual.color = Color(0.6, 0.6, 0.6)
	pan.add_child(visual)

	get_tree().current_scene.add_child(pan)

	_active_pan_projectiles.append({
		"node": pan,
		"hit_area": hit_area,
		"dir": dir,
		"speed": 250.0,
		"elapsed": 0.0,
		"max_time": 2.0,
		"damage": 20.0,
	})


func _process_pan_projectiles(delta: float) -> void:
	var to_remove: Array[int] = []

	for i in range(_active_pan_projectiles.size()):
		var p: Dictionary = _active_pan_projectiles[i]
		var node: Node2D = p["node"]

		if not is_instance_valid(node):
			to_remove.append(i)
			continue

		p["elapsed"] = float(p["elapsed"]) + delta

		if float(p["elapsed"]) >= float(p["max_time"]):
			_pan_impact(node.global_position)
			node.queue_free()
			to_remove.append(i)
			continue

		var dir: Vector2 = p["dir"]
		var speed: float = float(p["speed"])
		node.global_position += dir * speed * delta

		var hit_area: Area2D = p["hit_area"]
		if is_instance_valid(hit_area):
			var bodies := hit_area.get_overlapping_bodies()
			var hit := false
			for body in bodies:
				if body.is_in_group("player"):
					hit = true
					if body.has_method("receive_damage"):
						body.receive_damage(float(p["damage"]), DamageZone.Zone.TORSO, false, 10.0, dir)
					break

			if not hit:
				for body in bodies:
					if not body.is_in_group("player") and not body.is_in_group("enemy"):
						hit = true
						break

			if hit:
				_pan_impact(node.global_position)
				node.queue_free()
				to_remove.append(i)

	for i in to_remove:
		if i < _active_pan_projectiles.size():
			_active_pan_projectiles.remove_at(i)


func _pan_impact(pos: Vector2) -> void:
	var hazard_scene: PackedScene = load("res://scenes/combat/hazard_zone.tscn")
	if hazard_scene == null:
		return
	var zone: Area2D = hazard_scene.instantiate()

	zone.damage_per_second = 5.0
	zone.slow_factor = 1.0
	zone.duration = 3.0
	zone.zone_color = Color(1.0, 0.3, 0.0)
	zone.zone_radius = 48.0
	zone.global_position = pos

	get_tree().current_scene.add_child(zone)


# ---------------------------------------------------------------------------
# Mutilation
# ---------------------------------------------------------------------------

func _on_limb_lost(zone: int) -> void:
	super._on_limb_lost(zone)

	if DamageZone.is_arm(zone):
		_arms_lost = int(severed_limbs[DamageZone.Zone.LEFT_ARM]) + \
				int(severed_limbs[DamageZone.Zone.RIGHT_ARM])

		if _arms_lost >= 2:
			attack_damage = 5.0


func _evaluate_mutilated_behavior() -> void:
	if _arms_lost >= 2:
		if aggression >= 7.0:
			_enter_state("engage")
		else:
			_enter_state("retreat")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _telegraph_flash() -> void:
	if sprite:
		sprite.modulate = Color(1.5, 1.0, 0.3)


func get_enemy_type() -> String:
	return enemy_type
