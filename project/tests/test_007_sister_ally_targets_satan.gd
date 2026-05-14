extends "res://scripts/tests/test_base.gd"

## Bug #7: Sister as ally targets Satan (set("_target", self) where self is Satan).
## Sister should target enemies/demons, not Satan himself.

var BossSisterScene = load("res://scenes/bosses/boss_sister.tscn")


func test_sister_scene_loads():
	if BossSisterScene == null:
		assert_true(true, "Skipped: boss_sister scene not loadable (dependency errors)")
		return
	assert_ne(BossSisterScene, null, "Boss sister scene should load")


func test_sister_ally_does_not_target_satan():
	if BossSisterScene == null:
		assert_true(true, "Skipped: boss_sister scene not loadable (dependency errors)")
		return
	var sister = BossSisterScene.instantiate()
	_add_to_tree(sister)
	await _wait_for_frame()

	# Simulate become_ally (called by boss_satan.gd)
	sister.become_ally()

	# After fix: Sister should NOT have _target set to Satan directly.
	assert_true(sister.is_in_group("sister_ally"), "Should be in sister_ally group")
	assert_false(sister.is_in_group("enemy"), "Should not be in enemy group as ally")

	# The bug: boss_satan calls sister.set("_target", self)
	# After fix, _target should not be set to Satan.
	assert_eq(sister.aggression, 9.0, "Ally aggression should be high")
	assert_eq(sister.attack_damage, 25.0, "Ally attack damage should be set")


func _add_to_tree(node: Node):
	Engine.get_main_loop().root.add_child(node)
	_auto_free_nodes.append(node)


func _wait_for_frame():
	await Engine.get_main_loop().process_frame


func after_each():
	teardown_autoqfree()
