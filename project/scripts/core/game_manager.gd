extends Node

## GameManager — Global game state autoload
## Manages game state transitions, run lifecycle, and core signals.

# Lazy-loaded script references (avoids parse-order issues with class_name)
var _loot_spawner_script: GDScript:
	get:
		if _loot_spawner_script == null:
			_loot_spawner_script = load("res://scripts/world/loot_spawner.gd")
		return _loot_spawner_script

signal run_started(run_seed: int)
signal run_ended(victory: bool)
signal floor_entered(floor_number: int)
signal floor_exited(floor_number: int)
signal player_died
signal player_captured
signal basement_entered
signal basement_escaped
signal basement_failed
signal artifact_unlocked(artifact_id: String)
signal stat_upgrade_unlocked(upgrade_id: String)

enum GameState {
	MENU,
	LOADOUT,
	PLAYING,
	BASEMENT,
	PAUSED,
	GAME_OVER,
	VICTORY,
}

@export var starting_floor: int = 1

var current_state: GameState = GameState.MENU
var current_floor: int = 1
var run_state: RunState
var seed_manager: SeedManager

# Pending unlocks — only committed to meta on run end (victory/failure)
var _pending_artifact_unlocks: Array[String] = []
var _pending_stat_unlocks: Array[String] = []
var _mini_boss_floors_cleared: Array[int] = []
var _basement_escaped_this_run: bool = false

# Selected loadout from loadout screen
var selected_starting_upgrade: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SaveManager.load_and_apply_settings()
	# Start on title screen
	_load_title_screen()


func _load_title_screen() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")


func show_loadout() -> void:
	current_state = GameState.LOADOUT
	get_tree().change_scene_to_file("res://scenes/ui/loadout_screen.tscn")


func start_new_run() -> void:
	var run_seed := randi()
	seed_manager = SeedManager.new(run_seed)
	run_state = RunState.new()
	current_floor = starting_floor
	current_state = GameState.PLAYING

	# Give starting loadout: Machete (slot 1) + Sawed-off (slot 2)
	_loot_spawner_script.give_starting_loadout(run_state)

	# Apply chosen starting stat upgrade
	if selected_starting_upgrade != "" and UpgradeRegistry:
		var upg := UpgradeRegistry.get_upgrade(selected_starting_upgrade)
		if upg:
			run_state.apply_upgrade(upg)

	# Reset pending unlocks for this run
	_pending_artifact_unlocks.clear()
	_pending_stat_unlocks.clear()
	_mini_boss_floors_cleared.clear()
	_basement_escaped_this_run = false

	run_started.emit(run_seed)
	floor_entered.emit(current_floor)

	# Save run state
	SaveManager.save_run(run_state.to_dict())

	# Load Floor 1
	get_tree().change_scene_to_file("res://scenes/floors/floor_01.tscn")
	print("[GameManager] Run started. Seed: %d" % run_seed)


func transition_to_floor(floor_number: int) -> void:
	floor_exited.emit(current_floor)
	current_floor = floor_number
	run_state.current_floor = floor_number
	floor_entered.emit(floor_number)

	# Check unlock conditions for reaching this floor
	_check_floor_unlocks(floor_number)

	# Save on floor transition
	SaveManager.save_run(run_state.to_dict())

	# Load floor scene (M4: only floor_01, others added in M6+)
	var scene_path := "res://scenes/floors/floor_%02d.tscn" % floor_number
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		push_warning("[GameManager] Floor scene not found: %s" % scene_path)
		get_tree().change_scene_to_file("res://scenes/floors/floor_01.tscn")

	print("[GameManager] Transitioned to floor %d" % floor_number)


func handle_player_death() -> void:
	if current_state != GameState.PLAYING:
		return
	player_died.emit()
	player_captured.emit()
	transition_to_basement()


func transition_to_basement() -> void:
	current_state = GameState.BASEMENT
	basement_entered.emit()
	get_tree().change_scene_to_file("res://scenes/basement/basement.tscn")
	print("[GameManager] Player captured. Entering basement.")


func handle_basement_success() -> void:
	current_state = GameState.PLAYING
	_basement_escaped_this_run = true
	basement_escaped.emit()
	SaveManager.save_run(run_state.to_dict())
	# Check basement-related unlocks
	_check_basement_unlocks()
	print("[GameManager] Basement escaped. Returning to floor %d" % current_floor)


func handle_basement_failure() -> void:
	current_state = GameState.GAME_OVER
	basement_failed.emit()
	run_ended.emit(false)
	# Commit pending unlocks (run ended)
	_commit_run_end("")
	SaveManager.update_records(current_floor, run_state.get_run_time())
	SaveManager.delete_run()
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
	print("[GameManager] Basement failed. Run over.")


