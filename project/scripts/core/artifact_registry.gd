extends Node

## ArtifactRegistry — Autoload that preloads all cult artifact .tres resources.
## Provides lookup by id and weighted random selection.

var _artifacts: Dictionary = {}  # id -> Resource
var _all_artifacts: Array = []   # flat list for weighted selection


func _ready() -> void:
	_load_artifacts_from_dir("res://resources/artifacts/")
	print("[ArtifactRegistry] Loaded %d artifacts" % _artifacts.size())


func _load_artifacts_from_dir(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("[ArtifactRegistry] Directory not found: %s" % dir_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path := dir_path + file_name
			var res := load(full_path)
			if res and res is Resource:
				_artifacts[res.id] = res
				_all_artifacts.append(res)
		file_name = dir.get_next()
	dir.list_dir_end()


func get_artifact(id: String) -> Resource:
	return _artifacts.get(id, null)


func get_random_artifact(rarity_weights: Dictionary, rng: RandomNumberGenerator) -> Resource:
	# rarity_weights: {1: 0.0, 2: 0.7, 3: 0.3} — weight per rarity level
	# Get unlocked artifact ids from meta
	var unlocked_ids: Array = []
	if SaveManager:
		var meta := SaveManager.get_meta()
		unlocked_ids = meta.get("unlocked_artifacts", [])

	# Filter artifacts by rarity weights AND unlock status
	var candidates: Array = []
	var weights: Array = []
	for art in _all_artifacts:
		# Skip locked artifacts
		if unlocked_ids.size() > 0 and not unlocked_ids.has(art.id):
			continue
		var rarity: int = art.rarity
		var weight: float = rarity_weights.get(rarity, 0.0)
		if weight > 0.0:
			candidates.append(art)
			weights.append(weight)

	if candidates.is_empty():
		# Fallback: if less than 3 unlocked, allow any artifact (prevents empty pool)
		if _all_artifacts.is_empty():
			return null
		if unlocked_ids.size() < 3:
			# Use full pool as fallback
			candidates = _all_artifacts.duplicate()
			weights.clear()
			for art in candidates:
				var rarity: int = art.rarity
				weights.append(rarity_weights.get(rarity, 0.5))
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
	return candidates[-1]


func get_all_artifacts() -> Array:
	return _all_artifacts.duplicate()
