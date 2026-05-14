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
	if not is_inside_tree():
		push_warning("[ObjectPool] get_instance called but pool is not in tree — _ready() never ran, pool is empty")
		return null
	if is_inside_tree() and _pool.is_empty():
		for i in range(_initial_count):
			_expand()
	# Lazy cleanup: remove freed instances from _active
	_active = _active.filter(func(n): return is_instance_valid(n))
	if _pool.is_empty():
		if _active.size() < _max_size:
			_expand()
		else:
			# Try to find a non-busy active instance to reclaim
			var reclaimed := false
			for i in range(_active.size()):
				var candidate: Node = _active[i]
				if is_instance_valid(candidate) and not candidate.get_meta("_pool_busy", false):
					candidate.set_meta("_pool_reclaimed", true)
					_return(candidate)
					reclaimed = true
					break
			if not reclaimed:
				return null
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
	# Reset state on reused instances
	if instance.has_method("reset"):
		instance.reset()
	_active.append(instance)
	instance.set_meta("_pool_busy", true)
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
		_active.erase(instance)
		if not _pool.has(instance):
			_pool.append(instance)
		return
	instance.set_meta("_pool_busy", false)
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
	if _scene == null:
		return
	var instance: Node = _scene.instantiate()
	instance.set_meta("_pool_busy", false)
	instance.set_process(false)
	instance.set_physics_process(false)
	if instance is CanvasItem:
		instance.visible = false
	add_child(instance)
	_pool.append(instance)


func prewarm(count: int) -> void:
	for i in range(count):
		_expand()
