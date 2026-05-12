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


func _ready() -> void:
	_current_speed = base_speed
	if GameManager.run_state:
		_current_speed = GameManager.run_state.player_speed
	_connect_signals()
	# Find camera in "camera" group for follow
	var cameras := get_tree().get_nodes_in_group("camera")
	for cam in cameras:
		if cam is Camera2D:
			_camera = cam
			break
	# Connect bloodlust tracking
	EventBus.enemy_disabled.connect(_on_enemy_killed_bloodlust)


func _exit_tree() -> void:
	if EventBus and EventBus.enemy_disabled.is_connected(_on_enemy_killed_bloodlust):
		EventBus.enemy_disabled.disconnect(_on_enemy_killed_bloodlust)


func _connect_signals() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_hit)
	EventBus.player_weapon_changed.connect(_on_weapon_changed)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# Timers
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_hurt_timer = maxf(0.0, _hurt_timer - delta)
	if _hurt_timer <= 0.0:
		_is_hurt = false
	_invul_timer = maxf(0.0, _invul_timer - delta)
	if _invul_timer <= 0.0:
		_invulnerable = false

	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * _current_speed + _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
	move_and_slide()

	# Facing / Aim
	var aim_delta := get_global_mouse_position() - global_position
	_aim_direction = aim_delta.normalized() if aim_delta.length_squared() > 0.0001 else _facing
	if input_dir != Vector2.ZERO:
		_facing = input_dir.normalized()

	# Attack
	if Input.is_action_pressed("attack") and _attack_cooldown <= 0.0 and not _is_attacking:
		_attack()
	# Throw
	if Input.is_action_just_pressed("throw_weapon") and not _is_attacking:
		weapon_manager.throw_active_weapon(_aim_direction)
	# Switch weapon
	if Input.is_action_just_pressed("switch_weapon"):
		weapon_manager.switch_slot()
	# Pickup
	if Input.is_action_just_pressed("interact"):
		_try_pickup()

	# Update visual facing
	_update_sprite_facing()

	# Camera follow
	if _camera and is_instance_valid(_camera):
		_camera.global_position = global_position

	# Pause input
	if Input.is_action_just_pressed("ui_pause"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			GameManager.pause_game()
			_show_pause_menu()

	# S9 Second Wind: passive regen when HP < 30%
	_check_second_wind_regen(delta)

	# S11 Bloodlust: decay timer
	if GameManager.run_state:
		if GameManager.run_state.bloodlust_timer > 0.0:
			GameManager.run_state.bloodlust_timer -= delta
			if GameManager.run_state.bloodlust_timer <= 0.0:
				GameManager.run_state.bloodlust_stacks = 0


func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knockback_force: float = 0.0) -> void:
	if _invulnerable or _is_dead:
		return

	if GameManager.run_state:
		# Apply damage reduction from upgrades
		var reduction: float = float(GameManager.run_state.stat_upgrades.get("damage_reduction", 0.0))
		# Apply damage_taken_mult from artifacts (e.g. Crown of Thorns)
		var taken_mult: float = 1.0 + float(GameManager.run_state.stat_upgrades.get("damage_taken_mult", 0.0))
		amount *= (1.0 - reduction) * taken_mult
		GameManager.run_state.player_hp = maxf(GameManager.run_state.player_hp - amount, 0.0)
	else:
		amount = 0.0

	_is_hurt = true
	_hurt_timer = 0.2
	_invulnerable = true
	_invul_timer = 0.5

	AudioManager.SFXPlayer.play_sfx_with_pitch("player_hurt", randf_range(0.85, 1.15))

	# Knockback
	if knockback_force > 0.0:
		_knockback_velocity = knockback_dir * knockback_force * 5.0

	# Flash
	_flash_white()

	# Screen effects
	ScreenEffects.shake(5.0, 0.2)
	ScreenEffects.flash(Color.WHITE, 0.05, 0.4)
	ScreenEffects.update_vignette(get_hp() / get_max_hp())

	# Damage direction indicator on HUD
	if knockback_force > 0.0:
		var _hud := get_tree().get_first_node_in_group("hud")
		if _hud and _hud.has_method("flash_damage_direction"):
			_hud.flash_damage_direction(knockback_dir)

	EventBus.player_damaged.emit(amount)

	# Check death
	if GameManager.run_state and GameManager.run_state.player_hp <= 0.0:
		GameManager.run_state.player_hp = 0.0
		# S9 Second Wind: prevent first death, heal to 30%
		if _try_second_wind():
			return
		_die()


func heal(amount: float) -> void:
	if _is_dead:
		return
	if GameManager.run_state:
		GameManager.run_state.player_hp = minf(
			GameManager.run_state.player_hp + amount,
			GameManager.run_state.player_max_hp
		)
	EventBus.player_healed.emit(amount)
	ScreenEffects.update_vignette(get_hp() / get_max_hp())
	AudioManager.SFXPlayer.play_sfx("player_heal")


func get_hp() -> float:
	if GameManager.run_state:
		return GameManager.run_state.player_hp
	return 100.0


func get_max_hp() -> float:
	if GameManager.run_state:
		return GameManager.run_state.player_max_hp
	return 100.0


func apply_slow(mult: float, duration: float) -> void:
	_current_speed = base_speed * mult
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if is_instance_valid(self):
			_current_speed = GameManager.run_state.player_speed if GameManager.run_state else base_speed
	)


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
	ScreenEffects.flash(Color(0.8, 0.9, 1.0), 0.1, 0.5)
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
	GameManager.run_state.bloodlust_stacks = mini(stacks, 3)
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
	_attack_end_timer.timeout.connect(_on_attack_end)


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
		weapon_manager.equip_weapon(weapon)
		closest.queue_free()
		EventBus.weapon_picked_up.emit(weapon)


func _die() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	AudioManager.SFXPlayer.play_sfx("playerDeath", 5.0)
	# Trigger capture sequence after brief delay
	get_tree().create_timer(0.5).timeout.connect(func():
		GameManager.handle_player_death()
	)


func _flash_white() -> void:
	sprite.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)


enum AnimRow { IDLE = 0, WALK = 1, ATTACK = 2, THROW = 3, HURT = 4 }

var _current_anim: int = AnimRow.IDLE
var _frame_size := Vector2(24, 36)  # Per-frame size in the spritesheet


func _update_sprite_facing() -> void:
	# Determine direction column from aim
	var col := 0  # right
	if abs(_aim_direction.x) > abs(_aim_direction.y):
		col = 0 if _aim_direction.x >= 0 else 1
	else:
		col = 2 if _aim_direction.y >= 0 else 3  # down, up
	# Update animation row based on state
	if _is_attacking:
		_current_anim = AnimRow.THROW
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
	var knockback_dir: Vector2 = global_position.direction_to(hit_area.global_position)
	var knockback_force: float = 100.0

	# Try to get damage from the enemy
	var enemy = hit_area.get_parent()
	if enemy and enemy.has_method("get_attack_damage"):
		damage = enemy.get_attack_damage()

	take_damage(damage, -knockback_dir, knockback_force)


func _on_weapon_changed(slot: int, _weapon: Resource) -> void:
	# Visual update for weapon slots
	pass


func _show_pause_menu() -> void:
	if _pause_menu_instance != null and is_instance_valid(_pause_menu_instance):
		return
	var pause_scene := preload("res://scenes/ui/pause_menu.tscn")
	_pause_menu_instance = pause_scene.instantiate()
	var cs := get_tree().current_scene
	if cs:
		cs.add_child(_pause_menu_instance)
