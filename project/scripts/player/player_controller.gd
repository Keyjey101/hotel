extends CharacterBody2D

## Player — Main player controller.
## Handles movement, aiming, combat input, HP, and weapon management.

@onready var sprite: Sprite2D = %Sprite
@onready var weapon_manager: Node2D = %WeaponManager
@onready var hurtbox: Area2D = %Hurtbox
@onready var pickup_area: Area2D = %PickupArea
@onready var anim_player: AnimationPlayer = %AnimPlayer

@export_group("Movement")
@export var base_speed: float = 200.0

var _current_speed: float = 200.0
var _facing: Vector2 = Vector2.DOWN
var _aim_direction: Vector2 = Vector2.DOWN
var _is_attacking: bool = false
var _attack_cooldown: float = 0.0
var _attack_end_timer: SceneTreeTimer = null
var _is_hurt: bool = false
var _hurt_timer: float = 0.0
var _is_dead: bool = false
var _invulnerable: bool = false
var _invul_timer: float = 0.0
var _camera: Camera2D = null
var _pause_menu_instance: Node = null
var _knockback_velocity: Vector2 = Vector2.ZERO
var _flash_tween: Tween = null
var _slow_count: int = 0
var _active_slows: Array[Dictionary] = []  # [{id: int, mult: float}]
var _slow_id_counter: int = 0
var _hazard_slow_count: int = 0
var _hazard_slow_mult: float = 1.0
var _active_hazard_slows: Array[float] = []
var _regen_hp_timer: float = 0.0


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	if hurtbox:
		if not hurtbox.area_entered.is_connected(_on_hurtbox_hit):
			hurtbox.area_entered.connect(_on_hurtbox_hit)
	else:
		push_error("PlayerController: Hurtbox not found!")
	_current_speed = base_speed
	if GameManager.run_state:
		_current_speed = GameManager.run_state.player_speed


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	var rs := GameManager.run_state

	# Cooldowns
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	if _hurt_timer > 0.0:
		_hurt_timer -= delta
		if _hurt_timer <= 0.0:
			_is_hurt = false
	if _invulnerable:
		_invul_timer -= delta
		if _invul_timer <= 0.0:
			_invulnerable = false

	# Bloodlust decay
	if rs:
		if rs.bloodlust_timer > 0.0:
			rs.bloodlust_timer -= delta
			if rs.bloodlust_timer <= 0.0:
				rs.bloodlust_stacks = 0

	# Second Wind regen
	_check_second_wind_regen(delta)

	# HP regen from upgrades
	if rs and rs.player_hp > 0.0:
		var hp_regen := float(rs.stat_upgrades.get("hp_regen", 0.0))
		var hp_regen_low := float(rs.stat_upgrades.get("hp_regen_low", 0.0))
		if hp_regen > 0.0:
			rs.player_hp = minf(rs.player_hp + hp_regen * delta, rs.player_max_hp)
		elif hp_regen_low > 0.0 and rs.player_hp < rs.player_max_hp * 0.3:
			rs.player_hp = minf(rs.player_hp + hp_regen_low * delta, rs.player_max_hp * 0.3)

	# Movement
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	if input_dir.length_squared() > 0.01:
		input_dir = input_dir.normalized()
		_aim_direction = input_dir

	var effective_speed := _current_speed * _hazard_slow_mult
	velocity = input_dir * effective_speed + _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)

	move_and_slide()
	_update_sprite_facing()


func _unhandled_input(event: InputEvent) -> void:
	if _is_dead:
		return

	if event.is_action_pressed("attack"):
		if _attack_cooldown <= 0.0:
			_attack()
	elif event.is_action_pressed("interact"):
		_try_pickup()
	elif event.is_action_pressed("switch_weapon"):
		if weapon_manager:
			weapon_manager.switch_slot()
	elif event.is_action_pressed("throw_weapon"):
		if weapon_manager:
			weapon_manager.throw_active_weapon(_aim_direction)
	elif event.is_action_pressed("pause"):
		_show_pause_menu()


# ---------------------------------------------------------------------------
# Damage / Healing
# ---------------------------------------------------------------------------

