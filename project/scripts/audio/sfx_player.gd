extends Node

## SFXPlayer — Pool-based SFX player with global and positional audio.
## Child node of AudioManager.

const GLOBAL_POOL_SIZE: int = 8
const POSITIONAL_POOL_SIZE: int = 4

const SFX_NAMES: Dictionary = {
	# Weapon
	"weapon_swing": true,
	"weapon_hit": true,
	"weapon_throw": true,
	"weapon_shoot": true,
	"weapon_throw_impact": true,
	"weapon_shatter": true,
	"weapon_discharge": true,
	# Enemy
	"enemy_alert": true,
	"enemy_hurt": true,
	"enemy_death": true,
	"enemy_regen": true,
	"enemy_grab": true,
	# Gore
	"limb_sever": true,
	"blood_splash": true,
	# Player
	"player_hurt": true,
	"player_heal": true,
	"player_death": true,
	# Environment
	"door_open": true,
	"door_close": true,
	"item_pickup": true,
	"floor_transition": true,
	"boss_unlock": true,
	# UI
	"ui_click": true,
	"ui_confirm": true,
	"ui_cancel": true,
	"ui_pause": true,
	"ui_prompt_show": true,
	"ui_damage_edge": true,
	"ui_floor_complete": true,
}

var _global_pool: Array[AudioStreamPlayer] = []
var _positional_pool: Array[AudioStreamPlayer2D] = []
var _silence_stream: AudioStream


func _ready() -> void:
	_silence_stream = _generate_silence()

	for i in GLOBAL_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFX_Global_%d" % i
		player.stream = _silence_stream
		add_child(player)
		_global_pool.append(player)

	for i in POSITIONAL_POOL_SIZE:
		var player := AudioStreamPlayer2D.new()
		player.name = "SFX_Positional_%d" % i
		player.stream = _silence_stream
		add_child(player)
		_positional_pool.append(player)


func play_sfx(name: String, volume_db: float = 0.0) -> void:
	if not SFX_NAMES.has(name):
		push_warning("[SFXPlayer] Unknown SFX: %s" % name)
		return
	var player := _get_available_global()
	if player == null:
		return
	player.pitch_scale = 1.0
	player.stop()
	player.volume_db = volume_db
	player.stream = _silence_stream
	player.play()


func play_sfx_2d(name: String, position: Vector2, volume_db: float = 0.0) -> void:
	if not SFX_NAMES.has(name):
		push_warning("[SFXPlayer] Unknown SFX 2D: %s" % name)
		return
	var player := _get_available_positional()
	if player == null:
		return
	player.pitch_scale = 1.0
	player.stop()
	player.position = position
	player.volume_db = volume_db
	player.stream = _silence_stream
	player.play()


func play_sfx_with_pitch(name: String, pitch: float) -> void:
	if not SFX_NAMES.has(name):
		push_warning("[SFXPlayer] Unknown SFX: %s" % name)
		return
	var player := _get_available_global()
	if player == null:
		return
	player.pitch_scale = pitch
	player.stream = _silence_stream
	player.play()


func _get_available_global() -> AudioStreamPlayer:
	for player in _global_pool:
		if not player.playing:
			return player
	# All busy — steal the first one
	_global_pool[0].stop()
	return _global_pool[0]


func _get_available_positional() -> AudioStreamPlayer2D:
	for player in _positional_pool:
		if not player.playing:
			return player
	_positional_pool[0].stop()
	return _positional_pool[0]


func _generate_silence() -> AudioStream:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 22050
	stream.data = PackedByteArray([0])
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = 1
	return stream
