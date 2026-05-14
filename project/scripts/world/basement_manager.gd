class_name BasementManager
extends Node2D

## BasementManager — Basement escape logic.
## Layout from 19_BASEMENT_DESIGN.md: 7 rooms, weapon stripping, time pressure.

# Basement palette (19_BASEMENT_DESIGN.md section 2.2)
const WALL_COLOR := Color(0.102, 0.102, 0.102)  # #1A1A1A
const FLOOR_COLOR := Color(0.227, 0.227, 0.227)  # #3A3A3A
const PIPE_COLOR := Color(0.478, 0.227, 0.102)    # #7A3A1A
const LIGHT_COLOR := Color(0.667, 0.133, 0.133)   # #AA2222
const TILE_SIZE := 32

# Reference to enemy spawner constants (loaded at runtime to avoid parse-order issues)
static var _enemy_spawner_script: GDScript:
	get:
		if _enemy_spawner_script == null:
			_enemy_spawner_script = load("res://scripts/world/enemy_spawner.gd")
		return _enemy_spawner_script

var timer: float = 60.0
var reinforcements_spawned: bool = false
var heavy_reinforcements_spawned: bool = false
var source_floor: int = 1
var player_weapons_backup: Array = []
var allowed_weapon_id: String = ""
var enter_time: float = 0.0
var rooms: Dictionary = {}
var _rng: RandomNumberGenerator
var _basement_active: bool = false
var _basement_escaped: bool = false


func _ready() -> void:
	_build_layout()
	_rng = RandomNumberGenerator.new()
	if GameManager.seed_manager:
		_rng.seed = GameManager.seed_manager.get_seed() * 313


func _exit_tree() -> void:
	# Cleanup: disconnect player_died signal if still connected
	if GameManager.player_died.is_connected(_on_player_died):
		GameManager.player_died.disconnect(_on_player_died)


## Called when player enters basement from a specific floor.
func enter_basement(floor_number: int) -> void:
	_basement_active = true
	source_floor = floor_number
	timer = 60.0
	reinforcements_spawned = false
	heavy_reinforcements_spawned = false
	enter_time = Time.get_ticks_msec() / 1000.0

	# Strip weapons, keep 1 random melee
	_strip_weapons()

	# Spawn enemies based on floor scaling
	_spawn_basement_enemies(floor_number)

	# Connect player death signal
	if not GameManager.player_died.is_connected(_on_player_died):
		GameManager.player_died.connect(_on_player_died)

	# Position player at START room
	_position_player_at_start()

	print("[BasementManager] Entered basement from floor %d. Timer: %.0fs" % [floor_number, timer])


func _process(delta: float) -> void:
	if not _basement_active:
		return
	timer -= delta

	# 60s: reinforcements (2 extra enemies)
	if timer <= 0.0 and not reinforcements_spawned:
		reinforcements_spawned = true
		_spawn_reinforcements(2)
		print("[BasementManager] Reinforcements arrived!")

	# 90s total (-30s): heavy reinforcements (4 more enemies)
	if timer <= -30.0 and not heavy_reinforcements_spawned:
		heavy_reinforcements_spawned = true
		_spawn_reinforcements(4)
		print("[BasementManager] Heavy reinforcements!")

	# Audio cue placeholder: warn at 30s and 10s remaining
	if timer > 0.0:
		if timer <= 10.0:
			var _warned_second: int = int(ceil(timer))
			if not has_meta("_last_warned_sec") or get_meta("_last_warned_sec") != _warned_second:
				set_meta("_last_warned_sec", _warned_second)
				print("[BasementManager] WARNING: %.0f seconds remaining!" % timer)


