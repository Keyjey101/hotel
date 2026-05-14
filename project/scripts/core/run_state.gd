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
var cult_artifacts: Array = []           # [CultArtifact]
var collected_upgrade_ids: Array = []    # [String] — tracks upgrade stacking
var _upgrade_stack_counts: Dictionary = {}  # upgrade_id -> count
var rooms_cleared: Dictionary = {}      # "floor_room" -> bool
var mini_boss_defeated: Dictionary = {} # floor -> bool
var enemies_mutilated: int = 0
var limbs_severed: int = 0
var run_start_time: float = 0.0
var run_meta: Dictionary = {}  # arbitrary key-value flags for ending logic
var _paused_duration: float = 0.0

# Behavioral state
var second_wind_used: bool = false
var bloodlust_timer: float = 0.0
var bloodlust_stacks: int = 0

# Achievement counters (incremented via EventBus, committed to meta on run end)
var counters: Dictionary = {
	"dismembered_limbs": 0,
	"weapons_thrown": 0,
	"basements_escaped": 0,
	"no_damage_rooms": 0,
	"deals_with_demons": 0,
	"bosses_defeated": {},  # boss_id -> count
	"floors_no_damage": 0,  # consecutive rooms without damage
}


var _cleaned_up: bool = false

func _init() -> void:
	run_start_time = Time.get_ticks_msec() / 1000.0
	# Wire achievement counters to EventBus (deferred to handle autoload timing)
	_wire_events.call_deferred()


func _wire_events() -> void:
	if _cleaned_up:
		return
	if EventBus:
		if not EventBus.limb_severed.is_connected(_on_limb_severed):
			EventBus.limb_severed.connect(_on_limb_severed)
		if not EventBus.weapon_was_thrown.is_connected(_on_weapon_thrown):
			EventBus.weapon_was_thrown.connect(_on_weapon_thrown)
		if not EventBus.basement_was_escaped.is_connected(_on_basement_escaped):
			EventBus.basement_was_escaped.connect(_on_basement_escaped)
		if not EventBus.room_cleared_no_damage.is_connected(_on_room_no_damage):
			EventBus.room_cleared_no_damage.connect(_on_room_no_damage)
		if not EventBus.demon_deal_made.is_connected(_on_demon_deal):
			EventBus.demon_deal_made.connect(_on_demon_deal)
		if not EventBus.mini_boss_defeated.is_connected(_on_mini_boss_defeated):
			EventBus.mini_boss_defeated.connect(_on_mini_boss_defeated)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		cleanup()


func cleanup() -> void:
	_cleaned_up = true
	if EventBus:
		if EventBus.limb_severed.is_connected(_on_limb_severed):
			EventBus.limb_severed.disconnect(_on_limb_severed)
		if EventBus.weapon_was_thrown.is_connected(_on_weapon_thrown):
			EventBus.weapon_was_thrown.disconnect(_on_weapon_thrown)
		if EventBus.basement_was_escaped.is_connected(_on_basement_escaped):
			EventBus.basement_was_escaped.disconnect(_on_basement_escaped)
		if EventBus.room_cleared_no_damage.is_connected(_on_room_no_damage):
			EventBus.room_cleared_no_damage.disconnect(_on_room_no_damage)
		if EventBus.demon_deal_made.is_connected(_on_demon_deal):
			EventBus.demon_deal_made.disconnect(_on_demon_deal)
		if EventBus.mini_boss_defeated.is_connected(_on_mini_boss_defeated):
			EventBus.mini_boss_defeated.disconnect(_on_mini_boss_defeated)


func _on_limb_severed() -> void:
	counters["dismembered_limbs"] = int(counters.get("dismembered_limbs", 0)) + 1

func _on_weapon_thrown() -> void:
	counters["weapons_thrown"] = int(counters.get("weapons_thrown", 0)) + 1

func _on_basement_escaped() -> void:
	counters["basements_escaped"] = int(counters.get("basements_escaped", 0)) + 1

func _on_room_no_damage(_floor: int, _room: String) -> void:
	counters["no_damage_rooms"] = int(counters.get("no_damage_rooms", 0)) + 1

func _on_demon_deal() -> void:
	counters["deals_with_demons"] = int(counters.get("deals_with_demons", 0)) + 1

