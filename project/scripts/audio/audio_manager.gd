extends Node

## AudioManager — Global autoload for dynamic music and SFX routing.
## Manages music state machine and delegates to MusicPlayer / SFXPlayer children.

signal music_track_changed(track_name: String)
signal sfx_played(sfx_name: String)

enum MusicState {
	SILENCE,
	EXPLORATION,
	TENSION,
	COMBAT,
	INTENSE,
	BOSS,
}

var current_music_state: MusicState = MusicState.SILENCE
var current_floor: int = 1

var _music_player: Node
var _sfx_player: Node

# Tension tracking
var _tension_timer: float = 0.0
var _enemy_damage_count: int = 0
var _engaged_enemies: int = 0
var _connections_made: bool = false


func _ready() -> void:
	_music_player = Node.new()
	_music_player.set_script(load("res://scripts/audio/music_player.gd"))
	_music_player.name = "MusicPlayer"
	add_child(_music_player)

	_sfx_player = Node.new()
	_sfx_player.set_script(load("res://scripts/audio/sfx_player.gd"))
	_sfx_player.name = "SFXPlayer"
	add_child(_sfx_player)

	_connect_events()


func _connect_events() -> void:
	if _connections_made:
		return
	# EventBus and GameManager are autoloads — check they exist
	if not _has_autoload("EventBus"):
		# In test mode, autoloads may not be available
		return
	if not _has_autoload("GameManager"):
		return

	var event_bus: Node = _get_autoload("EventBus")
	var game_manager: Node = _get_autoload("GameManager")

	if event_bus and event_bus.has_signal("room_entered") and not event_bus.room_entered.is_connected(_on_room_entered):
		event_bus.room_entered.connect(_on_room_entered)
	if event_bus and event_bus.has_signal("enemy_damaged") and not event_bus.enemy_damaged.is_connected(_on_enemy_damaged):
		event_bus.enemy_damaged.connect(_on_enemy_damaged)
	if event_bus and event_bus.has_signal("room_cleared") and not event_bus.room_cleared.is_connected(_on_room_cleared):
		event_bus.room_cleared.connect(_on_room_cleared)
	if event_bus and event_bus.has_signal("player_damaged") and not event_bus.player_damaged.is_connected(_on_player_damaged):
		event_bus.player_damaged.connect(_on_player_damaged)
	if event_bus and event_bus.has_signal("mini_boss_defeated") and not event_bus.mini_boss_defeated.is_connected(_on_mini_boss_defeated):
		event_bus.mini_boss_defeated.connect(_on_mini_boss_defeated)
	if event_bus and event_bus.has_signal("floor_completed") and not event_bus.floor_completed.is_connected(_on_floor_completed):
		event_bus.floor_completed.connect(_on_floor_completed)
	if game_manager and game_manager.has_signal("run_started") and not game_manager.run_started.is_connected(_on_run_started):
		game_manager.run_started.connect(_on_run_started)
	if game_manager and game_manager.has_signal("player_died") and not game_manager.player_died.is_connected(_on_player_died):
		game_manager.player_died.connect(_on_player_died)
	if game_manager and game_manager.has_signal("run_ended") and not game_manager.run_ended.is_connected(_on_run_ended):
		game_manager.run_ended.connect(_on_run_ended)

	_connections_made = true


func _has_autoload(name: String) -> bool:
	return get_tree().root.has_node(name)


func _get_autoload(name: String) -> Node:
	if _has_autoload(name):
		return get_tree().root.get_node(name)
	return null


# === EventBus handlers ===

func _on_room_entered(floor_number: int, _room_name: String) -> void:
	current_floor = floor_number
	if current_music_state == MusicState.SILENCE:
		_transition_to(MusicState.EXPLORATION)
		_music_player.play_exploration(floor_number)


func _on_enemy_damaged(_enemy: CharacterBody2D, _zone: int, _damage: float) -> void:
	_enemy_damage_count += 1
	match current_music_state:
		MusicState.EXPLORATION:
			_transition_to(MusicState.TENSION)
			_tension_timer = 1.5
			_enemy_damage_count = 1
		MusicState.TENSION:
			if _enemy_damage_count >= 2:
				_transition_to(MusicState.COMBAT)
				_music_player.play_combat(current_floor)
				_tension_timer = 0.0
		MusicState.COMBAT:
			_engaged_enemies += 1
			if _engaged_enemies >= 3:
				_transition_to(MusicState.INTENSE)
		MusicState.INTENSE:
			pass


var _music_transition_timer: SceneTreeTimer = null


func _on_room_cleared(_floor_number: int, _room_name: String) -> void:
	_enemy_damage_count = 0
	_engaged_enemies = 0
	if _music_transition_timer != null and is_instance_valid(_music_transition_timer):
		_music_transition_timer.timeout.disconnect(_on_music_transition_timeout)
	_music_transition_timer = get_tree().create_timer(2.0)
	_music_transition_timer.timeout.connect(_on_music_transition_timeout)


func _on_music_transition_timeout() -> void:
	_transition_to(MusicState.EXPLORATION)
	_music_player.play_exploration(current_floor)


func _on_player_damaged(_amount: float) -> void:
	pass


func _on_mini_boss_defeated(_floor_number: int) -> void:
	if current_music_state == MusicState.BOSS:
		_transition_to(MusicState.EXPLORATION)
		_music_player.play_exploration(current_floor)


func _on_floor_completed(_floor_number: int) -> void:
	pass


# === GameManager handlers ===

func _on_run_started(_run_seed: int) -> void:
	_transition_to(MusicState.SILENCE)


func _on_player_died() -> void:
	_music_player.stop_all(1.0)
	_transition_to(MusicState.SILENCE)


func _on_run_ended(_victory: bool) -> void:
	_music_player.stop_all(2.0)
	_transition_to(MusicState.SILENCE)


# === State machine ===

func _transition_to(new_state: MusicState) -> void:
	current_music_state = new_state


# === Boss entry ===

func enter_boss_mode() -> void:
	_transition_to(MusicState.BOSS)
	_music_player.play_boss()


# === Process for tension timer ===

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	if _tension_timer > 0.0:
		_tension_timer -= delta
		if _tension_timer <= 0.0 and current_music_state == MusicState.TENSION:
			_transition_to(MusicState.EXPLORATION)
			_enemy_damage_count = 0
