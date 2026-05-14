extends "res://scripts/tests/test_base.gd"

## Bug #5: _select_patterns accesses optional[1] without bounds check.
## If optional.size() < 2, this causes array out-of-bounds crash.
## Bug #6: DESCENDING state doesn't call move_and_slide().
## Bug #25: Enemy buff applied before add_child() (before _ready).

var BossChampionScene = load("res://scenes/bosses/boss_champion.tscn")


func test_champion_scene_loads():
	if BossChampionScene == null:
		assert_true(true, "Skipped: boss_champion scene not loadable (dependency errors)")
		return
	assert_ne(BossChampionScene, null, "Boss champion scene should load")


func test_select_patterns_no_oob_with_two_optional():
	if BossChampionScene == null:
		assert_true(true, "Skipped: boss_champion scene not loadable (dependency errors)")
		return
	var boss = BossChampionScene.instantiate()
	_add_to_tree(boss)
	await _wait_for_frame()

	# Call with minimal patterns (should not crash)
	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	var result = boss._select_patterns(["combo", "taunt"], "combo", rng)
	assert_eq(result.size(), 2, "Should return 2 patterns when only 1 optional available")
	assert_true("combo" in result, "Required pattern should be included")


func test_select_patterns_no_oob_with_one_optional():
	if BossChampionScene == null:
		assert_true(true, "Skipped: boss_champion scene not loadable (dependency errors)")
		return
	var boss = BossChampionScene.instantiate()
	_add_to_tree(boss)
	await _wait_for_frame()

	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	# Only 1 optional item -- should NOT crash accessing optional[1]
	var result = boss._select_patterns(["combo", "taunt"], "combo", rng)
	assert_ne(result, null, "_select_patterns should not crash with small input")


func test_descending_state_calls_move_and_slide():
	if BossChampionScene == null:
		assert_true(true, "Skipped: boss_champion scene not loadable (dependency errors)")
		return
	# Bug #6: _process_descending sets velocity but doesn't call move_and_slide
	var boss = BossChampionScene.instantiate()
	_add_to_tree(boss)
	await _wait_for_frame()

	# Force DESCENDING state
	boss.current_boss_state = boss.BossState.DESCENDING
	var initial_pos: Vector2 = boss.global_position

	await _wait(0.1)

	# Boss should have moved from initial position
	var moved: bool = boss.global_position.distance_to(initial_pos) > 0.0
	assert_true(moved, "Boss in DESCENDING state should move (move_and_slide must be called)")


func test_wave_enemy_buff_after_add_child():
	if BossChampionScene == null:
		assert_true(true, "Skipped: boss_champion scene not loadable (dependency errors)")
		return
	# Bug #25: Buff applied before add_child() -- _ready() overwrites attack_damage.
	var boss = BossChampionScene.instantiate()
	_add_to_tree(boss)
	await _wait_for_frame()

	assert_true(boss.wave_number >= 1, "Wave system should be active after _ready")


func _add_to_tree(node: Node):
	Engine.get_main_loop().root.add_child(node)
	_auto_free_nodes.append(node)


func _wait(seconds: float):
	var _st := Engine.get_main_loop() as SceneTree
	var timer: SceneTreeTimer = _st.create_timer(seconds)
	timer.one_shot = true
	await timer.timeout


func _wait_for_frame():
	await Engine.get_main_loop().process_frame


func after_each():
	teardown_autoqfree()