func handle_floor_completed(floor_num: int) -> void:
	if floor_num >= 9:
		handle_victory()
		return
	# Transition to next floor
	transition_to_floor(floor_num + 1)


func handle_mini_boss_cleared(floor_num: int) -> void:
	_mini_boss_floors_cleared.append(floor_num)
	_check_mini_boss_unlocks(floor_num)


func handle_victory() -> void:
	current_state = GameState.VICTORY
	run_ended.emit(true)
	# Commit pending unlocks with ending info
	var ending_id := ""
	if run_state:
		if run_state.run_meta.get("player_embraced", false):
			ending_id = "d"
		elif run_state.run_meta.get("sister_never_attacked", false):
			ending_id = "c"
		elif run_state.run_meta.get("sister_spared", false):
			ending_id = "b"
		else:
			ending_id = "a"
	_commit_run_end(ending_id)
	SaveManager.update_records(current_floor, run_state.get_run_time())
	SaveManager.delete_run()
	get_tree().change_scene_to_file("res://scenes/ui/demo_complete.tscn")
	print("[GameManager] Victory!")


func trigger_ending(ending_id: String) -> void:
	current_state = GameState.VICTORY
	run_ended.emit(true)
	_commit_run_end(ending_id)
	SaveManager.update_records(current_floor, run_state.get_run_time())
	SaveManager.delete_run()
	var scene_path := "res://scenes/endings/ending_%s.tscn" % ending_id
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/demo_complete.tscn")
	print("[GameManager] Ending triggered: %s" % ending_id)


func handle_final_boss_defeated() -> void:
	# Determine ending based on run_state flags
	var ending_id := "a"
	if run_state:
		if run_state.run_meta.get("player_embraced", false):
			ending_id = "d"
		elif run_state.run_meta.get("sister_never_attacked", false):
			ending_id = "c"
		elif run_state.run_meta.get("sister_spared", false):
			ending_id = "b"
		else:
			ending_id = "a"
	trigger_ending(ending_id)


func restart_run() -> void:
	# Clear run state (pending unlocks are DISCARDED — no free unlocks)
	current_state = GameState.MENU
	current_floor = 1
	run_state = null
	seed_manager = null
	_pending_artifact_unlocks.clear()
	_pending_stat_unlocks.clear()
	_mini_boss_floors_cleared.clear()
	_basement_escaped_this_run = false
	selected_starting_upgrade = ""
	SaveManager.delete_run()
	_load_title_screen()


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func unpause_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false


# === Unlock condition checks ===

func _check_floor_unlocks(floor_num: int) -> void:
	var meta := SaveManager.get_meta()
	var unlocked_artifacts: Array = meta.get("unlocked_artifacts", [])
	var unlocked_stats: Array = meta.get("unlocked_starting_stat_upgrades", [])
	var runs: int = int(meta.get("runs_completed", 0))

	# --- Artifact unlocks by floor ---
	# Floor 3 → a6_golden_hand (rare)
	if floor_num >= 3 and not _is_unlocked(unlocked_artifacts, "a6_golden_hand"):
		_pending_unlock_artifact("a6_golden_hand", "Golden Hand")
	# Floor 5 → a4_hunger_blade (rare)
	if floor_num >= 5 and not _is_unlocked(unlocked_artifacts, "a4_hunger_blade"):
		_pending_unlock_artifact("a4_hunger_blade", "Hunger Blade")
	# Floor 7 → a10_demon_heart (cursed)
	if floor_num >= 7 and not _is_unlocked(unlocked_artifacts, "a10_demon_heart"):
		_pending_unlock_artifact("a10_demon_heart", "Demon Heart")
	# Floor 9 → a12_void_contract (cursed)
	if floor_num >= 9 and not _is_unlocked(unlocked_artifacts, "a12_void_contract"):
		_pending_unlock_artifact("a12_void_contract", "Void Contract")
	# 2 runs completed → a9_third_eye
	if runs >= 2 and not _is_unlocked(unlocked_artifacts, "a9_third_eye"):
		_pending_unlock_artifact("a9_third_eye", "Third Eye")

	# --- Stat upgrade unlocks by floor ---
	# Floor 3 → s5_sure_shot
	if floor_num >= 3 and not _is_unlocked(unlocked_stats, "s5_sure_shot"):
		_pending_unlock_stat("s5_sure_shot", "Sure Shot")
	# Floor 5 → s3_iron_skin
	if floor_num >= 5 and not _is_unlocked(unlocked_stats, "s3_iron_skin"):
		_pending_unlock_stat("s3_iron_skin", "Iron Skin")
	# Floor 7 → s6_heavy_arm
	if floor_num >= 7 and not _is_unlocked(unlocked_stats, "s6_heavy_arm"):
		_pending_unlock_stat("s6_heavy_arm", "Heavy Arm")
	# Floor 9 → s11_bloodlust
	if floor_num >= 9 and not _is_unlocked(unlocked_stats, "s11_bloodlust"):
		_pending_unlock_stat("s11_bloodlust", "Bloodlust")
	# 1 run completed → s2_swift_step
	if runs >= 1 and not _is_unlocked(unlocked_stats, "s2_swift_step"):
		_pending_unlock_stat("s2_swift_step", "Swift Step")
	# 2 runs completed → s7_quick_hands
	if runs >= 2 and not _is_unlocked(unlocked_stats, "s7_quick_hands"):
		_pending_unlock_stat("s7_quick_hands", "Quick Hands")
	# 3 runs completed → s9_second_wind
	if runs >= 3 and not _is_unlocked(unlocked_stats, "s9_second_wind"):
		_pending_unlock_stat("s9_second_wind", "Second Wind")


