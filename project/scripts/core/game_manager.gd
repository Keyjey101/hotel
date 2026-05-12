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

enum GameState {
	MENU,
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Start on title screen
	_load_title_screen()


func _load_title_screen() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")


func start_new_run() -> void:
	var run_seed := randi()
	seed_manager = SeedManager.new(run_seed)
	run_state = RunState.new()
	current_floor = starting_floor
	current_state = GameState.PLAYING

	# Give starting loadout: Machete (slot 1) + Sawed-off (slot 2)
	_loot_spawner_script.give_starting_loadout(run_state)

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
	basement_escaped.emit()
	SaveManager.save_run(run_state.to_dict())
	print("[GameManager] Basement escaped. Returning to floor %d" % current_floor)


func handle_basement_failure() -> void:
	current_state = GameState.GAME_OVER
	basement_failed.emit()
	run_ended.emit(false)
	# Update records
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


func handle_victory() -> void:
	current_state = GameState.VICTORY
	run_ended.emit(true)
	SaveManager.update_records(current_floor, run_state.get_run_time())
	SaveManager.delete_run()
	get_tree().change_scene_to_file("res://scenes/ui/demo_complete.tscn")
	print("[GameManager] Victory!")


func trigger_ending(ending_id: String) -> void:
	current_state = GameState.VICTORY
	run_ended.emit(true)
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
		if run_state.get_meta("player_embraced", false):
			ending_id = "d"
		elif run_state.get_meta("sister_never_attacked", false):
			ending_id = "c"
		elif run_state.get_meta("sister_spared", false):
			ending_id = "b"
		else:
			ending_id = "a"
	trigger_ending(ending_id)


func restart_run() -> void:
	# Clear run state
	current_state = GameState.MENU
	current_floor = 1
	run_state = null
	seed_manager = null
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
