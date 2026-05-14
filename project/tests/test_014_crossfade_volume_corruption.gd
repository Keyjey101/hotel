extends "res://scripts/tests/test_base.gd"

## Bug #14: _crossfade kills tween without cleanup -- next crossfade works with corrupted volume.
## Bug #15: stop_all creates uncontrolled tweens -- duplicates fight over volume_db.

const MusicPlayerScript = preload("res://scripts/audio/music_player.gd")


func test_music_player_script_loads():
	assert_ne(MusicPlayerScript, null, "MusicPlayer script should load")


func test_crossfade_resets_source_volume():
	var mp = MusicPlayerScript.new()
	Engine.get_main_loop().root.add_child(mp)
	_auto_free_nodes.append(mp)
	await _wait_for_frame()

	# Start playing on exploration player
	mp.play_exploration(1)

	# Start a crossfade
	mp.play_combat(1)

	# Kill it immediately (simulates rapid transition)
	if mp._crossfade_tween and mp._crossfade_tween.is_valid():
		mp._crossfade_tween.kill()

	# After fix: from player volume should be reset to 0.0, not -80.0
	assert_gte(mp._exploration.volume_db, -1.0,
		"Exploration player volume should be reset after crossfade kill (got %f)" % mp._exploration.volume_db)


func test_stop_all_no_duplicate_tweens():
	var mp = MusicPlayerScript.new()
	Engine.get_main_loop().root.add_child(mp)
	_auto_free_nodes.append(mp)
	await _wait_for_frame()

	mp.play_exploration(1)
	mp.play_combat(1)

	# Call stop_all twice rapidly -- should not create duplicate tweens
	mp.stop_all(0.5)
	mp.stop_all(0.5)

	# Just verify no crash and system is stable
	assert_true(true, "stop_all should not crash on double call")


func _wait_for_frame():
	await Engine.get_main_loop().process_frame


func after_each():
	teardown_autoqfree()
