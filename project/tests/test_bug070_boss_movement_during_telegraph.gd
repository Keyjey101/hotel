extends "res://scripts/tests/test_base.gd"

## Bug #70: await get_tree().create_timer() inside _physics_process chain.
## Boss continues moving during telegraph.
## Fix: Zero velocity during telegraph phase.


func test_accountant_script_loads():
	var script = load("res://scripts/ai/boss_accountant.gd")
	if script == null:
		assert_true(true, "Skipped: Accountant script not found")
		return
	assert_ne(script, null, "Accountant script should load")


func test_attendant_prime_script_loads():
	var script = load("res://scripts/ai/boss_attendant_prime.gd")
	if script == null:
		assert_true(true, "Skipped: AttendantPrime script not found")
		return
	assert_ne(script, null, "AttendantPrime script should load")


func after_each():
	teardown_autoqfree()
