extends Node

## SaveManager — Minimal save system for roguelike runs + settings + records + meta-progression.

const RUN_SAVE_PATH := "user://hotel_run.json"
const SETTINGS_PATH := "user://hotel_settings.json"
const RECORDS_PATH := "user://hotel_records.json"
const META_PATH := "user://hotel_meta.json"

## Starting unlocks (4 artifacts + 2 stat upgrades available from run 1).
const DEFAULT_UNLOCKED_ARTIFACTS: Array[String] = [
	"a1_demon_eye",
	"a2_blood_pact",
	"a3_iron_will",
	"a5_shadow_step",
]
const DEFAULT_UNLOCKED_STAT_UPGRADES: Array[String] = [
	"s1_vitality_shard",
	"s4_razor_edge",
]

var _current_settings: Dictionary = {}
var _settings_loaded: bool = false
var _meta_cache: Dictionary = {}  # in-memory cache, loaded once
var _meta_loaded: bool = false


func save_run(state: Dictionary) -> void:
	var file := FileAccess.open(RUN_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % RUN_SAVE_PATH)
		return
	file.store_string(JSON.stringify(state, "\t"))


func load_run() -> Dictionary:
	if not FileAccess.file_exists(RUN_SAVE_PATH):
		return {}
	var file := FileAccess.open(RUN_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: %s" % RUN_SAVE_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func delete_run() -> void:
	if FileAccess.file_exists(RUN_SAVE_PATH):
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove(RUN_SAVE_PATH.get_file())


func save_settings(settings: Dictionary) -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % SETTINGS_PATH)
		return
	file.store_string(JSON.stringify(settings, "\t"))


func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return _default_settings()
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: %s" % SETTINGS_PATH)
		return _default_settings()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else _default_settings()


