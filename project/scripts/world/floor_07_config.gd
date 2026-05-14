## Floor 7 config — Observatory (Envy).
## All room data from 13_FLOOR_DESIGN.md section 8.
## Palette: floor #1A1A6A deep indigo, walls #0A0A2A deep space blue, accent #C0C0D0 silver,
##   purple #4B0082, starlight #E6E6FA.
## Blood: #CC2222 | BG: #0A0A2A

const F7_FLOOR := Color(0.102, 0.102, 0.416, 1.0)  # #1A1A6A deep indigo
const F7_WALL := Color(0.039, 0.039, 0.165, 1.0)   # #0A0A2A deep space blue
const TILE := 32


## Return all 10 rooms for Floor 7 as Dictionary[room_id -> RoomConfig].
static func get_floor_07_rooms() -> Dictionary:
	var rooms: Dictionary = {}

	# --- A1 — Telescope Gallery ---
	# 10×6 tiles, corridor, Spy×1, connects a2
	rooms["a1"] = RoomConfig._make({
		"room_id": "a1",
		"room_name": "Telescope Gallery",
		"room_type": "corridor",
		"size_tiles": Vector2i(10, 6),
		"size_px": Vector2(10 * TILE, 6 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [{"type": "spy", "count": 1}],
		"loot": [],
		"connections": ["a2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 6 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 6 * TILE), ["a2"], ["bottom"]),
		"branch": "a",
	})

	# --- A2 — Star Map Corridor ---
	# 12×4 tiles, corridor, Shadow Stalker×1, connects a1 + hub
	rooms["a2"] = RoomConfig._make({
		"room_id": "a2",
		"room_name": "Star Map Corridor",
		"room_type": "corridor",
		"size_tiles": Vector2i(12, 4),
		"size_px": Vector2(12 * TILE, 4 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [{"type": "shadow_stalker", "count": 1}],
		"loot": [],
		"connections": ["a1", "hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 4 * TILE), 8),
		"loot_zone_positions": [],
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 4 * TILE), ["a1", "hub"], ["top", "bottom"]),
		"branch": "a",
	})

	# --- HUB — The Library ---
	# 14×12 tiles, hub, Spy×2 + Shadow Stalker×1, Shotgun
	rooms["hub"] = RoomConfig._make({
		"room_id": "hub",
		"room_name": "The Library",
		"room_type": "hub",
		"size_tiles": Vector2i(14, 12),
		"size_px": Vector2(14 * TILE, 12 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [
			{"type": "spy", "count": 2},
			{"type": "shadow_stalker", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "shotgun"}],
		"connections": ["a2", "b1", "c1", "d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(14 * TILE, 12 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(14 * TILE, 12 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(
			Vector2(14 * TILE, 12 * TILE),
			["a2", "b1", "c1", "d1"],
			["top", "left", "right", "bottom"]
		),
		"branch": "hub",
	})

	# --- B1 — Restricted Archives (DARK) ---
	# 10×8 tiles, chamber, Spy×2 + Shadow Stalker×1, SMG
	rooms["b1"] = RoomConfig._make({
		"room_id": "b1",
		"room_name": "Restricted Archives",
		"room_type": "chamber",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [
			{"type": "spy", "count": 2},
			{"type": "shadow_stalker", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "smg"}],
		"connections": ["hub", "b2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "b2"], ["top", "bottom"]),
		"branch": "b",
	})

	# --- B2 — The Cipher Room ---
	# 8×8 tiles, chamber, Cultist×1, stat_upgrade + KEY(50%)
	rooms["b2"] = RoomConfig._make({
		"room_id": "b2",
		"room_name": "The Cipher Room",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE, 8 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [{"type": "cultist", "count": 1}],
		"loot": [{"type": "stat_upgrade"}, {"type": "key", "chance": 0.5}],
		"connections": ["b1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["b1"], ["top"]),
		"branch": "b",
	})

	# --- C1 — Observatory Dome (LOCKED) ---
	# 12×10 tiles, gallery, Spy×2 + Shadow Stalker×2, Machete
	rooms["c1"] = RoomConfig._make({
		"room_id": "c1",
		"room_name": "Observatory Dome",
		"room_type": "gallery",
		"size_tiles": Vector2i(12, 10),
		"size_px": Vector2(12 * TILE, 10 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [
			{"type": "spy", "count": 2},
			{"type": "shadow_stalker", "count": 2},
		],
		"loot": [{"type": "weapon", "id": "machete"}],
		"connections": ["hub", "c2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(12 * TILE, 10 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(12 * TILE, 10 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(12 * TILE, 10 * TILE), ["hub", "c2"], ["left", "right"]),
		"branch": "c",
		"is_locked": true,
	})

	# --- C2 — Star Chamber ---
	# 8×8 tiles, chamber, Shadow Stalker×1 + Cultist×1, KEY(50%) + ammo
	rooms["c2"] = RoomConfig._make({
		"room_id": "c2",
		"room_name": "Star Chamber",
		"room_type": "chamber",
		"size_tiles": Vector2i(8, 8),
		"size_px": Vector2(8 * TILE, 8 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [
			{"type": "shadow_stalker", "count": 1},
			{"type": "cultist", "count": 1},
		],
		"loot": [{"type": "key", "chance": 0.5}, {"type": "ammo"}],
		"connections": ["c1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(8 * TILE, 8 * TILE), 8),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(8 * TILE, 8 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(8 * TILE, 8 * TILE), ["c1"], ["left"]),
		"branch": "c",
	})

	# --- D1 — Shadow Gallery (DARK) ---
	# 10×8 tiles, gallery, Spy×2 + Cultist×1, Knife
	rooms["d1"] = RoomConfig._make({
		"room_id": "d1",
		"room_name": "Shadow Gallery",
		"room_type": "gallery",
		"size_tiles": Vector2i(10, 8),
		"size_px": Vector2(10 * TILE, 8 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [
			{"type": "spy", "count": 2},
			{"type": "cultist", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "knife"}],
		"connections": ["hub", "d2"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 8 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 8 * TILE), 1),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 8 * TILE), ["hub", "d2"], ["left", "right"]),
		"branch": "d",
	})

	# --- D2 — The Void Room (DARK) ---
	# 10×10 tiles, trap, Shadow Stalker×2 + Spy×1, random weapon + KEY(50%)
	rooms["d2"] = RoomConfig._make({
		"room_id": "d2",
		"room_name": "The Void Room",
		"room_type": "trap",
		"size_tiles": Vector2i(10, 10),
		"size_px": Vector2(10 * TILE, 10 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [
			{"type": "shadow_stalker", "count": 2},
			{"type": "spy", "count": 1},
		],
		"loot": [{"type": "weapon", "id": "random"}, {"type": "key", "chance": 0.5}],
		"connections": ["d1"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(10 * TILE, 10 * TILE), 10),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(10 * TILE, 10 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(10 * TILE, 10 * TILE), ["d1"], ["left"]),
		"branch": "d",
	})

	# --- BOSS — The Curator's Study ---
	# 16×14 tiles, boss, Curator×1, cult artifact
	rooms["boss"] = RoomConfig._make({
		"room_id": "boss",
		"room_name": "The Curator's Study",
		"room_type": "boss",
		"size_tiles": Vector2i(16, 14),
		"size_px": Vector2(16 * TILE, 14 * TILE),
		"floor_color": F7_FLOOR,
		"wall_color": F7_WALL,
		"enemies": [{"type": "curator", "count": 1}],
		"loot": [{"type": "cult_artifact", "id": "random"}],
		"connections": ["hub"],
		"spawn_point_positions": RoomConfig._gen_spawn_points(Vector2(16 * TILE, 14 * TILE), 12),
		"loot_zone_positions": RoomConfig._gen_loot_zones(Vector2(16 * TILE, 14 * TILE), 2),
		"door_positions": RoomConfig._gen_doors(Vector2(16 * TILE, 14 * TILE), ["hub"], ["top"]),
		"branch": "boss",
	})

	return rooms



## Floor 7 specific: rooms that are dark zones (from 13_FLOOR_DESIGN.md section 8.2)
const DARK_ROOMS: Array[String] = ["b1", "d1", "d2"]

## Floor 7 specific: rooms with surveillance cameras
const CAMERA_ROOMS: Array[String] = ["hub", "b2", "c1"]


## Apply Floor 7-specific elements to a room after setup:
## - Darkness overlays in DARK_ROOMS
## - Surveillance cameras in CAMERA_ROOMS
## - Light sources in dark rooms
static func apply_floor_07_extras(room: RoomInstance) -> void:
	var rid: String = room.room_id

	if rid in DARK_ROOMS:
		_add_darkness_overlay(room)
		_add_light_sources(room)

	if rid in CAMERA_ROOMS:
		_add_surveillance_cameras(room)


## Darkness overlay: ColorRect covering full room, #000000 alpha 0.6
static func _add_darkness_overlay(room: RoomInstance) -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 50
	var overlay := ColorRect.new()
	overlay.name = "DarknessOverlay"
	overlay.color = Color(0.0, 0.0, 0.0, 0.6)
	overlay.size = room.room_bounds.size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(overlay)
	room.add_child(canvas)


## Light sources: 1-2 per dark room. Area2D with circle radius 40px.
## Reveals Spy/Shadow Stalker when they enter the light zone.
static func _add_light_sources(room: RoomInstance) -> void:
	var size := room.room_bounds.size
	var positions: Array[Vector2] = [
		Vector2(size.x * 0.3, size.y * 0.4),
		Vector2(size.x * 0.7, size.y * 0.6),
	]

	for i in range(positions.size()):
		var light := Area2D.new()
		light.name = "LightSource%d" % i
		light.position = positions[i]
		light.add_to_group("light_sources")

		var shape := CircleShape2D.new()
		shape.radius = 40.0
		var col := CollisionShape2D.new()
		col.shape = shape
		light.add_child(col)

		# Visual glow
		var glow := ColorRect.new()
		glow.size = Vector2(80, 80)
		glow.position = Vector2(-40, -40)
		glow.color = Color(0.902, 0.902, 0.980, 0.2)  # #E6E6FA alpha 0.2
		glow.z_index = 51
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		light.add_child(glow)

		# When an enemy enters light, reveal them
		light.body_entered.connect(_on_light_body_entered)

		room.add_child(light)


## Surveillance camera: Area2D detection cone, alerts enemies on player enter.
## Destroyed in 1 hit (any weapon hit -> queue_free + alert nearby).
static func _add_surveillance_cameras(room: RoomInstance) -> void:
	var size := room.room_bounds.size
	var camera_positions: Array[Vector2] = [
		Vector2(size.x * 0.5, size.y * 0.15),
	]

	for i in range(camera_positions.size()):
		var cam := Area2D.new()
		cam.name = "SurveillanceCamera%d" % i
		cam.position = camera_positions[i]
		cam.add_to_group("cameras")
		cam.collision_layer = 0
		cam.collision_mask = 1  # Detect player layer
		cam.monitorable = true
		cam.monitoring = true

		# Detection shape: elongated capsule (cone-like)
		var shape := CapsuleShape2D.new()
		shape.radius = 20.0
		shape.height = 120.0
		var col := CollisionShape2D.new()
		col.shape = shape
		cam.add_child(col)

		# Visual: small silver rectangle
		var visual := ColorRect.new()
		visual.size = Vector2(8, 6)
		visual.position = Vector2(-4, -3)
		visual.color = Color(0.753, 0.753, 0.816, 1.0)  # #C0C0D0 silver
		visual.z_index = 60
		cam.add_child(visual)

		# Red "recording" indicator
		var indicator := ColorRect.new()
		indicator.name = "RecordingLight"
		indicator.size = Vector2(2, 2)
		indicator.position = Vector2(3, -1)
		indicator.color = Color(1.0, 0.0, 0.0, 1.0)
		indicator.z_index = 61
		cam.add_child(indicator)

		# Player enters camera zone -> alert enemies
		cam.body_entered.connect(_on_camera_detected_player.bind(room))

		# Player weapon hits camera -> destroy + alert
		cam.area_entered.connect(_on_camera_hit.bind(cam, room))

		room.add_child(cam)


## Camera spotted the player -> alert all enemies in room
static func _on_camera_detected_player(body: Node2D, room: RoomInstance) -> void:
	if not is_instance_valid(room):
		return
	if not body.is_in_group("player"):
		return

	for enemy in room.active_enemies:
		if is_instance_valid(enemy) and enemy.has_method("on_nearby_alert"):
			enemy.on_nearby_alert(body.global_position)


## Camera hit by player attack -> destroy + alert nearby enemies
static func _on_camera_hit(area: Area2D, cam: Area2D, room: RoomInstance) -> void:
	if not is_instance_valid(cam):
		return
	if not is_instance_valid(room):
		return

	# Only react to player attack areas (melee hits, projectiles)
	var area_name: String = area.name
	if not area_name.begins_with("Melee") and not area_name.begins_with("Projectile"):
		if not area.is_in_group("player_attack"):
			return
	# Verify the hit area belongs to the player (not an enemy)
	if not area.is_in_group("player_attack"):
		var owner_node := area.owner
		if owner_node == null or not owner_node.is_in_group("player"):
			return

	var cam_pos := cam.global_position
	cam.queue_free()

	# Destroying camera alerts enemies
	for enemy in room.active_enemies:
		if is_instance_valid(enemy) and enemy.has_method("on_nearby_alert"):
			enemy.on_nearby_alert(cam_pos)


## Light source body entered -> reveal invisible enemies
static func _on_light_body_entered(body: Node2D) -> void:
	if body.is_in_group("spies") or body.is_in_group("shadow_stalkers"):
		var sprite_node = body.get("sprite") if body else null
		if sprite_node and is_instance_valid(sprite_node):
			sprite_node.modulate.a = 1.0
		if body.has_method("reveal"):
			body.reveal()
	if body and body.has_meta("_reveal_timer"):
		body.set_meta("_reveal_timer", 3.0)
	elif body and "_reveal_timer" in body:
		body.set("_reveal_timer", 3.0)
