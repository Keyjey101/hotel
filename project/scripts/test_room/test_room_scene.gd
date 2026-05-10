extends Node2D

## TestRoom — Combat prototype test room.
## Contains a player, enemies, weapons on ground, and navigation.
## Press T to spawn enemy, R to reset, K to kill all enemies (debug).

@onready var player: CharacterBody2D = %Player
@onready var nav_region: NavigationRegion2D = %NavigationRegion

var _enemy_scene: PackedScene
var _spawn_count: int = 0


func _ready() -> void:
	_enemy_scene = load("res://scenes/enemies/base_enemy.tscn")
	_setup_run()
	_spawn_initial_enemies()
	print("[TestRoom] Ready. WASD=move, LMB=attack, RMB=throw, E=pickup, Q=switch")
	print("[TestRoom] T=spawn enemy, R=reset, K=kill all (debug)")


func _setup_run() -> void:
	GameManager.start_new_run()
	# Give player starting weapons
	var machete := load("res://resources/weapons/melee_machete.tres") as WeaponData
	var sawed_off := load("res://resources/weapons/ranged_sawed_off.tres") as WeaponData
	GameManager.run_state.weapon_slots[0] = machete
	GameManager.run_state.weapon_slots[1] = sawed_off
	GameManager.run_state._ammo = [0, 4]


func _spawn_initial_enemies() -> void:
	_spawn_enemy(Vector2(200, 100))
	_spawn_enemy(Vector2(400, 200))
	_spawn_enemy(Vector2(150, 250))


func _spawn_enemy(pos: Vector2) -> void:
	if not _enemy_scene:
		return
	var enemy := _enemy_scene.instantiate()
	enemy.global_position = pos
	enemy.set_patrol_points([
		pos + Vector2(-50, 0),
		pos + Vector2(50, 0),
	])
	add_child(enemy)
	_spawn_count += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		# T = spawn enemy (reuse pause key for debug)
		_spawn_enemy(player.global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100)))
	elif event is InputEventKey:
		if event.keycode == KEY_R and event.pressed:
			_reset_room()
		elif event.keycode == KEY_K and event.pressed:
			_kill_all_enemies()
		elif event.keycode == KEY_H and event.pressed:
			player.heal(25.0)
			print("[Debug] Healed 25 HP. Current: %.0f" % player.get_hp())


func _reset_room() -> void:
	# Remove all enemies
	for child in get_children():
		if child.is_in_group("enemy"):
			child.queue_free()
	_spawn_count = 0
	_setup_run()
	player.global_position = Vector2(320, 180)
	GameManager.run_state.player_hp = 100.0
	_spawn_initial_enemies()
	print("[TestRoom] Reset complete.")


func _kill_all_enemies() -> void:
	for child in get_children():
		if child.is_in_group("enemy"):
			child.receive_damage(9999.0, DamageZone.Zone.TORSO, false, 0.0, Vector2.ZERO)
	print("[TestRoom] All enemies disabled.")
