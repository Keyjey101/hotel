extends Node

## UpgradeRegistry — Autoload that preloads all stat upgrade .tres resources.
## Provides lookup by id and weighted random selection.

var _upgrades: Dictionary = {}  # id -> Resource
var _all_upgrades: Array = []   # flat list


func _ready() -> void:
	_load_upgrades_from_dir("res://resources/upgrades/")
	print("[UpgradeRegistry] Loaded %d upgrades" % _upgrades.size())


func _load_upgrades_from_dir(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("[UpgradeRegistry] Directory not found: %s" % dir_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path := dir_path + file_name
			var res := load(full_path)
			if res and res is StatUpgrade:
				_upgrades[res.id] = res
				_all_upgrades.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()


func get_upgrade(id: String) -> Resource:
	return _upgrades.get(id, null)


func get_random_upgrade_for_floor(floor_number: int, rng: RandomNumberGenerator) -> Resource:
	# Filter upgrades available for this floor
	var candidates: Array = []
	var weights: Array = []
	var unlocked_ids: Array = []
	if SaveManager:
		var meta := SaveManager.get_meta()
		unlocked_ids = meta.get("unlocked_starting_stat_upgrades", [])
	for upg in _all_upgrades:
		if _is_available_on_floor(upg, floor_number):
			if unlocked_ids.size() > 0 and upg.id not in unlocked_ids:
				continue
			candidates.append(upg)
			var weight: float = float(upg.get("spawn_weight", 1.0))
			weights.append(weight)

	if candidates.is_empty():
		if _all_upgrades.is_empty():
			return null
		candidates = _all_upgrades.duplicate()
		if unlocked_ids.size() > 0:
			candidates = candidates.filter(func(u): return u.id in unlocked_ids)
		else:
			# No unlock data available — only use upgrades that are available on this floor
			candidates = candidates.filter(func(u): return _is_available_on_floor(u, floor_number))
		weights.clear()
		for upg in candidates:
			weights.append(float(upg.get("spawn_weight", 1.0)))
		if candidates.is_empty():
			return null

	# Weighted selection
	var total := 0.0
	for w in weights:
		total += w
	if total <= 0.0:
		return candidates[rng.randi_range(0, candidates.size() - 1)]
	var roll := rng.randf() * total
	var accumulated := 0.0
	for i in range(candidates.size()):
		accumulated += weights[i]
		if roll <= accumulated:
			return candidates[i]
	if candidates.is_empty():
		return null
	return candidates[-1]


func _is_available_on_floor(upg: StatUpgrade, floor_number: int) -> bool:
	var floors_str: String = upg.spawn_floors
	if floors_str == "" or floors_str == "1-9":
		return true
	# Parse "3-9" or "5" format
	var parts := floors_str.split("-")
	if parts.size() == 2:
		var min_floor := int(parts[0])
		var max_floor := int(parts[1])
		return floor_number >= min_floor and floor_number <= max_floor
	if parts.size() == 1:
		var specific_floor := int(parts[0])
		return floor_number == specific_floor
	return false


func get_all_upgrades() -> Array:
	return _all_upgrades.duplicate()
