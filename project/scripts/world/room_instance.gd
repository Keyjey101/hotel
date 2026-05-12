class_name RoomInstance
extends Node2D

## RoomInstance — Base room template for Floor 1 layout.
## TDD reference: 02_TDD.md section 5.2

signal player_entered(room: RoomInstance)
signal player_exited(room: RoomInstance)
signal room_cleared(room: RoomInstance)

@export var room_id: String = ""
@export var room_bounds: Rect2 = Rect2(0, 0, 640, 480)
@export var room_type: String = "chamber"  # corridor/chamber/storage/gallery/service/trap/hub/boss

var spawn_points: Array[Marker2D] = []
var loot_zones: Array[Marker2D] = []
var doors: Array[Area2D] = []
var active_enemies: Array[CharacterBody2D] = []
var is_active: bool = false
var is_cleared: bool = false


func _ready() -> void:
	# Gather spawn points from children
	for child in get_children():
		if child is Marker2D:
			if child.is_in_group("spawn_points"):
				spawn_points.append(child)
			elif child.is_in_group("loot_zones"):
				loot_zones.append(child)
	# Gather from containers
	_collect_from_container("SpawnPoints", spawn_points, "spawn_points")
	_collect_from_container("LootZones", loot_zones, "loot_zones")
	_collect_from_container("Doors", doors, "doors")

	# Connect door signals
	for door in doors:
		if door is Area2D:
			door.body_entered.connect(_on_door_body_entered.bind(door))


func _collect_from_container(container_name: String, arr: Array, group_name: String) -> void:
	var container := find_child(container_name, false, false)
	if container == null:
		return
	for child in container.get_children():
		if child is Marker2D and group_name in ["spawn_points", "loot_zones"]:
			arr.append(child)
		elif child is Area2D and group_name == "doors":
			arr.append(child)
			child.add_to_group("doors")


# ---------------------------------------------------------------------------
# Activation / Deactivation
# ---------------------------------------------------------------------------

func activate() -> void:
	is_active = true
	set_process(true)
	AudioManager.SFXPlayer.play_sfx("door_open")
	# Update camera bounds
	var cameras := get_tree().get_nodes_in_group("camera")
	for cam in cameras:
		if cam.has_method("set_limits"):
			cam.set_limits(room_bounds)
	# Unfreeze enemies
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.process_mode = Node.PROCESS_MODE_INHERIT
	player_entered.emit(self)
	EventBus.room_entered.emit(GameManager.current_floor, room_id)


func deactivate() -> void:
	is_active = false
	AudioManager.SFXPlayer.play_sfx("door_close")
	# Freeze enemies — do NOT delete
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
	player_exited.emit(self)


# ---------------------------------------------------------------------------
# Spawning
# ---------------------------------------------------------------------------

func get_spawn_points_for_seed(seed_value: int) -> Array[Marker2D]:
	if spawn_points.is_empty():
		return []
	if GameManager.seed_manager == null:
		return spawn_points
	var config := GameManager.seed_manager.get_room_enemy_config(
		GameManager.current_floor, seed_value, spawn_points.size()
	)
	var result: Array[Marker2D] = []
	for idx in config.get("active_points", []):
		if idx < spawn_points.size():
			result.append(spawn_points[idx])
	return result


func add_enemy(enemy_scene: PackedScene, position: Vector2) -> CharacterBody2D:
	if active_enemies.size() >= 10:
		push_warning("RoomInstance: max 10 active_enemies reached")
		return null
	var enemy := enemy_scene.instantiate() as CharacterBody2D
	if enemy == null:
		return null
	var enemies_container := find_child("Enemies", false, false)
	if enemies_container != null:
		enemies_container.add_child(enemy)
	else:
		add_child(enemy)
	enemy.global_position = position
	active_enemies.append(enemy)
	return enemy


func check_cleared() -> bool:
	if is_cleared:
		return true
	for enemy in active_enemies:
		if is_instance_valid(enemy) and not enemy._disabled:
			return false
	is_cleared = true
	room_cleared.emit(self)
	EventBus.room_cleared.emit(GameManager.current_floor, room_id)
	return true


# ---------------------------------------------------------------------------
# Door transitions
# ---------------------------------------------------------------------------

func _on_door_body_entered(body: Node2D, door: Area2D) -> void:
	if not body.is_in_group("player"):
		return
	# FloorManager handles transitions via metadata
	var target_room: String = door.get_meta("target_room_id", "")
	if not target_room.is_empty():
		var fm := _find_floor_manager()
		if fm != null:
			fm.transition_to_room(target_room)
		return
	# Legacy: direct path-based connection
	var connected_path: String = door.get_meta("connected_room_path", "")
	if connected_path.is_empty():
		return
	deactivate()
	var connected := get_node_or_null(connected_path) as RoomInstance
	if connected != null:
		connected.activate()


# ---------------------------------------------------------------------------
# Programmatic room creation from RoomConfig (M3.2)
# ---------------------------------------------------------------------------

var _enemies_spawned: bool = false


func setup_from_config(config: RoomConfig) -> void:
	room_id = config.room_id
	room_type = config.room_type
	room_bounds = Rect2(Vector2.ZERO, config.size_px)
	name = "Room_%s" % config.room_id

	_create_floor(config.size_px, config.floor_color)
	_create_walls(config.size_px, config.wall_color)
	_create_navigation(config.size_px)
	_create_spawn_points(config.spawn_point_positions)
	_create_loot_zones(config.loot_zone_positions)
	_create_doors_from_config(config.door_positions)
	_create_enemies_container()