func _on_mini_boss_defeated(floor_number: int) -> void:
	var bd: Dictionary = counters.get("bosses_defeated", {})
	var key := "floor_%d_boss" % floor_number
	bd[key] = int(bd.get(key, 0)) + 1
	counters["bosses_defeated"] = bd


func apply_stat_upgrade(stat_name: String, value: float) -> void:
	var current: float = float(stat_upgrades.get(stat_name, 0.0))
	# Diminishing returns after 3 stacks (applied from 3rd stack onward)
	var stack_count: int = _upgrade_stack_counts.get(stat_name, 0)
	if stack_count > 2:
		value *= 0.5
	stat_upgrades[stat_name] = current + value
	_recalculate_stats()


func add_artifact(artifact: Resource) -> void:
	cult_artifacts.append(artifact)
	_recalculate_stats()


func apply_artifact(art: Resource) -> void:
	if art == null:
		return
	# Apply stat mods from artifact into stat_upgrades
	for key in art.stat_mods:
		var val = art.stat_mods[key]
		if val is float or val is int:
			stat_upgrades[key] = float(stat_upgrades.get(key, 0.0)) + float(val)
	# Note: does NOT append to cult_artifacts — use add_artifact() for that
	_recalculate_stats()


func apply_upgrade(upg: Resource) -> void:
	if upg == null:
		return
	collected_upgrade_ids.append(upg.id)
	_upgrade_stack_counts[upg.id] = _upgrade_stack_counts.get(upg.id, 0) + 1
	if upg.stat_key != "" and upg.behavioral_id == "":
		var stat_stack_key := upg.stat_key
		if stat_stack_key != upg.id:
			_upgrade_stack_counts[stat_stack_key] = _upgrade_stack_counts.get(stat_stack_key, 0) + 1
		apply_stat_upgrade(upg.stat_key, upg.delta)


func get_stack_count(upgrade_id: String) -> int:
	return _upgrade_stack_counts.get(upgrade_id, 0)


func get_artifact_stat(key: String, default: float = 0.0) -> float:
	return float(stat_upgrades.get(key, default))


func has_artifact(artifact_id: String) -> bool:
	for a in cult_artifacts:
		if a != null and a.get("id") != null and str(a.get("id")) == artifact_id:
			return true
	return false


func heal(amount: float) -> void:
	player_hp = minf(player_hp + amount, player_max_hp)


func get_run_time() -> float:
	return Time.get_ticks_msec() / 1000.0 - run_start_time - _paused_duration


func track_pause(delta: float) -> void:
	_paused_duration += delta


func to_dict() -> Dictionary:
	var elapsed_at_save := get_run_time()
	var d := {
		"current_floor": current_floor,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"player_speed": player_speed,
		"active_slot": active_slot,
		"stat_upgrades": stat_upgrades.duplicate(true),
		"collected_upgrade_ids": collected_upgrade_ids,
		"_upgrade_stack_counts": _upgrade_stack_counts,
		"enemies_mutilated": enemies_mutilated,
		"limbs_severed": limbs_severed,
		"elapsed_at_save": elapsed_at_save,
		"second_wind_used": second_wind_used,
		"rooms_cleared": {},
		"mini_boss_defeated": {},
		"weapon_slots": [],
		"cult_artifacts": [],
		"run_meta": {},
		"counters": counters.duplicate(true),
		"_paused_duration": _paused_duration,
		"bloodlust_timer": bloodlust_timer,
		"bloodlust_stacks": bloodlust_stacks,
	}
	for key in rooms_cleared:
		d["rooms_cleared"][key] = rooms_cleared[key]
	for key in mini_boss_defeated:
		d["mini_boss_defeated"][key] = mini_boss_defeated[key]
	for ws in weapon_slots:
		if ws == null:
			d["weapon_slots"].append(null)
		elif ws is Resource:
			d["weapon_slots"].append({"resource_path": ws.resource_path, "resource_name": ws.resource_name, "weapon_id": (ws.get("weapon_id") if ws.get("weapon_id") != null else "")})
		else:
			d["weapon_slots"].append(null)
	for artifact in cult_artifacts:
		if artifact is Resource:
			d["cult_artifacts"].append({"resource_path": artifact.resource_path, "resource_name": artifact.resource_name})
	for key in run_meta:
		d["run_meta"][key] = run_meta[key]
	return d