## Player reached exit stairs.
func _on_exit_reached(_body: Node2D) -> void:
	if _basement_escaped:
		return
	if _body == null:
		return
	if not _body.is_in_group("player"):
		return

	_basement_escaped = true

	# Disconnect player_died signal — no longer needed after escape
	if GameManager.player_died.is_connected(_on_player_died):
		GameManager.player_died.disconnect(_on_player_died)

	# Restore player weapons
	_restore_weapons()

	# Check speed bonus (< 30s clear = bonus artifact)
	var clear_time := Time.get_ticks_msec() / 1000.0 - enter_time
	var fast_clear := clear_time < 30.0

	GameManager.handle_basement_success()

	if fast_clear:
		print("[BasementManager] Fast escape! (%.1fs) Bonus artifact earned." % clear_time)
		# Bonus: random cult artifact (applied by game_manager)
		var art := _random_bonus_artifact()
		if art and GameManager.run_state and not GameManager.run_state.has_artifact(art.resource_name):
			GameManager.run_state.add_artifact(art)

	# Transition back to source floor
	GameManager.transition_to_floor(source_floor)


## Player died in basement — run over.
func _on_player_died() -> void:
	GameManager.handle_basement_failure()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/game_over.tscn")


## Strip all weapons except 1 random melee. If no melee, give Knife.
func _strip_weapons() -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
	player_weapons_backup.clear()
	var rs: RunState = GameManager.run_state
	if rs == null:
		return

	# Backup all weapons
	for ws in rs.weapon_slots:
		player_weapons_backup.append(ws)

	# Find melee weapons
	var melee_weapons: Array = []
	for ws in rs.weapon_slots:
		if ws != null and ws is Resource:
			var wtype: String = ws.get("weapon_type", "")
			if wtype == "melee":
				melee_weapons.append(ws)

	# Keep 1 random melee or give Knife
	allowed_weapon_id = ""
	if melee_weapons.is_empty():
		# Give Knife (worst case backup)
		var knife_path := "res://resources/weapons/melee_knife.tres"
		if ResourceLoader.exists(knife_path):
			rs.weapon_slots[0] = load(knife_path)
			allowed_weapon_id = "knife"
		rs.weapon_slots[1] = null
	else:
		# Pick random melee (use seeded _rng)
		var idx := _rng.randi_range(0, melee_weapons.size() - 1)
		var kept = melee_weapons[idx]
		rs.weapon_slots[0] = kept
		allowed_weapon_id = kept.resource_name if kept is Resource else "melee"
		rs.weapon_slots[1] = null

	# Reset ammo
	# (ammo tracking is per-weapon in weapon_data; upgrades KEPT per design)

	print("[BasementManager] Weapons stripped. Kept: %s" % allowed_weapon_id)


## Restore player weapons after successful escape.
func _restore_weapons() -> void:
	var rs: RunState = GameManager.run_state
	if rs == null:
		return
	for i in range(mini(player_weapons_backup.size(), rs.weapon_slots.size())):
		rs.weapon_slots[i] = player_weapons_backup[i]