func _create_floor(size_px: Vector2, color: Color) -> void:
	var floor_rect := ColorRect.new()
	floor_rect.name = "FloorVisual"
	floor_rect.color = color
	floor_rect.size = size_px
	add_child(floor_rect)


func _create_walls(size_px: Vector2, color: Color) -> void:
	var wall_thickness := 16.0
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	walls.collision_layer = 128  # environment layer (bit 7)
	walls.collision_mask = 0

	# Wall visuals
	var wall_visual := ColorRect.new()
	wall_visual.name = "WallVisual"
	wall_visual.color = color
	wall_visual.size = size_px
	walls.add_child(wall_visual)

	# Top wall
	var shape_top := RectangleShape2D.new()
	shape_top.size = Vector2(size_px.x, wall_thickness)
	var col_top := CollisionShape2D.new()
	col_top.name = "WallTop"
	col_top.position = Vector2(size_px.x * 0.5, 0.0)
	col_top.shape = shape_top
	walls.add_child(col_top)

	# Bottom wall
	var shape_bottom := RectangleShape2D.new()
	shape_bottom.size = Vector2(size_px.x, wall_thickness)
	var col_bottom := CollisionShape2D.new()
	col_bottom.name = "WallBottom"
	col_bottom.position = Vector2(size_px.x * 0.5, size_px.y)
	col_bottom.shape = shape_bottom
	walls.add_child(col_bottom)

	# Left wall
	var shape_left := RectangleShape2D.new()
	shape_left.size = Vector2(wall_thickness, size_px.y)
	var col_left := CollisionShape2D.new()
	col_left.name = "WallLeft"
	col_left.position = Vector2(0.0, size_px.y * 0.5)
	col_left.shape = shape_left
	walls.add_child(col_left)

	# Right wall
	var shape_right := RectangleShape2D.new()
	shape_right.size = Vector2(wall_thickness, size_px.y)
	var col_right := CollisionShape2D.new()
	col_right.name = "WallRight"
	col_right.position = Vector2(size_px.x, size_px.y * 0.5)
	col_right.shape = shape_right
	walls.add_child(col_right)

	add_child(walls)


func _create_navigation(size_px: Vector2) -> void:
	var margin := 16.0
	var nav_poly := NavigationPolygon.new()
	var verts := PackedVector2Array([
		Vector2(margin, margin),
		Vector2(size_px.x - margin, margin),
		Vector2(size_px.x - margin, size_px.y - margin),
		Vector2(margin, size_px.y - margin),
	])
	nav_poly.vertices = verts
	nav_poly.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	var nav_region := NavigationRegion2D.new()
	nav_region.name = "NavigationRegion2D"
	nav_region.navigation_polygon = nav_poly
	add_child(nav_region)


func _create_spawn_points(positions: Array[Vector2]) -> void:
	var container := Node2D.new()
	container.name = "SpawnPoints"
	for i in range(positions.size()):
		var marker := Marker2D.new()
		marker.name = "SpawnPoint%d" % (i + 1)
		marker.position = positions[i]
		marker.add_to_group("spawn_points")
		container.add_child(marker)
	add_child(container)
	# Populate spawn_points array
	for child in container.get_children():
		spawn_points.append(child)


func _create_loot_zones(positions: Array[Vector2]) -> void:
	var container := Node2D.new()
	container.name = "LootZones"
	for i in range(positions.size()):
		var marker := Marker2D.new()
		marker.name = "LootZone%d" % (i + 1)
		marker.position = positions[i]
		marker.add_to_group("loot_zones")
		container.add_child(marker)
	add_child(container)
	for child in container.get_children():
		loot_zones.append(child)


func _create_doors_from_config(door_configs: Array[Dictionary]) -> void:
	var container := Node2D.new()
	container.name = "Doors"
	for i in range(door_configs.size()):
		var cfg: Dictionary = door_configs[i]
		var door_area := Area2D.new()
		door_area.name = "Door%d_%s" % [i, cfg.get("entry_side", "")]
		door_area.position = cfg["pos"]
		door_area.add_to_group("doors")
		door_area.set_meta("target_room_id", cfg["target_room"])
		door_area.set_meta("entry_side", cfg.get("entry_side", ""))

		var shape := RectangleShape2D.new()
		shape.size = Vector2(32, 48)
		var col := CollisionShape2D.new()
		col.shape = shape
		door_area.add_child(col)

		# Visual indicator
		var door_visual := ColorRect.new()
		door_visual.color = Color(0.8, 0.6, 0.2, 0.6)
		door_visual.size = Vector2(32, 48)
		door_visual.position = Vector2(-16, -24)
		door_area.add_child(door_visual)

		door_area.body_entered.connect(_on_door_body_entered.bind(door_area))
		container.add_child(door_area)
	add_child(container)
	for child in container.get_children():
		doors.append(child)


func _create_enemies_container() -> void:
	var enemies := Node2D.new()
	enemies.name = "Enemies"
	add_child(enemies)


func get_entry_position(entry_side: String) -> Vector2:
	# Return a position near the opposite side of the room for player spawn
	match entry_side:
		"top":
			return Vector2(room_bounds.size.x * 0.5, room_bounds.size.y - 48.0)
		"bottom":
			return Vector2(room_bounds.size.x * 0.5, 48.0)
		"left":
			return Vector2(room_bounds.size.x - 48.0, room_bounds.size.y * 0.5)
		"right":
			return Vector2(48.0, room_bounds.size.y * 0.5)
		_:
			return Vector2(room_bounds.size.x * 0.5, room_bounds.size.y * 0.5)


func _find_floor_manager() -> FloorManager:
	# Room may be nested under Rooms container → walk up
	var node := get_parent()
	while node != null:
		if node is FloorManager:
			return node
		node = node.get_parent()
	return null
