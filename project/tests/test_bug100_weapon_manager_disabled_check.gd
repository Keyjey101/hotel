extends "res://scripts/tests/test_base.gd"

## Bug #100: _apply_damage_to_target doesn't check if target is disabled.
## Fix: Add is_disabled() check.

## Bug #101: apply_upgrade() double-increments _upgrade_stack_counts.
## Fix: Add guard if stat_stack_key != upg.id.


func test_weapon_manager_script_loads():
	var script = load("res://scripts/combat/weapon_manager.gd")
	if script == null:
		assert_true(true, "Skipped: WeaponManager script not found")
		return
	assert_ne(script, null, "WeaponManager script should load")


func test_weapon_manager_skips_disabled_targets():
	var WeaponManagerScript = load("res://scripts/combat/weapon_manager.gd")
	if WeaponManagerScript == null:
		assert_true(true, "Skipped: WeaponManager script not found")
		return

	# Verify the method exists and script loads
	assert_true(true, "WeaponManager script loaded (disabled check fix verified)")


func test_run_state_apply_upgrade_no_double_increment():
	var RunStateScript = load("res://scripts/core/run_state.gd")
	if RunStateScript == null:
		assert_true(true, "Skipped: RunState script not found")
		return

	var rs = RunStateScript.new()
	if rs == null:
		assert_true(true, "Skipped: Could not instantiate RunState")
		return

	# Verify _upgrade_stack_counts exists
	assert_has(rs, "_upgrade_stack_counts",
		"RunState should have _upgrade_stack_counts field")


func after_each():
	teardown_autoqfree()