## Spawn basement enemies using scaling table (19_BASEMENT_DESIGN.md section 3.2).
func _spawn_basement_enemies(floor_number: int) -> void:
	var es: GDScript = _enemy_spawner_script
	var basement_scaling: Dictionary = es.BASEMENT_SCALING
	var scaling: Dictionary = basement_scaling.get(floor_number, basement_scaling[1])
	var enemy_range: Array = scaling["enemies"]
	var types: Array = scaling["types"]
	var hp_mult: float = scaling["hp"]
	var speed_mult: float = scaling["speed"]
	var enemy_scenes: Dictionary = es.ENEMY_SCENES

	# Use existing _rng from _ready (preserves determinism)

	var total_count := _rng.randi_range(enemy_range[0], enemy_range[1])

	# Distribute across rooms (skip Start room)
	var spawn_rooms: Array[String] = ["corridor_a", "room_a", "corridor_b", "room_b", "corridor_c", "exit_room"]
	var enemies_remaining := total_count

	for room_id in spawn_rooms:
		if enemies_remaining <= 0:
			break
		if not rooms.has(room_id):
			continue

		var room_data: Dictionary = rooms[room_id]
		var count := 0

		# Allocate enemies based on room capacity
		match room_id:
			"corridor_a", "corridor_b":
				count = mini(_rng.randi_range(1, 2), enemies_remaining)
			"room_a", "room_b":
				count = mini(_rng.randi_range(2, 3), enemies_remaining)
			"corridor_c":
				count = mini(_rng.randi_range(1, 2), enemies_remaining)
			"exit_room":
				count = 1

		enemies_remaining -= count

		# Spawn enemies
		var spawn_points: Array = room_data.get("spawn_points", [])
		for i in range(count):
			var enemy_type: String = types[_rng.randi_range(0, types.size() - 1)]
			var scene_path: String = enemy_scenes.get(enemy_type, "")
			if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
				continue

			var scene: PackedScene = load(scene_path)
			var enemy := scene.instantiate() as CharacterBody2D
			if enemy == null:
				continue

			# Position at spawn point or room center
			var pos: Vector2 = room_data.get("center", Vector2(80, 80))
			if i < spawn_points.size():
				pos = spawn_points[i]
			enemy.global_position = room_data.get("offset", Vector2.ZERO) + pos

			# Apply basement scaling
			es._apply_scaling(enemy, hp_mult, speed_mult)

			# Add to scene tree
			var room_node: Node2D = room_data.get("node", null)
			if room_node:
				room_node.add_child(enemy)
			else:
				add_child(enemy)


## Spawn reinforcement enemies at random positions.
func _spawn_reinforcements(count: int) -> void:
	var es: GDScript = _enemy_spawner_script
	var basement_scaling: Dictionary = es.BASEMENT_SCALING
	var scaling: Dictionary = basement_scaling.get(source_floor, basement_scaling[1])
	var types: Array = scaling["types"]
	var hp_mult: float = scaling["hp"]
	var speed_mult: float = scaling["speed"]
	var enemy_scenes: Dictionary = es.ENEMY_SCENES

	for i in range(count):
		var enemy_type: String = types[_rng.randi_range(0, types.size() - 1)]
		var scene_path: String = enemy_scenes.get(enemy_type, "")
		if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
			continue

		var scene: PackedScene = load(scene_path)
		var enemy := scene.instantiate() as CharacterBody2D
		if enemy == null:
			continue

		# Spawn near start room to create pressure from behind
		enemy.global_position = Vector2(48 + _rng.randf_range(-16, 16), 48 + _rng.randf_range(-16, 16))
		es._apply_scaling(enemy, hp_mult, speed_mult)
		add_child(enemy)


## Position player at START room center.
func _position_player_at_start() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	player.global_position = Vector2(48, 48)  # Center of 3×3 room (96×96 px)


## Generate a random bonus cult artifact from the registry.
func _random_bonus_artifact() -> Resource:
	if ArtifactRegistry:
		return ArtifactRegistry.get_random_artifact({1: 0.0, 2: 0.7, 3: 0.3}, _rng)
	# Fallback: create a simple Resource with artifact metadata
	var artifact := Resource.new()
	artifact.resource_name = "basement_bonus_artifact"
	artifact.set_meta("artifact_type", "cult_artifact")
	artifact.set_meta("source", "basement_fast_clear")
	return artifact


