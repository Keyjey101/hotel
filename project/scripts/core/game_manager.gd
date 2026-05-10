extends Node

## GameManager — Global game state autoload
## Manages game state transitions, run lifecycle, and core signals.

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


func start_new_run() -> void:
	var run_seed := randi()
	seed_manager = SeedManager.new(run_seed)
	run_state = RunState.new()
	current_floor = starting_floor
	current_state = GameState.PLAYING
	run_started.emit(run_seed)
	floor_entered.emit(current_floor)
	print("[GameManager] Run started. Seed: %d" % run_seed)


func transition_to_floor(floor_number: int) -> void:
	floor_exited.emit(current_floor)
	current_floor = floor_number
	run_state.current_floor = floor_number
	floor_entered.emit(floor_number)
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
	print("[GameManager] Player captured. Entering basement.")


func handle_basement_success() -> void:
	current_state = GameState.PLAYING
	basement_escaped.emit()
	print("[GameManager] Basement escaped. Returning to floor %d" % current_floor)


func handle_basement_failure() -> void:
	current_state = GameState.GAME_OVER
	basement_failed.emit()
	run_ended.emit(false)
	print("[GameManager] Basement failed. Run over.")


func handle_victory() -> void:
	current_state = GameState.VICTORY
	run_ended.emit(true)
	print("[GameManager] Victory!")


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func unpause_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
