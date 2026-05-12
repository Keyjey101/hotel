extends Node

## SaveManager — Minimal save system for roguelike runs + settings + records.

const RUN_SAVE_PATH := "user://hotel_run.json"
const SETTINGS_PATH := "user://hotel_settings.json"
const RECORDS_PATH := "user://hotel_records.json"


func save_run(state: Dictionary) -> void:
	var file := FileAccess.open(RUN_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state, "\t"))


func load_run() -> Dictionary:
	if not FileAccess.file_exists(RUN_SAVE_PATH):
		return {}
	var file := FileAccess.open(RUN_SAVE_PATH, FileAccess.READ)
	if file:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		return parsed if parsed is Dictionary else {}
	return {}


func delete_run() -> void:
	if FileAccess.file_exists(RUN_SAVE_PATH):
		DirAccess.remove_absolute(RUN_SAVE_PATH)


func save_settings(settings: Dictionary) -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings, "\t"))


func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return _default_settings()
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		return parsed if parsed is Dictionary else {}
	return _default_settings()


func load_records() -> Dictionary:
	if not FileAccess.file_exists(RECORDS_PATH):
		return {"deepest_floor": 0, "total_runs": 0, "fastest_time": INF}
	var file := FileAccess.open(RECORDS_PATH, FileAccess.READ)
	if file:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		return parsed if parsed is Dictionary else {}
	return {"deepest_floor": 0, "total_runs": 0, "fastest_time": INF}


func update_records(deepest_floor: int, run_time: float) -> void:
	var records := load_records()
	if deepest_floor > records.get("deepest_floor", 0):
		records["deepest_floor"] = deepest_floor
	if run_time < records.get("fastest_time", INF):
		records["fastest_time"] = run_time
	records["total_runs"] = records.get("total_runs", 0) + 1
	var file := FileAccess.open(RECORDS_PATH, FileAccess.WRITE)
	if file:
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
	}


func get_total_runs() -> int:
	var records := load_records()
	return int(records.get("total_runs", 0))