## Build the 7-room basement layout (19_BASEMENT_DESIGN.md section 2.1).
## Layout flow: Start → CorridorA → RoomA → CorridorB → RoomB → CorridorC → Exit
func _build_layout() -> void:
	var rooms_container := Node2D.new()
	rooms_container.name = "Rooms"
	add_child(rooms_container)

	# Room definitions: name, tile_size, pixel_size, offset_x, offset_y
	var room_defs: Array[Dictionary] = [
		{"id": "start_room", "name": "StartRoom", "tiles": Vector2i(3, 3), "offset": Vector2(0, 0)},
		{"id": "corridor_a", "name": "CorridorA", "tiles": Vector2i(6, 2), "offset": Vector2(0, 96)},
		{"id": "room_a", "name": "RoomA", "tiles": Vector2i(5, 4), "offset": Vector2(0, 160)},
		{"id": "corridor_b", "name": "CorridorB", "tiles": Vector2i(4, 2), "offset": Vector2(0, 288)},
		{"id": "room_b", "name": "RoomB", "tiles": Vector2i(5, 4), "offset": Vector2(0, 352)},
		{"id": "corridor_c", "name": "CorridorC", "tiles": Vector2i(4, 2), "offset": Vector2(0, 480)},
		{"id": "exit_room", "name": "ExitRoom", "tiles": Vector2i(2, 3), "offset": Vector2(0, 544)},
	]

	for rdef in room_defs:
		var room_node := _create_room(rdef)
		rooms_container.add_child(room_node)

		# Store room data for enemy spawning
		var spawn_pts: Array[Vector2] = _gen_basement_spawn_points(rdef["tiles"], rdef["id"])
		rooms[rdef["id"]] = {
			"node": room_node,
			"spawn_points": spawn_pts,
			"center": Vector2(rdef["tiles"].x * TILE_SIZE * 0.5, rdef["tiles"].y * TILE_SIZE * 0.5),
			"offset": rdef["offset"],
			"tiles": rdef["tiles"],
		}

	# Create exit trigger in exit room
	var exit_data: Dictionary = rooms["exit_room"]
	var exit_pos: Vector2 = exit_data["offset"] + exit_data["center"]
	var exit_trigger := Area2D.new()
	exit_trigger.name = "ExitTrigger"
	exit_trigger.position = exit_pos
	exit_trigger.add_to_group("exit_triggers")
	var exit_shape := RectangleShape2D.new()
	exit_shape.size = Vector2(32, 48)
	var exit_col := CollisionShape2D.new()
	exit_col.shape = exit_shape
	exit_trigger.add_child(exit_col)
	# Visual: stairs indicator
	var stairs_visual := ColorRect.new()
	stairs_visual.color = Color(0.4, 0.4, 0.2, 0.8)
	stairs_visual.size = Vector2(28, 40)
	stairs_visual.position = Vector2(-14, -20)
	exit_trigger.add_child(stairs_visual)
	exit_trigger.body_entered.connect(_on_exit_reached)
	add_child(exit_trigger)

	# Create player spawn marker
	var player_spawn := Marker2D.new()
	player_spawn.name = "PlayerSpawn"
	player_spawn.position = Vector2(48, 48)
	add_child(player_spawn)

	# Debug timer label
	var timer_label := Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(10, 10)
	timer_label.add_theme_font_size_override("font_size", 16)
	add_child(timer_label)


