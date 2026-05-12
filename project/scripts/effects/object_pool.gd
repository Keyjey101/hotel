extends Node
class_name ObjectPool

## ObjectPool — Generic reusable object pool.
## Pre-instantiate nodes, get/return, auto-expand up to max_size.

var _scene: PackedScene
var _pool: Array[Node] = []
var _active: Array[Node] = []
var _max_size: int = 50


func _init(scene: PackedScene, initial: int = 10, maximum: int = 50) -> void:
	_scene = scene
	_max_size = maximum
	# Defer prewarm to _ready so we can add_child first
	_initial_count = initial


var _initial_count: int = 0


func _ready() -> void:
	for i in range(_initial_count):
		_expand()


func get_instance() -> Node:
	if _pool.is_empty():
		if _active.size() < _max_size:
			_expand()
		else:
			# Force return oldest active
			var oldest: Node = _active.pop_front()
			if is_instance_valid(oldest):
				oldest.set_meta("_pool_reclaimed", true)
				_return(oldest)
	if _pool.is_empty():
		return null

	var instance: Node = _pool.pop_back()
	while not is_instance_valid(instance) and not _pool.is_empty():
		instance = _pool.pop_back()
	if not is_instance_valid(instance):
		if _active.size() < _max_size:
			_expand()
			instance = _pool.pop_back()
		else:
			return null
	_active.append(instance)
	instance.set_process(true)
	instance.set_physics_process(true)
	if instance is CanvasItem:
		instance.visible = true
	return instance


func return_instance(instance: Node) -> void:
	_return(instance)


func _return(instance: Node) -> void:
	if instance.get_meta("_pool_reclaimed", false):
		instance.set_meta("_pool_reclaimed", false)
		if _pool.has(instance):
			_active.erase(instance)
			return
	instance.set_process(false)
	instance.set_physics_process(false)
	if instance is CanvasItem:
		instance.visible = false
	_active.erase(instance)
	if not _pool.has(instance):
		_pool.append(instance)


func _expand() -> void:
	if not is_inside_tree():
		return
	var instance: Node = _scene.instantiate()
	instance.set_process(false)
	instance.set_physics_process(false)
	if instance is CanvasItem:
		instance.visible = false
	add_child(instance)
	_pool.append(instance)


func prewarm(count: int) -> void:
	for i in range(count):
		_expand()