static func from_dict(d: Dictionary) -> RunState:
	if GameManager == null:
		push_warning("[RunState] from_dict called but GameManager is null — save data may be lost. Populating available fields.")
	elif GameManager.run_state != null and GameManager.run_state is RunState:
		GameManager.run_state.cleanup()
	var rs := RunState.new()
	rs.current_floor = d.get("current_floor", 1)
	rs.player_hp = d.get("player_hp", 100.0)
	rs.player_max_hp = d.get("player_max_hp", 100.0)
	rs.player_speed = d.get("player_speed", 200.0)
	rs.active_slot = d.get("active_slot", 0)
	rs.stat_upgrades = d.get("stat_upgrades", {})
	rs.collected_upgrade_ids = d.get("collected_upgrade_ids", [])
	rs.enemies_mutilated = d.get("enemies_mutilated", 0)
	rs.limbs_severed = d.get("limbs_severed", 0)
	# Restore elapsed time correctly across sessions
	var elapsed_at_save: float = d.get("elapsed_at_save", d.get("run_start_time", 0.0))
	rs.run_start_time = Time.get_ticks_msec() / 1000.0 - elapsed_at_save
	rs.second_wind_used = d.get("second_wind_used", false)
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
	# Dynamic resize: support Crown of Thorns 3-slot and future expansion
	var max_slots := maxi(ws_arr.size(), rs.weapon_slots.size())
	while rs.weapon_slots.size() < max_slots:
		rs.weapon_slots.append(null)
	for i in range(mini(ws_arr.size(), max_slots)):
		if ws_arr[i] == null:
			rs.weapon_slots[i] = null
		elif ws_arr[i] is Dictionary:
			var path: String = ws_arr[i].get("resource_path", "")
			if path.is_empty():
				var wid: String = ws_arr[i].get("weapon_id", "")
				if not wid.is_empty():
					path = "res://resources/weapons/%s.tres" % wid
			if not path.is_empty() and ResourceLoader.exists(path):
				rs.weapon_slots[i] = load(path)
	# Restore cult_artifacts
	var ca_arr: Array = d.get("cult_artifacts", [])
	for entry in ca_arr:
		if entry is Dictionary:
			var path: String = entry.get("resource_path", "")
			if not path.is_empty() and ResourceLoader.exists(path):
				rs.cult_artifacts.append(load(path))
	# Restore run_meta
	var rm: Dictionary = d.get("run_meta", {})
	for key in rm:
		rs.run_meta[key] = rm[key]
	# Restore counters
	var cnt: Dictionary = d.get("counters", {})
	for key in cnt:
		rs.counters[key] = cnt[key]
	rs._upgrade_stack_counts = d.get("_upgrade_stack_counts", {})
	rs._paused_duration = d.get("_paused_duration", 0.0)
	rs.bloodlust_timer = d.get("bloodlust_timer", 0.0)
	rs.bloodlust_stacks = d.get("bloodlust_stacks", 0)
	rs._recalculate_stats()
	# Safety: if the caller did not assign this RunState to GameManager.run_state,
	# clean up its signal connections to prevent EventBus leaks.
	if GameManager == null or GameManager.run_state != rs:
		rs.cleanup()
	return rs


func _recalculate_stats() -> void:
	player_max_hp = 100.0
	player_speed = 200.0

	# Apply stat upgrades
	for stat in stat_upgrades:
		match stat:
			"max_hp":
				player_max_hp += stat_upgrades[stat]
			"max_hp_mult":
				player_max_hp *= (1.0 + stat_upgrades[stat])
			"speed":
				player_speed *= 1.0 + stat_upgrades[stat]
			"move_speed_mult":
				player_speed *= (1.0 + stat_upgrades[stat])
			"damage_melee", "damage_ranged", "damage_throw":
				pass  # Applied at damage calculation time
			"damage_reduction", "hp_regen", "hp_regen_low", "kill_damage_buff":
				pass  # Applied in relevant systems

	# Artifact stat_mods are already merged into stat_upgrades by apply_artifact()
	# Additional artifact effects are checked at usage sites

	# Clamp
	player_max_hp = maxf(player_max_hp, 1.0)
	player_hp = minf(player_hp, player_max_hp)
	player_speed = maxf(player_speed, 50.0)