## Create a single basement room node.
func _create_room(rdef: Dictionary) -> Node2D:
	var room := Node2D.new()
	room.name = rdef["name"]
	room.position = rdef["offset"]

	var size_px := Vector2(rdef["tiles"].x * TILE_SIZE, rdef["tiles"].y * TILE_SIZE)

	# Floor
	var floor_rect := ColorRect.new()
	floor_rect.name = "Floor"
	floor_rect.color = FLOOR_COLOR
	floor_rect.size = size_px
	room.add_child(floor_rect)

	# Walls (StaticBody2D)
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	walls.collision_layer = 128  # environment layer (bit 7)
	walls.collision_mask = 0

	var wall_thickness := 16.0
	# Wall visual (border)
	var wall_visual := ColorRect.new()
	wall_visual.color = WALL_COLOR
	wall_visual.size = size_px
	walls.add_child(wall_visual)

	# Collision shapes for walls
	var sides: Array[Dictionary] = [
		{"name": "Top", "size": Vector2(size_px.x, wall_thickness), "pos": Vector2(size_px.x * 0.5, 0)},
		{"name": "Bottom", "size": Vector2(size_px.x, wall_thickness), "pos": Vector2(size_px.x * 0.5, size_px.y)},
		{"name": "Left", "size": Vector2(wall_thickness, size_px.y), "pos": Vector2(0, size_px.y * 0.5)},
		{"name": "Right", "size": Vector2(wall_thickness, size_px.y), "pos": Vector2(size_px.x, size_px.y * 0.5)},
	]
	for side in sides:
		var shape := RectangleShape2D.new()
		shape.size = side["size"]
		var col := CollisionShape2D.new()
		col.name = "Wall" + side["name"]
		col.position = side["pos"]
		col.shape = shape
		walls.add_child(col)

	room.add_child(walls)

	# Navigation region
	_nav_region(room, size_px)

	# Corridor-specific: pipes visual
	if rdef["id"] == "corridor_b":
		var pipes := ColorRect.new()
		pipes.name = "Pipes"
		pipes.color = PIPE_COLOR
		pipes.size = Vector2(size_px.x - 32, 8)
		pipes.position = Vector2(16, size_px.y * 0.3)
		room.add_child(pipes)

	# Dim red light
	var light := PointLight2D.new()
	light.name = "DimLight"
	light.color = LIGHT_COLOR
	light.energy = 0.3
	light.position = size_px * 0.5
	# Create a simple procedural circle texture for the light
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	for y in range(64):
		for x in range(64):
			var dx := float(x) - 32.0
			var dy := float(y) - 32.0
			var dist := sqrt(dx * dx + dy * dy) / 32.0
			var alpha := maxf(0.0, 1.0 - dist)
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	var tex := ImageTexture.create_from_image(img)
	light.texture = tex
	room.add_child(light)

	# Obstacles in room_a and room_b
	if rdef["id"] == "room_a" or rdef["id"] == "room_b":
		_add_obstacles(room, size_px)

	return room


## Add navigation region to room.
func _nav_region(parent: Node2D, size_px: Vector2) -> void:
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
	nav_region.navigation_polygon = nav_poly
	parent.add_child(nav_region)


## Add placeholder obstacles (ColorRects) to rooms.
func _add_obstacles(room: Node2D, size_px: Vector2) -> void:
	var obstacle_data: Array[Vector2] = [
		Vector2(size_px.x * 0.3, size_px.y * 0.3),
		Vector2(size_px.x * 0.7, size_px.y * 0.6),
	]
	for pos in obstacle_data:
		var obs := ColorRect.new()
		obs.color = Color(0.15, 0.15, 0.15, 1.0)
		obs.size = Vector2(32, 32)
		obs.position = pos - Vector2(16, 16)
		room.add_child(obs)

		# Static body for collision
		var body := StaticBody2D.new()
		body.position = pos
		var shape := RectangleShape2D.new()
		shape.size = Vector2(32, 32)
		var col := CollisionShape2D.new()
		col.shape = shape
		body.add_child(col)
		body.collision_layer = 128
		body.collision_mask = 0
		room.add_child(body)


## Generate spawn points for a basement room.
func _gen_basement_spawn_points(tiles: Vector2i, room_id: String) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var size_px := Vector2(tiles.x * TILE_SIZE, tiles.y * TILE_SIZE)
	var margin := 32.0

	match room_id:
		"start_room":
			pass  # No enemies in start room
		"corridor_a", "corridor_b":
			points.append(Vector2(size_px.x * 0.5, size_px.y * 0.5))
		"room_a", "room_b":
			points.append(Vector2(margin, margin))
			points.append(Vector2(size_px.x - margin, margin))
			points.append(Vector2(size_px.x * 0.5, size_px.y - margin))
		"corridor_c":
			points.append(Vector2(size_px.x * 0.3, size_px.y * 0.5))
			points.append(Vector2(size_px.x * 0.7, size_px.y * 0.5))
		"exit_room":
			points.append(Vector2(size_px.x * 0.5, size_px.y * 0.5))

	return points