func receive_damage(damage: float, _zone: int, _sever: bool = false,
		knockback_force: float = 0.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	take_damage(damage, knockback_dir, knockback_force)


func take_damage(damage: float, knockback_dir: Vector2 = Vector2.ZERO,
		knockback_force: float = 0.0) -> void:
	if _is_dead or _invulnerable:
		return

	if GameManager.run_state:
		# Apply damage reduction
		var dmg_reduction := float(GameManager.run_state.stat_upgrades.get("damage_reduction", 0.0))
		damage = maxf(damage - dmg_reduction, 0.0)

		GameManager.run_state.player_hp -= damage
		if GameManager.run_state.player_hp <= 0.0:
			# Try Second Wind before dying
			if not _try_second_wind():
				_on_hurtbox_hit_take_damage(knockback_dir, knockback_force)
				_die()
				return
	else:
		_die()
		return

	_on_hurtbox_hit_take_damage(knockback_dir, knockback_force)


func _on_hurtbox_hit_take_damage(knockback_dir: Vector2, knockback_force: float) -> void:
	_is_hurt = true
	_hurt_timer = 0.3
	_invulnerable = true
	_invul_timer = 0.5
	if knockback_force > 0.0:
		_knockback_velocity = knockback_dir * knockback_force * 3.0
	_flash_white()
	if AudioManager and AudioManager.SFXPlayer: AudioManager.SFXPlayer.play_sfx("player_hurt")
	if ScreenEffects: ScreenEffects.flash(Color(1.0, 0.0, 0.0, 0.3), 0.05, 0.2)


func heal(amount: float) -> void:
	if GameManager.run_state:
		GameManager.run_state.heal(amount)


func apply_hazard_slow(mult: float) -> void:
	if mult not in _active_hazard_slows:
		_active_hazard_slows.append(mult)
	_apply_worst_hazard_slow()


func remove_hazard_slow(mult: float) -> void:
	_active_hazard_slows.erase(mult)
	_apply_worst_hazard_slow()


func _apply_worst_hazard_slow() -> void:
	if _active_hazard_slows.is_empty():
		_hazard_slow_mult = 1.0
	else:
		_hazard_slow_mult = _active_hazard_slows.min()


func apply_stun(duration: float) -> void:
	_invulnerable = true
	_invul_timer = maxf(_invul_timer, duration)


func apply_slow(mult: float, duration: float) -> void:
	var slow_id := _slow_id_counter
	_slow_id_counter += 1
	_active_slows.append({"id": slow_id, "mult": mult})
	_update_slow_speed()
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(self):
			for i in range(_active_slows.size()):
				if _active_slows[i]["id"] == slow_id:
					_active_slows.remove_at(i)
					break
			_update_slow_speed()
	)


func get_hp() -> float:
	if GameManager.run_state:
		return GameManager.run_state.player_hp
	return 100.0


func get_max_hp() -> float:
	if GameManager.run_state:
		return GameManager.run_state.player_max_hp
	return 100.0


func _update_slow_speed() -> void:
	if _active_slows.is_empty():
		_current_speed = GameManager.run_state.player_speed if GameManager.run_state else base_speed
	else:
		var min_mult := _active_slows[0]["mult"]
		for s in _active_slows:
			min_mult = minf(min_mult, s["mult"])
		_current_speed = (GameManager.run_state.player_speed if GameManager.run_state else base_speed) * min_mult


# ---------------------------------------------------------------------------
# S9 Second Wind — prevent first death, heal to 30%
# ---------------------------------------------------------------------------

func _try_second_wind() -> bool:
	if GameManager.run_state == null:
		return false
	if GameManager.run_state.second_wind_used:
		return false
	var stacks := GameManager.run_state.get_stack_count("s9_second_wind")
	if stacks == 0:
		return false
	# Check if disabled by Pact of Flesh
	if GameManager.run_state.has_artifact("a8_pact_of_flesh"):
		return false

	GameManager.run_state.second_wind_used = true
	# Heal to 30% of max HP
	var heal_amount := GameManager.run_state.player_max_hp * 0.30
	GameManager.run_state.player_hp = heal_amount
	# 2 seconds invulnerability
	_invulnerable = true
	_invul_timer = 2.0
	# Visual feedback
	if ScreenEffects: ScreenEffects.flash(Color(0.8, 0.9, 1.0), 0.1, 0.5)
	print("[Player] Second Wind activated! Healed to %.0f HP" % heal_amount)
	return true


func _check_second_wind_regen(delta: float) -> void:
	if GameManager.run_state == null:
		return
	var stacks := GameManager.run_state.get_stack_count("s9_second_wind")
	if stacks == 0:
		return
	# Check if disabled by Pact of Flesh
	if GameManager.run_state.has_artifact("a8_pact_of_flesh"):
		return
	var threshold := GameManager.run_state.player_max_hp * 0.30
	if GameManager.run_state.player_hp < threshold and GameManager.run_state.player_hp > 0.0:
		var heal_rate := 1.0 * stacks
		GameManager.run_state.player_hp = minf(
			GameManager.run_state.player_hp + heal_rate * delta,
			threshold  # Capped at 30%
		)


# ---------------------------------------------------------------------------
# S11 Bloodlust — +damage buff on kill, stacking, decaying
# ---------------------------------------------------------------------------

func _on_enemy_killed_bloodlust(_enemy: CharacterBody2D) -> void:
	if GameManager.run_state == null:
		return
	var stacks := GameManager.run_state.get_stack_count("s11_bloodlust")
	if stacks == 0:
		return
	GameManager.run_state.bloodlust_stacks = mini(GameManager.run_state.bloodlust_stacks + 1, 3)
	GameManager.run_state.bloodlust_timer = 3.0