func load_records() -> Dictionary:
	if not FileAccess.file_exists(RECORDS_PATH):
		return {"deepest_floor": 0, "total_runs": 0, "fastest_time": 999999.0}
	var file := FileAccess.open(RECORDS_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: %s" % RECORDS_PATH)
		return {"deepest_floor": 0, "total_runs": 0, "fastest_time": 999999.0}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {"deepest_floor": 0, "total_runs": 0, "fastest_time": 999999.0}


func update_records(deepest_floor: int, run_time: float) -> void:
	var records := load_records()
	if deepest_floor > records.get("deepest_floor", 0):
		records["deepest_floor"] = deepest_floor
	if run_time < records.get("fastest_time", 999999.0):
		records["fastest_time"] = run_time
	records["total_runs"] = records.get("total_runs", 0) + 1
	var file := FileAccess.open(RECORDS_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % RECORDS_PATH)
		return
	file.store_string(JSON.stringify(records, "\t"))


func _default_settings() -> Dictionary:
	return {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0,
		"screen_shake": true,
		"screen_flash": true,
		"blood_intensity": 1.0,
		"fullscreen": false,
		"tutorial_shown": false,
	}


func get_total_runs() -> int:
	var records := load_records()
	return int(records.get("total_runs", 0))


func get_settings() -> Dictionary:
	if not _settings_loaded:
		_current_settings = load_settings()
		_settings_loaded = true
	return _current_settings


func save_and_apply(settings: Dictionary) -> void:
	_current_settings = settings
	_settings_loaded = true
	save_settings(settings)
	_apply_settings(settings)


func load_and_apply_settings() -> void:
	_current_settings = load_settings()
	_settings_loaded = true
	_apply_settings(_current_settings)


func _apply_settings(s: Dictionary) -> void:
	# Audio
	var master: float = s.get("master_volume", 1.0)
	var music: float = s.get("music_volume", 0.8)
	var sfx: float = s.get("sfx_volume", 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master))
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
		music_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(music))
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
		AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
		sfx_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(sfx))

	# Screen effects
	var screen_effects := get_node_or_null("/root/ScreenEffects")
	if screen_effects:
		screen_effects.set_meta("shake_enabled", s.get("screen_shake", true))
		screen_effects.set_meta("flash_enabled", s.get("screen_flash", true))
		screen_effects.set_meta("blood_intensity", s.get("blood_intensity", 1.0))

	# Fullscreen
	if s.get("fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# === Meta-progression persistence ===

func load_meta() -> Dictionary:
	if _meta_loaded:
		return _meta_cache.duplicate(true)
	if FileAccess.file_exists(META_PATH):
		var file := FileAccess.open(META_PATH, FileAccess.READ)
		if file == null:
			push_error("Failed to open file for reading: %s" % META_PATH)
		else:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				_meta_cache = parsed
				_meta_loaded = true
				_ensure_meta_defaults(_meta_cache)
				return _meta_cache.duplicate(true)
	_meta_cache = _default_meta()
	_meta_loaded = true
	return _meta_cache.duplicate(true)


func save_meta(meta: Dictionary) -> void:
	_meta_cache = meta
	_meta_loaded = true
	var file := FileAccess.open(META_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % META_PATH)
		return
	file.store_string(JSON.stringify(meta, "\t"))


func get_meta() -> Dictionary:
	return load_meta()


## Commit all pending unlocks to meta save. Only call from victory/failure handlers.
func commit_pending_unlocks(pending_artifacts: Array, pending_stats: Array, run_counters: Dictionary, floor_reached: int, ending_id: String) -> void:
	var meta := get_meta()
	# Artifact unlocks
	var unlocked: Array = meta.get("unlocked_artifacts", [])
	for id in pending_artifacts:
		if not unlocked.has(id):
			unlocked.append(id)
	meta["unlocked_artifacts"] = unlocked
	# Stat upgrade unlocks
	var unlocked_stats: Array = meta.get("unlocked_starting_stat_upgrades", [])
	for id in pending_stats:
		if not unlocked_stats.has(id):
			unlocked_stats.append(id)
	meta["unlocked_starting_stat_upgrades"] = unlocked_stats
	# Runs completed (intentionally counts both victories and basement failures;
	# this is standard roguelike behavior where every run counts toward progression)
	meta["runs_completed"] = int(meta.get("runs_completed", 0)) + 1
	# Deepest floor ever
	if floor_reached > int(meta.get("deepest_floor_ever", 0)):
		meta["deepest_floor_ever"] = floor_reached
	# Bosses defeated (use set to prevent double-counting)
	var bosses: Dictionary = meta.get("bosses_defeated", {})
	for boss_id in run_counters.get("bosses_defeated", {}):
		bosses[boss_id] = true
	meta["bosses_defeated"] = bosses
	# Endings seen
	if ending_id != "":
		var endings: Array = meta.get("secret_endings_seen", [])
		if not endings.has(ending_id):
			endings.append(ending_id)
		meta["secret_endings_seen"] = endings
	# Lifetime counters
	meta["total_limbs_severed"] = int(meta.get("total_limbs_severed", 0)) + int(run_counters.get("dismembered_limbs", 0))
	meta["total_weapons_thrown"] = int(meta.get("total_weapons_thrown", 0)) + int(run_counters.get("weapons_thrown", 0))
	save_meta(meta)


func _default_meta() -> Dictionary:
	return {
		"unlocked_artifacts": DEFAULT_UNLOCKED_ARTIFACTS.duplicate(),
		"unlocked_starting_stat_upgrades": DEFAULT_UNLOCKED_STAT_UPGRADES.duplicate(),
		"runs_completed": 0,
		"bosses_defeated": {},
		"secret_endings_seen": [],
		"deepest_floor_ever": 0,
		"total_limbs_severed": 0,
		"total_weapons_thrown": 0,
	}


func _ensure_meta_defaults(meta: Dictionary) -> void:
	if not meta.has("unlocked_artifacts"):
		meta["unlocked_artifacts"] = DEFAULT_UNLOCKED_ARTIFACTS.duplicate()
	if not meta.has("unlocked_starting_stat_upgrades"):
		meta["unlocked_starting_stat_upgrades"] = DEFAULT_UNLOCKED_STAT_UPGRADES.duplicate()
	if not meta.has("runs_completed"):
		meta["runs_completed"] = 0
	if not meta.has("bosses_defeated"):
		meta["bosses_defeated"] = {}
	if not meta.has("secret_endings_seen"):
		meta["secret_endings_seen"] = []
	if not meta.has("deepest_floor_ever"):
		meta["deepest_floor_ever"] = 0
	if not meta.has("total_limbs_severed"):
		meta["total_limbs_severed"] = 0
	if not meta.has("total_weapons_thrown"):
		meta["total_weapons_thrown"] = 0
