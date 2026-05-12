extends Node

## GoreSystem — Manages blood effects, severed limbs, and gore visuals.
## Attached as autoload or child of game scene.

var blood_particles_scene: PackedScene
var limb_scene: PackedScene
var blood_pool_scene: PackedScene

var _active_pools: Array[Node2D] = []
var _active_limbs: Array[RigidBody2D] = []
var max_pools_per_room: int = 15
var max_limbs: int = 30


func _ready() -> void:
	# Load scenes (will be created later)
	# blood_particles_scene = preload("res://scenes/effects/blood_splash.tscn")
	# limb_scene = preload("res://scenes/effects/severed_limb.tscn")
	# blood_pool_scene = preload("res://scenes/effects/blood_pool.tscn")
	EventBus.room_entered.connect(_on_room_entered)


func _on_room_entered(_floor_number: int, _room_name: String) -> void:
	# Reset blood pools for new room
	for pool in _active_pools:
		if is_instance_valid(pool):
			pool.queue_free()
	_active_pools.clear()


func spawn_severed_limb(position: Vector2, limb_type: int, owner: CharacterBody2D) -> void:
	AudioManager.SFXPlayer.play_sfx_2d("limb_sever", position, 3.0)
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

	# Extra splash at sever point (bigger than regular hit)
	_spawn_placeholder_blood(position, Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized())


func spawn_blood_splash(position: Vector2, direction: Vector2) -> void:
	AudioManager.SFXPlayer.play_sfx_with_pitch("blood_splash", randf_range(0.7, 1.3))
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
	# Severed limb as RigidBody2D with proper physics
	var limb := RigidBody2D.new()
	limb.mass = 0.5
	limb.gravity_scale = 1.0

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	var vis := ColorRect.new()
	var stump := ColorRect.new()

	match limb_type:
		DamageZone.Zone.LEFT_ARM, DamageZone.Zone.RIGHT_ARM:
			rect_shape.size = Vector2(20, 6)
			vis.size = Vector2(20, 6)
			vis.color = Color(0.7, 0.2, 0.2)
			stump.size = Vector2(2, 3)
			stump.color = Color(0.545, 0.0, 0.0)  # #8B0000
			stump.position = Vector2(0, 3)
		DamageZone.Zone.LEFT_LEG, DamageZone.Zone.RIGHT_LEG:
			rect_shape.size = Vector2(6, 20)
			vis.size = Vector2(6, 20)
			vis.color = Color(0.6, 0.15, 0.15)
			stump.size = Vector2(2, 3)
			stump.color = Color(0.545, 0.0, 0.0)
			stump.position = Vector2(2, 17)
		DamageZone.Zone.HEAD:
			rect_shape.size = Vector2(12, 12)
			vis.size = Vector2(12, 12)
			vis.color = Color(0.7, 0.25, 0.2)
			stump.size = Vector2(2, 3)
			stump.color = Color(0.545, 0.0, 0.0)
			stump.position = Vector2(5, 12)

	shape.shape = rect_shape
	limb.add_child(shape)
	limb.add_child(vis)
	limb.add_child(stump)
	limb.global_position = position
	# Random initial velocity
	var impulse_dir := Vector2(randf_range(-1, 1), randf_range(-1, -0.3)).normalized()
	limb.apply_impulse(impulse_dir * randf_range(100, 200))
	limb.angular_velocity = randf_range(-5.0, 5.0)

	# Freeze after 1s (lands on ground)
	var freeze_timer := get_tree().create_timer(1.0, true, false, true)
	limb.set_meta("_freeze_timer", freeze_timer)
	freeze_timer.timeout.connect(func():
		if is_instance_valid(limb):
			limb.freeze = true
	)

	# Lifetime: 30s, then fadeout 1s
	limb.set_meta("despawn_time", 30.0)
	get_tree().create_timer(30.0, true, false, true).timeout.connect(func():
		if not is_instance_valid(limb):
			return
		var tween := limb.create_tween()
		tween.tween_property(limb, "modulate:a", 0.0, 1.0)
		tween.tween_callback(limb.queue_free)
	)

	get_tree().current_scene.add_child(limb)
	_active_limbs.append(limb)
	_cleanup_limbs()


func _spawn_placeholder_blood(position: Vector2, direction: Vector2) -> void:
	# Blood splash: 3-5 RigidBody2D droplets
	var count := randi_range(3, 5)
	for i in range(count):
		var drop := RigidBody2D.new()
		drop.gravity_scale = 1.0
		var vis := ColorRect.new()
		vis.size = Vector2(2, 2)
		var r_variation := randf_range(0.6, 1.0)
		vis.color = Color(r_variation, 0.0, 0.0)
		drop.add_child(vis)
		var drop_col := CollisionShape2D.new()
		var drop_shape := CircleShape2D.new()
		drop_shape.radius = 1.0
		drop_col.shape = drop_shape
		drop.add_child(drop_col)
		drop.global_position = position
		# Random velocity in a cone ±30° around direction
		var angle_offset := randf_range(-0.524, 0.524)  # ~±30°
		var drop_dir := direction.rotated(angle_offset)
		drop.linear_velocity = drop_dir * randf_range(50, 150)
		get_tree().current_scene.add_child(drop)
		# Freeze on contact with StaticBody2D, lifetime 5s
		drop.contact_monitor = true
		drop.body_entered.connect(func(body):
			if body is StaticBody2D or body is TileMapLayer:
				drop.freeze = true
		)
		get_tree().create_timer(5.0).timeout.connect(func():
			if not is_instance_valid(drop):
				return
			var tween := drop.create_tween()
			tween.tween_property(drop, "modulate:a", 0.0, 0.5)
			tween.tween_callback(drop.queue_free)
		)


func _spawn_placeholder_pool(position: Vector2) -> void:
	var pool := StaticBody2D.new()
	pool.collision_layer = 0
	pool.collision_mask = 0
	var vis := ColorRect.new()
	var size := randf_range(6, 16)
	vis.size = Vector2(size, size)
	vis.color = Color(0.353, 0.0, 0.0, 0.7)  # #5A0000 dark blood
	pool.add_child(vis)
	# Collision shape so characters step on it
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(size, size)
	col.shape = rect
	pool.add_child(col)
	# Organic offset
	pool.global_position = position + Vector2(randf_range(-4, 4), randf_range(-4, 4)) - vis.size / 2.0
	pool.z_index = -1
	get_tree().current_scene.add_child(pool)
	_active_pools.append(pool)
	_cleanup_pools()


func _cleanup_pools() -> void:
	while _active_pools.size() > max_pools_per_room:
		var oldest: Node2D = _active_pools.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	_active_pools = _active_pools.filter(func(p): return is_instance_valid(p))


func _cleanup_limbs() -> void:
	while _active_limbs.size() > max_limbs:
		var oldest: RigidBody2D = _active_limbs.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	_active_limbs = _active_limbs.filter(func(l): return is_instance_valid(l))


func clear_room_effects() -> void:
	# Blood pools are persistent — only clear limbs between rooms
	for limb in _active_limbs:
		if is_instance_valid(limb):
			limb.queue_free()
	_active_limbs.clear()


func clear_all_effects() -> void:
	for pool in _active_pools:
		if is_instance_valid(pool):
			pool.queue_free()
	_active_pools.clear()
	for limb in _active_limbs:
		if is_instance_valid(limb):
			limb.queue_free()
	_active_limbs.clear()