func get_bloodlust_damage_mult() -> float:
	if GameManager.run_state == null:
		return 1.0
	if GameManager.run_state.bloodlust_timer <= 0.0:
		return 1.0
	var effective_stacks := mini(GameManager.run_state.bloodlust_stacks, 3)
	if effective_stacks <= 0:
		return 1.0
	var bonus := 0.0
	for i in range(effective_stacks):
		if i < 2:
			bonus += 0.10
		else:
			bonus += 0.05  # 50% of 0.10
	return 1.0 + bonus


# ---------------------------------------------------------------------------
# Attack / Combat
# ---------------------------------------------------------------------------

func _attack() -> void:
	var weapon: WeaponData = weapon_manager.get_active_weapon()
	if weapon == null:
		return

	_is_attacking = true
	_attack_cooldown = weapon.attack_speed

	if weapon.weapon_type == WeaponData.WeaponType.MELEE or weapon.weapon_type == WeaponData.WeaponType.IMPROVISED:
		weapon_manager.melee_attack(weapon, _aim_direction)
	elif weapon.weapon_type == WeaponData.WeaponType.RANGED:
		weapon_manager.ranged_attack(weapon, _aim_direction)

	# End attack after brief delay — cancel previous timer if any
	if _attack_end_timer != null and is_instance_valid(_attack_end_timer):
		_attack_end_timer.timeout.disconnect(_on_attack_end)
	_attack_end_timer = get_tree().create_timer(weapon.attack_speed)
	_attack_end_timer.timeout.connect(func():
		if is_instance_valid(self):
			_on_attack_end()
	)


func _on_attack_end() -> void:
	_is_attacking = false


func _try_pickup() -> void:
	var bodies := pickup_area.get_overlapping_bodies()
	var closest: Node2D = null
	var closest_dist: float = INF

	for body in bodies:
		if body.has_method("get_weapon_data"):
			var dist := global_position.distance_to(body.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = body

	if closest:
		var weapon: WeaponData = closest.get_weapon_data()
		if weapon == null:
			return
		weapon_manager.equip_weapon(weapon)
		closest.queue_free()
		EventBus.weapon_picked_up.emit(weapon)


func _die() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	if AudioManager and AudioManager.SFXPlayer: AudioManager.SFXPlayer.play_sfx("player_death", 5.0)
	# Trigger capture sequence after brief delay
	get_tree().create_timer(0.5).timeout.connect(func():
		GameManager.handle_player_death()
	)


func _flash_white() -> void:
	if sprite == null:
		return
	sprite.modulate = Color.WHITE
	if _flash_tween:
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	_flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


enum AnimRow { IDLE = 0, WALK = 1, ATTACK = 2, THROW = 3, HURT = 4 }

var _current_anim: int = AnimRow.IDLE
var _frame_size := Vector2(24, 36)  # Per-frame size in the spritesheet


func _update_sprite_facing() -> void:
	if sprite == null:
		return
	# Determine direction column from aim
	var col := 0  # right
	if abs(_aim_direction.x) > abs(_aim_direction.y):
		col = 0 if _aim_direction.x >= 0 else 1
	else:
		col = 2 if _aim_direction.y >= 0 else 3  # down, up
	# Update animation row based on state
	if _is_attacking:
		_current_anim = AnimRow.ATTACK
	elif _is_hurt:
		_current_anim = AnimRow.HURT
	elif velocity.length_squared() > 100.0:
		_current_anim = AnimRow.WALK
	else:
		_current_anim = AnimRow.IDLE
	sprite.region_enabled = true
	sprite.region_rect = Rect2(col * _frame_size.x, _current_anim * _frame_size.y, _frame_size.x, _frame_size.y)
	sprite.flip_h = false


func _on_hurtbox_hit(hit_area: Area2D) -> void:
	# Incoming hit from enemy hitbox
	if not hit_area.is_in_group("enemy_hitbox"):
		return

	var damage: float = 15.0  # Default damage
	var _dir_to_enemy: Vector2 = global_position.direction_to(hit_area.global_position)
	var knockback_force: float = 100.0

	# Walk up the tree to find the enemy node (hitbox may be nested in HurtboxManager)
	var node: Node = hit_area
	var enemy: Node2D = null
	while node != null:
		if node.is_in_group("enemy"):
			enemy = node as Node2D
			break
		node = node.get_parent()
	if enemy and enemy.has_method("get_attack_damage"):
		damage = enemy.get_attack_damage()

	take_damage(damage, -_dir_to_enemy, knockback_force)


func _on_weapon_changed(slot: int, _weapon: Resource) -> void:
	# Visual update for weapon slots
	pass


const PauseMenuScene := preload("res://scenes/ui/pause_menu.tscn")

func _show_pause_menu() -> void:
	if _pause_menu_instance != null and is_instance_valid(_pause_menu_instance):
		return
	_pause_menu_instance = PauseMenuScene.instantiate()
	var cs := get_tree().current_scene
	if cs:
		cs.add_child(_pause_menu_instance)
	else:
		_pause_menu_instance.queue_free()
