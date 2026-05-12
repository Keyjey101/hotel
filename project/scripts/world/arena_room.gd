extends Node2D

## ArenaRoom — Wave-based arena combat logic.
## Attach as child of a RoomInstance to add wave functionality.
## Used in Floor 6 rooms B1 (Gladiator Pit) and BOSS (The Arena).
## Does NOT modify RoomInstance — adds wave behavior as overlay.

signal all_waves_cleared

@export var wave_configs: Array[Dictionary] = []
## Format per wave: { "enemy_types": ["gladiator", "berserker"], "counts": [2, 1], "spawn_point_indices": [0, 1, 2] }

@export var door_nodes: Array[NodePath] = []

var current_wave: int = -1
var doors_locked: bool = false
var active_enemies: Array[CharacterBody2D] = []
var _room_instance: RoomInstance = null
var _connected: bool = false


func _ready() -> void:
	_room_instance = _find_room_instance()
	if _room_instance == null:
		push_warning("ArenaRoom: no RoomInstance found in parents")
		return


func _enter_tree() -> void:
	if not _connected:
		EventBus.enemy_disabled.connect(_on_enemy_disabled)
		_connected = true


func _exit_tree() -> void:
	if _connected:
		EventBus.enemy_disabled.disconnect(_on_enemy_disabled)
		_connected = false


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func start_arena() -> void:
	if current_wave >= 0:
		return  # Already started
	_lock_doors()
	_spawn_wave(0)


func is_arena_active() -> bool:
	return current_wave >= 0 and doors_locked


func get_current_wave() -> int:
	return current_wave


# ---------------------------------------------------------------------------
# Wave spawning
# ---------------------------------------------------------------------------

func _spawn_wave(index: int) -> void:
	if index >= wave_configs.size():
		_unlock_arena()
		return

	current_wave = index
	var config: Dictionary = wave_configs[index]
	var types: Array = config.get("enemy_types", [])
	var counts: Array = config.get("counts", [])
	var spawn_indices: Array = config.get("spawn_point_indices", [])

	if _room_instance == null:
		_unlock_arena()
		return

	var spawn_points := _room_instance.spawn_points
	var spawn_idx := 0

	for type_idx in range(types.size()):
		var type: String = types[type_idx]
		var count: int = counts[type_idx] if type_idx < counts.size() else 1

		var scene: PackedScene = _load_enemy_scene(type)
		if scene == null:
			continue

		for i in range(count):
			var pos := _get_spawn_position(spawn_points, spawn_indices, spawn_idx)
			spawn_idx += 1

			var enemy := _room_instance.add_enemy(scene, pos)
			if enemy != null:
				active_enemies.append(enemy)
				var _enemy_id := enemy.get_instance_id()
				# Connect tree_exited as fallback for enemy removal
				if enemy.has_signal("tree_exited"):
					enemy.tree_exited.connect(_on_enemy_tree_exited.bind(_enemy_id))

	print("[ArenaRoom] Wave %d spawned (%d enemies)" % [index, active_enemies.size()])


# Enemy scene cache to avoid repeated load() calls
var _enemy_scene_cache: Dictionary = {}

func _load_enemy_scene(type: String) -> PackedScene:
	if _enemy_scene_cache.has(type):
		return _enemy_scene_cache[type]
	var paths: Dictionary = {
		"gladiator": "res://scenes/enemies/gladiator.tscn",
		"berserker": "res://scenes/enemies/berserker.tscn",
		"staff": "res://scenes/enemies/staff.tscn",
		"guard": "res://scenes/enemies/guard.tscn",
	}
	var path: String = paths.get(type, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		_enemy_scene_cache[type] = null
		return null
	var scene: PackedScene = load(path)
	_enemy_scene_cache[type] = scene
	return scene


func _get_spawn_position(spawn_points: Array[Marker2D], indices: Array, spawn_idx: int) -> Vector2:
	# Use specific spawn point indices if provided
	if spawn_idx < indices.size() and indices[spawn_idx] < spawn_points.size():
		return spawn_points[indices[spawn_idx]].position
	# Fallback: use sequential spawn points
	if spawn_idx < spawn_points.size():
		return spawn_points[spawn_idx].position
	# Last resort: room center
	if _room_instance:
		return Vector2(_room_instance.room_bounds.size.x * 0.5, _room_instance.room_bounds.size.y * 0.5)
	return Vector2.ZERO


# ---------------------------------------------------------------------------
# Wave completion tracking
# ---------------------------------------------------------------------------

func _on_enemy_disabled(enemy: CharacterBody2D) -> void:
	if enemy in active_enemies:
		active_enemies.erase(enemy)
		_check_wave_cleared()


func _on_enemy_tree_exited(enemy_id: int) -> void:
	# Use instance ID to match since the enemy node is already freed
	var to_remove: Array[CharacterBody2D] = []
	for enemy in active_enemies:
		if not is_instance_valid(enemy) or enemy.get_instance_id() == enemy_id:
			to_remove.append(enemy)
	for enemy in to_remove:
		active_enemies.erase(enemy)
	if not to_remove.is_empty():
		_check_wave_cleared()


func _check_wave_cleared() -> void:
	# Filter out invalid/dead enemies
	var alive: Array[CharacterBody2D] = []
	for enemy in active_enemies:
		if is_instance_valid(enemy) and enemy.get("_disabled") != true:
			alive.append(enemy)
	active_enemies = alive

	if alive.is_empty():
		print("[ArenaRoom] Wave %d cleared!" % current_wave)
		# Next wave or finish
		var next_wave := current_wave + 1
		if next_wave < wave_configs.size():
			_spawn_wave(next_wave)
		else:
			_unlock_arena()


# ---------------------------------------------------------------------------
# Door management
# ---------------------------------------------------------------------------

func _lock_doors() -> void:
	doors_locked = true
	for path in door_nodes:
		var door := get_node_or_null(path) as Area2D
		if door != null:
			# Disable door monitoring to prevent passage
			door.monitoring = false
			# Visual: dim the door
			for child in door.get_children():
				if child is ColorRect:
					child.color = Color(0.5, 0.1, 0.1, 0.8)
			door.set_meta("arena_locked", true)
	print("[ArenaRoom] Doors locked")


func _unlock_arena() -> void:
	doors_locked = false
	current_wave = -1

	for path in door_nodes:
		var door := get_node_or_null(path) as Area2D
		if door != null:
			door.monitoring = true
			for child in door.get_children():
				if child is ColorRect:
					child.color = Color(0.8, 0.6, 0.2, 0.6)
			door.set_meta("arena_locked", false)
	print("[ArenaRoom] Doors unlocked — arena cleared!")

	all_waves_cleared.emit()

	if _room_instance != null:
		_room_instance.check_cleared()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _find_room_instance() -> RoomInstance:
	var node := get_parent()
	while node != null:
		if node is RoomInstance:
			return node
		node = node.get_parent()
	return null
