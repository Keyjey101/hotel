class_name SeedManager
extends RefCounted

## SeedManager — Deterministic per-run randomization.
## Same seed = same enemy spawns, same loot, same gate config.

var _seed: int
var _rng: RandomNumberGenerator
var _floor_rng_cache: Dictionary = {}  # floor -> RandomNumberGenerator
var _room_rng_cache: Dictionary = {}   # "floor_room" -> RandomNumberGenerator


func _init(run_seed: int) -> void:
	_seed = run_seed
	_rng = RandomNumberGenerator.new()
	_rng.seed = run_seed


func get_seed() -> int:
	return _seed


func get_floor_rng(floor_number: int) -> RandomNumberGenerator:
	if _floor_rng_cache.has(floor_number):
		return _floor_rng_cache[floor_number]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(_seed) + "_" + str(floor_number))
	_floor_rng_cache[floor_number] = rng
	return rng


func get_room_rng(floor_number: int, room_index: int) -> RandomNumberGenerator:
	var key := "%d_%d" % [floor_number, room_index]
	if _room_rng_cache.has(key):
		return _room_rng_cache[key]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(str(_seed) + "_" + str(floor_number) + "_" + str(room_index))
	_room_rng_cache[key] = rng
	return rng


func get_room_enemy_config(floor_number: int, room_index: int, spawn_points: int) -> Dictionary:
	var rng := get_room_rng(floor_number, room_index)
	# Decide how many enemies (60-100% of spawn points)
	var count := rng.randi_range(ceili(spawn_points * 0.6), spawn_points)
	# Decide which spawn points are active
	var active_points: Array[int] = []
	var all_points: Array = range(spawn_points)
	all_points = all_points.duplicate()
	_deterministic_shuffle(all_points, rng)
	for i in range(mini(count, all_points.size())):
		active_points.append(all_points[i])
	return {"count": count, "active_points": active_points}


func get_room_loot_config(floor_number: int, room_index: int, loot_zones: int) -> Dictionary:
	var rng := get_room_rng(floor_number, room_index)
	var loot_rng := RandomNumberGenerator.new()
	loot_rng.seed = hash(str(rng.seed) + "_loot")
	var loot_count := loot_rng.randi_range(1, maxi(1, loot_zones - 1))
	return {"count": loot_count, "seed": loot_rng.seed}


func get_gate_config(floor_number: int, total_branches: int) -> Dictionary:
	if total_branches <= 1:
		return {"open": range(total_branches), "closed": -1}
	var rng := get_floor_rng(floor_number)
	var gate_rng := RandomNumberGenerator.new()
	gate_rng.seed = rng.seed + 777  # Offset without mutating original
	var branches: Array = range(total_branches)
	branches = branches.duplicate()
	_deterministic_shuffle(branches, gate_rng)
	var open_branches := branches.slice(0, total_branches - 1)
	var closed_branch: int = int(branches[total_branches - 1])
	return {"open": open_branches, "closed": closed_branch}


func _deterministic_shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
