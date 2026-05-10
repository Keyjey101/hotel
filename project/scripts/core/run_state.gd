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
	var current := stat_upgrades.get(stat_name, 0.0)
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
		if a.name == artifact_name:
			return true
	return false


func get_run_time() -> float:
	return Time.get_ticks_msec() / 1000.0 - run_start_time


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
