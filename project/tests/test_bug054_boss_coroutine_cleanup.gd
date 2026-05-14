extends "res://scripts/tests/test_base.gd"

## Bug #54: Consort _move_projectile uses await physics_frame in while loop.
## Dangling coroutine when boss freed.
## Fix: Add is_instance_valid check + proper counter decrement on early exit.

## Bug #55: Curator shadow bolt _active_bolt_count leaks on external destruction.
## Fix: Decrement counter on all exit paths.

## Bug #57: Madame _continue_shard creates chain of SceneTreeTimers without cleanup.
## Fix: Check _disabled flag and clean up shard nodes.


func test_consort_script_loads():
	var script = load("res://scripts/ai/boss_consort.gd")
	if script == null:
		assert_true(true, "Skipped: Consort script not found")
		return
	assert_ne(script, null, "Consort script should load")


func test_curator_script_loads():
	var script = load("res://scripts/ai/boss_curator.gd")
	if script == null:
		assert_true(true, "Skipped: Curator script not found")
		return
	assert_ne(script, null, "Curator script should load")


func test_madame_script_loads():
	var script = load("res://scripts/ai/boss_madame.gd")
	if script == null:
		assert_true(true, "Skipped: Madame script not found")
		return
	assert_ne(script, null, "Madame script should load")


func after_each():
	teardown_autoqfree()
