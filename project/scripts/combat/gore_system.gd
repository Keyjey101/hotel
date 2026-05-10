extends Node

## GoreSystem — Manages blood effects, severed limbs, and gore visuals.
## Attached as autoload or child of game scene.

var blood_particles_scene: PackedScene
var limb_scene: PackedScene
var blood_pool_scene: PackedScene

var _active_pools: Array[Node2D] = []
var _active_limbs: Array[RigidBody2D] = []
var max_pools_per_room: int = 50
var max_limbs: int = 30


func _ready() -> void:
	# Load scenes (will be created later)
	# blood_particles_scene = preload("res://scenes/effects/blood_splash.tscn")
	# limb_scene = preload("res://scenes/effects/severed_limb.tscn")
	# blood_pool_scene = preload("res://scenes/effects/blood_pool.tscn")
	pass


func spawn_severed_limb(position: Vector2, limb_type: int, owner: CharacterBody2D) -> void:
	if not limb_scene:
		_create_placeholder_limb(position, limb_type, owner)
		return

	var limb: RigidBody2D = limb_scene.instantiate()
	limb.global_position = position
	limb.set_meta("limb_type", limb_type)
	limb.apply_impulse(Vector2(randf_range(-100, 100), randf_range(-200, -50)))

	get_tree().current_scene.add_child(limb)
	_active_limbs.append(limb)

	# Cleanup old limbs
	_cleanup_limbs()

	# Spawn blood at sever point
	spawn_blood_splash(position, Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized())

	# Spawn blood pool
	spawn_blood_pool(position)


func spawn_blood_splash(position: Vector2, direction: Vector2) -> void:
	# Placeholder until particle scene exists
	_spawn_placeholder_blood(position, direction)


func spawn_blood_pool(position: Vector2) -> void:
	if not blood_pool_scene:
		_spawn_placeholder_pool(position)
		return

	var pool: Node2D = blood_pool_scene.instantiate()
	pool.global_position = position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
	get_tree().current_scene.add_child(pool)
	_active_pools.append(pool)

	_cleanup_pools()


func _create_placeholder_limb(position: Vector2, limb_type: int, _owner: CharacterBody2D) -> void:
	# Simple colored rectangle as placeholder
	var limb := RigidBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	var vis := ColorRect.new()

	match limb_type:
		DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM:
			rect.size = Vector2(4, 12)
			vis.size = Vector2(4, 12)
			vis.color = Color(0.7, 0.2, 0.2)
		DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG:
			rect.size = Vector2(6, 14)
			vis.size = Vector2(6, 14)
			vis.color = Color(0.6, 0.15, 0.15)
		DamageZone.Zone.HEAD:
			rect.size = Vector2(6, 6)
			vis.size = Vector2(6, 6)
			vis.color = Color(0.7, 0.25, 0.2)

	shape.shape = rect
	limb.add_child(shape)
	limb.add_child(vis)
	limb.global_position = position
	limb.apply_impulse(Vector2(randf_range(-80, 80), randf_range(-150, -50)))

	# Auto-cleanup after 20 seconds
	limb.set_meta("despawn_time", 20.0)

	get_tree().current_scene.add_child(limb)
	_active_limbs.append(limb)
	_cleanup_limbs()


func _spawn_placeholder_blood(position: Vector2, _direction: Vector2) -> void:
	# Simple blood dots as placeholder
	for i in range(5):
		var dot := ColorRect.new()
		dot.size = Vector2(2, 2)
		dot.color = Color(0.8, 0.1, 0.1)
		dot.global_position = position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		get_tree().current_scene.add_child(dot)
		# Fade and remove
		var tween := dot.create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(dot.queue_free)


func _spawn_placeholder_pool(position: Vector2) -> void:
	var pool := ColorRect.new()
	var size := randf_range(6, 14)
	pool.size = Vector2(size, size)
	pool.color = Color(0.5, 0.05, 0.05, 0.7)
	pool.global_position = position - pool.size / 2.0
	pool.z_index = -1
	get_tree().current_scene.add_child(pool)
	_active_pools.append(pool)
	_cleanup_pools()


func _cleanup_pools() -> void:
	while _active_pools.size() > max_pools_per_room:
		var oldest := _active_pools.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()


func _cleanup_limbs() -> void:
	while _active_limbs.size() > max_limbs:
		var oldest := _active_limbs.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()


func clear_room_effects() -> void:
	for pool in _active_pools:
		if is_instance_valid(pool):
			pool.queue_free()
	_active_pools.clear()
	for limb in _active_limbs:
		if is_instance_valid(limb):
			limb.queue_free()
	_active_limbs.clear()
