extends Node

## MusicPlayer — Crossfade music player for exploration/combat/boss tracks.
## Child node of AudioManager.

const FLOOR_BPM: Dictionary = {
	1: {"explore": 80, "combat": 110},
	2: {"explore": 100, "combat": 130},
	3: {"explore": 140, "combat": 120},
	4: {"explore": 120, "combat": 150},
	5: {"explore": 60, "combat": 80},
	6: {"explore": 160, "combat": 180},
	7: {"explore": 0, "combat": 0},      # Arrhythmic (ambient cosmic horror)
	8: {"explore": 130, "combat": 160},
	9: {"explore": 0, "combat": 0},      # Special per-phase handling
}

# Crossfade durations (seconds)
const CROSSFADE_EXPLORE_TO_COMBAT: float = 0.5
const CROSSFADE_COMBAT_TO_INTENSE: float = 1.0
const CROSSFADE_COMBAT_TO_EXPLORE: float = 2.0
const CROSSFADE_EXPLORE_TO_BOSS: float = 3.0

var _exploration: AudioStreamPlayer
var _combat: AudioStreamPlayer
var _boss: AudioStreamPlayer
var _silence_stream: AudioStream
var _active_player: AudioStreamPlayer
var _crossfade_tween: Tween = null


func _ready() -> void:
	_silence_stream = _generate_silence()

	_exploration = AudioStreamPlayer.new()
	_exploration.name = "ExplorationPlayer"
	_exploration.stream = _silence_stream
	add_child(_exploration)

	_combat = AudioStreamPlayer.new()
	_combat.name = "CombatPlayer"
	_combat.stream = _silence_stream
	add_child(_combat)

	_boss = AudioStreamPlayer.new()
	_boss.name = "BossPlayer"
	_boss.stream = _silence_stream
	add_child(_boss)

	_active_player = _exploration


func play_exploration(floor: int) -> void:
	_combat.stop()
	_boss.stop()
	_exploration.stream = _silence_stream
	_exploration.volume_db = 0.0
	_exploration.play()
	_active_player = _exploration


func play_combat(floor: int) -> void:
	if _exploration.playing:
		_crossfade(_exploration, _combat, CROSSFADE_EXPLORE_TO_COMBAT)
	else:
		_combat.stream = _silence_stream
		_combat.volume_db = 0.0
		_combat.play()
	_active_player = _combat


func play_boss() -> void:
	if _active_player and _active_player.playing:
		_crossfade(_active_player, _boss, CROSSFADE_EXPLORE_TO_BOSS)
	else:
		_boss.stream = _silence_stream
		_boss.volume_db = 0.0
		_boss.play()
	_active_player = _boss


func stop_all(fade_time: float) -> void:
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
	var players := [_exploration, _combat, _boss]
	for player in players:
		if player and player.playing:
			if fade_time > 0.0:
				var tween := create_tween()
				tween.tween_property(player, "volume_db", -80.0, fade_time)
				tween.tween_callback(player.stop)
			else:
				player.stop()
				player.volume_db = 0.0
	_active_player = null


func play_floor09_phase(phase: int) -> void:
	if phase < 1 or phase > 4:
		return
	# Phase 1: silence + single piano note loop (8s)
	# Phase 2: heartbeat + music box (layer in over 5s)
	# Phase 3: ALL previous floor styles layered (chaos, 2s crossfade per layer)
	# Phase 4: silence → bass drop → noise → silence (one-shot)
	# All phases use placeholder silence for now
	match phase:
		1:
			stop_all(0.5)
			_exploration.stream = _silence_stream
			_exploration.play()
		2:
			_combat.stream = _silence_stream
			_combat.play()
		3:
			_boss.stream = _silence_stream
			_boss.play()
		4:
			stop_all(0.0)
			_exploration.stream = _silence_stream
			_exploration.play()


func _crossfade(from: AudioStreamPlayer, to: AudioStreamPlayer, duration: float) -> void:
	to.stream = _silence_stream
	to.volume_db = -80.0
	to.play()

	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
	_crossfade_tween = create_tween()
	_crossfade_tween.set_parallel(true)
	_crossfade_tween.tween_property(from, "volume_db", -80.0, duration)
	_crossfade_tween.tween_property(to, "volume_db", 0.0, duration)
	_crossfade_tween.set_parallel(false)
	_crossfade_tween.tween_callback(from.stop)
	_crossfade_tween.tween_callback(func(): from.volume_db = 0.0)


func _generate_silence() -> AudioStream:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.data = PackedByteArray([0])
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = 1
	return stream
