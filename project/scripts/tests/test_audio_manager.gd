extends "res://scripts/tests/test_base.gd"

## TestAudioManager — Tests for AudioManager autoload, MusicPlayer, SFXPlayer.


# ============================================================
# Step 1: AudioManager skeleton
# ============================================================

func test_audio_manager_registered_as_autoload() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load("res://project.godot")
	assert_eq(err, OK, "project.godot loads")
	var autoloads := cfg.get_section_keys("autoload")
	assert_true("AudioManager" in autoloads, "AudioManager in autoloads")


func test_audio_manager_script_loads() -> void:
	var script := load("res://scripts/audio/audio_manager.gd")
	assert_ne(script, null, "audio_manager.gd loads without errors")


func test_music_state_enum_has_6_values() -> void:
	var script := load("res://scripts/audio/audio_manager.gd")
	var constants: Dictionary = script.get_script_constant_map()
	assert_true(constants.has("MusicState"), "MusicState constant exists")

	var ms: Dictionary = constants["MusicState"]
	assert_eq(ms.SILENCE, 0, "MusicState.SILENCE == 0")
	assert_eq(ms.EXPLORATION, 1, "MusicState.EXPLORATION == 1")
	assert_eq(ms.TENSION, 2, "MusicState.TENSION == 2")
	assert_eq(ms.COMBAT, 3, "MusicState.COMBAT == 3")
	assert_eq(ms.INTENSE, 4, "MusicState.INTENSE == 4")
	assert_eq(ms.BOSS, 5, "MusicState.BOSS == 5")


func test_music_track_changed_signal_exists() -> void:
	var script := load("res://scripts/audio/audio_manager.gd")
	var signals: Array = []
	for s in script.get_script_signal_list():
		signals.append(s["name"])
	assert_true("music_track_changed" in signals, "music_track_changed signal exists")


func test_sfx_played_signal_exists() -> void:
	var script := load("res://scripts/audio/audio_manager.gd")
	var signals: Array = []
	for s in script.get_script_signal_list():
		signals.append(s["name"])
	assert_true("sfx_played" in signals, "sfx_played signal exists")