func _check_mini_boss_unlocks(floor_num: int) -> void:
	var meta := SaveManager.get_meta()
	var unlocked_artifacts: Array = meta.get("unlocked_artifacts", [])
	var unlocked_stats: Array = meta.get("unlocked_starting_stat_upgrades", [])

	# Any mini-boss → a7_ring_of_wrath
	if not _is_unlocked(unlocked_artifacts, "a7_ring_of_wrath"):
		_pending_unlock_artifact("a7_ring_of_wrath", "Ring of Wrath")
	# Any mini-boss → s10_ammo_pouch
	if not _is_unlocked(unlocked_stats, "s10_ammo_pouch"):
		_pending_unlock_stat("s10_ammo_pouch", "Ammo Pouch")
	# Floor 5 mini-boss → a8_pact_of_flesh
	if floor_num >= 5 and not _is_unlocked(unlocked_artifacts, "a8_pact_of_flesh"):
		_pending_unlock_artifact("a8_pact_of_flesh", "Pact of Flesh")


func _check_basement_unlocks() -> void:
	var meta := SaveManager.get_meta()
	var unlocked_artifacts: Array = meta.get("unlocked_artifacts", [])
	var unlocked_stats: Array = meta.get("unlocked_starting_stat_upgrades", [])

	# Escape basement once → a11_crown_of_thorns
	if not _is_unlocked(unlocked_artifacts, "a11_crown_of_thorns"):
		_pending_unlock_artifact("a11_crown_of_thorns", "Crown of Thorns")
	# Escape basement once → s8_steady_grip
	if not _is_unlocked(unlocked_stats, "s8_steady_grip"):
		_pending_unlock_stat("s8_steady_grip", "Steady Grip")


func _pending_unlock_artifact(id: String, display_name: String) -> void:
	if _pending_artifact_unlocks.has(id):
		return
	_pending_artifact_unlocks.append(id)
	artifact_unlocked.emit(id)
	_show_unlock_toast("Artifact unlocked: %s" % display_name)
	print("[GameManager] Pending artifact unlock: %s" % id)


func _pending_unlock_stat(id: String, display_name: String) -> void:
	if _pending_stat_unlocks.has(id):
		return
	_pending_stat_unlocks.append(id)
	stat_upgrade_unlocked.emit(id)
	_show_unlock_toast("Upgrade unlocked: %s" % display_name)
	print("[GameManager] Pending stat upgrade unlock: %s" % id)


func _show_unlock_toast(message: String) -> void:
	# Instance toast overlay if in a valid scene
	var tree := get_tree()
	if tree and tree.current_scene:
		var toast := load("res://scripts/ui/unlock_toast.gd").new()
		tree.current_scene.add_child(toast)
		toast.show_toast(message)


func _is_unlocked(unlocked_list: Array, id: String) -> bool:
	return unlocked_list.has(id) or _pending_artifact_unlocks.has(id) or _pending_stat_unlocks.has(id)


func _commit_run_end(ending_id: String) -> void:
	if run_state == null:
		return
	var counters: Dictionary = {}
	counters.merge(run_state.counters)
	SaveManager.commit_pending_unlocks(
		_pending_artifact_unlocks.duplicate(),
		_pending_stat_unlocks.duplicate(),
		counters,
		current_floor,
		ending_id,
	)
	_pending_artifact_unlocks.clear()
	_pending_stat_unlocks.clear()
