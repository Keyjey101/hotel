class_name RunState
extends RefCounted

## RunState — Per-run state tracking. No persistence between runs (roguelike).

var current_floor: int = 1
var player_hp: float = 100.0
var player_max_hp: float = 100.0
var player_speed: float = 200.0
var weapon_slots: Array = [null, null]  # [WeaponData, WeaponData]
var active_slot: int = 0
var stat_upgrades: Dictionary = {}      # stat_name -> accumulated value
var cult_artifacts: Array = []           # [CultArtifactData]
var rooms_cleared: Dictionary = {}      # "floor_room" -> bool
var mini_boss_defeated: Dictionary = {} # floor -> bool
var enemies_mutilated: int = 0
var limbs_severed: int = 0
var run_start_time: float = 0.0


func _init() -> void:
	run_start_time = Time.get_ticks_msec() / 1000.0


func apply_stat_upgrade(stat_name: String, value: float) -> void:
	var current: float = float(stat_upgrades.get(stat_name, 0.0))
	# Diminishing returns after 2 stacks
	var stack_count := int(current / _base_value(stat_name))
	if stack_count >= 2:
		value *= 0.5
	stat_upgrades[stat_name] = current + value
	_recalculate_stats()


func add_artifact(artifact: Resource) -> void:
	cult_artifacts.append(artifact)
	_recalculate_stats()


func has_artifact(artifact_name: String) -> bool:
	for a in cult_artifacts:
		var a_name: String = a.resource_name if a is Resource else ""
		if a_name == artifact_name:
			return true
	return false


func get_run_time() -> float:
	return Time.get_ticks_msec() / 1000.0 - run_start_time


func to_dict() -> Dictionary:
	var d := {
		"current_floor": current_floor,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"player_speed": player_speed,
		"active_slot": active_slot,
		"stat_upgrades": stat_upgrades,
		"enemies_mutilated": enemies_mutilated,
		"limbs_severed": limbs_severed,
		"run_start_time": run_start_time,
		"rooms_cleared": {},
		"mini_boss_defeated": {},
		"weapon_slots": [],
		"cult_artifacts": [],
	}
	for key in rooms_cleared:
		d["rooms_cleared"][key] = rooms_cleared[key]
	for key in mini_boss_defeated:
		d["mini_boss_defeated"][key] = mini_boss_defeated[key]
	for ws in weapon_slots:
		if ws == null:
			d["weapon_slots"].append(null)
		elif ws is Resource:
			d["weapon_slots"].append({"resource_path": ws.resource_path, "resource_name": ws.resource_name})
		else:
			d["weapon_slots"].append(null)
	for artifact in cult_artifacts:
		if artifact is Resource:
			d["cult_artifacts"].append({"resource_path": artifact.resource_path, "resource_name": artifact.resource_name})
	return d


static func from_dict(d: Dictionary) -> RunState:
	var script := load("res://scripts/core/run_state.gd")
	var rs = script.new()
	rs.current_floor = d.get("current_floor", 1)
	rs.player_hp = d.get("player_hp", 100.0)
	rs.player_max_hp = d.get("player_max_hp", 100.0)
	rs.player_speed = d.get("player_speed", 200.0)
	rs.active_slot = d.get("active_slot", 0)
	rs.stat_upgrades = d.get("stat_upgrades", {})
	rs.enemies_mutilated = d.get("enemies_mutilated", 0)
	rs.limbs_severed = d.get("limbs_severed", 0)
	rs.run_start_time = d.get("run_start_time", 0.0)
	# Restore rooms_cleared
	var rc: Dictionary = d.get("rooms_cleared", {})
	for key in rc:
		rs.rooms_cleared[key] = rc[key]
	# Restore mini_boss_defeated
	var mbd: Dictionary = d.get("mini_boss_defeated", {})
	for key in mbd:
		rs.mini_boss_defeated[key] = mbd[key]
	# Restore weapon_slots
	var ws_arr: Array = d.get("weapon_slots", [null, null])
	for i in range(mini(ws_arr.size(), 2)):
		if ws_arr[i] == null:
			rs.weapon_slots[i] = null
		elif ws_arr[i] is Dictionary:
			var path: String = ws_arr[i].get("resource_path", "")
			if not path.is_empty() and ResourceLoader.exists(path):
				rs.weapon_slots[i] = load(path)
	# Restore cult_artifacts
	var ca_arr: Array = d.get("cult_artifacts", [])
	for entry in ca_arr:
		if entry is Dictionary:
			var path: String = entry.get("resource_path", "")
			if not path.is_empty() and ResourceLoader.exists(path):
				rs.cult_artifacts.append(load(path))
	rs._recalculate_stats()
	return rs


func _recalculate_stats() -> void:
	player_max_hp = 100.0
	player_speed = 200.0

	# Apply stat upgrades
	for stat in stat_upgrades:
		match stat:
			"max_hp":
				player_max_hp += stat_upgrades[stat]
			"speed":
				player_speed *= 1.0 + stat_upgrades[stat]
			"damage_melee", "damage_ranged", "damage_throw":
				pass  # Applied at damage calculation time

	# Apply artifact modifiers
	for artifact in cult_artifacts:
		if not artifact is Resource:
			continue
		# Each artifact applies its own modifiers via the combat system
		# Stats are checked directly in damage/movement calculations

	# Clamp
	player_max_hp = maxf(player_max_hp, 1.0)
	player_speed = maxf(player_speed, 50.0)


func _base_value(stat_name: String) -> float:
	match stat_name:
		"max_hp": return 25.0
		"speed": return 0.12
		"damage_melee": return 0.20
		"damage_ranged": return 0.20
		"damage_throw": return 0.25
		"damage_reduction": return 0.15
		"grab_resist": return 0.30
		"pickup_speed": return 0.20
		"ammo_bonus": return 0.50
		_: return 1.0