func test_audio_manager_has_transition_method() -> void:
	var script := load("res://scripts/audio/audio_manager.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("_transition_to" in methods, "_transition_to method exists")
	assert_true("enter_boss_mode" in methods, "enter_boss_mode method exists")


# ============================================================
# Step 2: MusicPlayer
# ============================================================

func test_music_player_script_loads() -> void:
	var script := load("res://scripts/audio/music_player.gd")
	assert_ne(script, null, "music_player.gd loads without errors")


func test_music_player_has_play_methods() -> void:
	var script := load("res://scripts/audio/music_player.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("play_exploration" in methods, "play_exploration method exists")
	assert_true("play_combat" in methods, "play_combat method exists")
	assert_true("play_boss" in methods, "play_boss method exists")
	assert_true("stop_all" in methods, "stop_all method exists")


func test_floor_bpm_has_keys_1_to_9() -> void:
	var script := load("res://scripts/audio/music_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	assert_true(constants.has("FLOOR_BPM"), "FLOOR_BPM constant exists")
	var bpm: Dictionary = constants["FLOOR_BPM"]
	for i in range(1, 10):
		assert_true(bpm.has(i), "FLOOR_BPM has key %d" % i)


func test_floor_bpm_explore_and_combat_values() -> void:
	var script := load("res://scripts/audio/music_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	var bpm: Dictionary = constants["FLOOR_BPM"]
	# Floor 1: explore 80, combat 110
	assert_has(bpm[1], "explore", "Floor 1 has explore")
	assert_has(bpm[1], "combat", "Floor 1 has combat")
	assert_eq(bpm[1]["explore"], 80, "Floor 1 explore BPM == 80")
	assert_eq(bpm[1]["combat"], 110, "Floor 1 combat BPM == 110")
	# Floor 2: explore 100, combat 130
	assert_eq(bpm[2]["explore"], 100, "Floor 2 explore BPM == 100")
	assert_eq(bpm[2]["combat"], 130, "Floor 2 combat BPM == 130")
	# Floor 3: explore 140, combat 120
	assert_eq(bpm[3]["explore"], 140, "Floor 3 explore BPM == 140")
	assert_eq(bpm[3]["combat"], 120, "Floor 3 combat BPM == 120")
	# Floor 4: explore 120, combat 150
	assert_eq(bpm[4]["explore"], 120, "Floor 4 explore BPM == 120")
	assert_eq(bpm[4]["combat"], 150, "Floor 4 combat BPM == 150")
	# Floor 5: explore 60, combat 80
	assert_eq(bpm[5]["explore"], 60, "Floor 5 explore BPM == 60")
	assert_eq(bpm[5]["combat"], 80, "Floor 5 combat BPM == 80")
	# Floor 6: explore 160, combat 180
	assert_eq(bpm[6]["explore"], 160, "Floor 6 explore BPM == 160")
	assert_eq(bpm[6]["combat"], 180, "Floor 6 combat BPM == 180")
	# Floor 7: arrhythmic (0)
	assert_eq(bpm[7]["explore"], 0, "Floor 7 explore BPM == 0 (arrhythmic)")
	assert_eq(bpm[7]["combat"], 0, "Floor 7 combat BPM == 0 (arrhythmic)")
	# Floor 8: explore 130, combat 160
	assert_eq(bpm[8]["explore"], 130, "Floor 8 explore BPM == 130")
	assert_eq(bpm[8]["combat"], 160, "Floor 8 combat BPM == 160")
	# Floor 9: special per-phase (0)
	assert_eq(bpm[9]["explore"], 0, "Floor 9 explore BPM == 0 (special)")
	assert_eq(bpm[9]["combat"], 0, "Floor 9 combat BPM == 0 (special)")


func test_music_player_has_generate_silence() -> void:
	var script := load("res://scripts/audio/music_player.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("_generate_silence" in methods, "_generate_silence method exists")


# ============================================================
# Step 3: SFXPlayer
# ============================================================

func test_sfx_player_script_loads() -> void:
	var script := load("res://scripts/audio/sfx_player.gd")
	assert_ne(script, null, "sfx_player.gd loads without errors")


func test_sfx_player_has_play_methods() -> void:
	var script := load("res://scripts/audio/sfx_player.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("play_sfx" in methods, "play_sfx method exists")
	assert_true("play_sfx_2d" in methods, "play_sfx_2d method exists")
	assert_true("play_sfx_with_pitch" in methods, "play_sfx_with_pitch method exists")


func test_sfx_names_constant_exists() -> void:
	var script := load("res://scripts/audio/sfx_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	assert_true(constants.has("SFX_NAMES"), "SFX_NAMES constant exists")
	var names: Dictionary = constants["SFX_NAMES"]
	# Weapon
	for w in ["weapon_swing", "weapon_hit", "weapon_throw"]:
		assert_true(names.has(w), "SFX_NAMES has %s" % w)
	# Enemy
	for e in ["enemy_alert", "enemy_hurt", "enemy_death", "enemy_regen", "enemy_grab"]:
		assert_true(names.has(e), "SFX_NAMES has %s" % e)
	# Gore
	for g in ["limb_sever", "blood_splash"]:
		assert_true(names.has(g), "SFX_NAMES has %s" % g)
	# Player
	for p in ["player_hurt", "player_heal", "player_death"]:
		assert_true(names.has(p), "SFX_NAMES has %s" % p)
	# Environment
	for env in ["door_open", "door_close", "item_pickup", "floor_transition"]:
		assert_true(names.has(env), "SFX_NAMES has %s" % env)
	# UI
	for u in ["ui_click", "ui_confirm", "ui_cancel", "ui_pause"]:
		assert_true(names.has(u), "SFX_NAMES has %s" % u)


func test_sfx_names_has_all_28() -> void:
	var script := load("res://scripts/audio/sfx_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	var names: Dictionary = constants["SFX_NAMES"]
	assert_eq(names.size(), 29, "SFX_NAMES has exactly 29 entries")


func test_sfx_player_pool_sizes() -> void:
	var script := load("res://scripts/audio/sfx_player.gd")
	var constants: Dictionary = script.get_script_constant_map()
	assert_true(constants.has("GLOBAL_POOL_SIZE"), "GLOBAL_POOL_SIZE constant exists")
	assert_true(constants.has("POSITIONAL_POOL_SIZE"), "POSITIONAL_POOL_SIZE constant exists")
	assert_eq(constants["GLOBAL_POOL_SIZE"], 8, "GLOBAL_POOL_SIZE == 8")
	assert_eq(constants["POSITIONAL_POOL_SIZE"], 4, "POSITIONAL_POOL_SIZE == 4")


# ============================================================
# Step 4: State machine transitions
# ============================================================

func test_current_music_state_accessible() -> void:
	var script := load("res://scripts/audio/audio_manager.gd")
	var props: Array = []
	for p in script.get_script_property_list():
		props.append(p["name"])
	assert_true("current_music_state" in props, "current_music_state property exists")


func test_transition_method_exists() -> void:
	var script := load("res://scripts/audio/audio_manager.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("_on_room_entered" in methods, "_on_room_entered exists")
	assert_true("_on_enemy_damaged" in methods, "_on_enemy_damaged exists")
	assert_true("_on_room_cleared" in methods, "_on_room_cleared exists")
	assert_true("_on_player_died" in methods, "_on_player_died exists")


# ============================================================
# Step 5: Floor 9 special handling
# ============================================================

func test_music_player_has_floor09_phase() -> void:
	var script := load("res://scripts/audio/music_player.gd")
	var methods: Array = []
	for m in script.get_script_method_list():
		methods.append(m["name"])
	assert_true("play_floor09_phase" in methods, "play_floor09_phase method exists")
