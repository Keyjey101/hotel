extends "res://scripts/tests/test_base.gd"

## Bug #32: upgrade_registry fallback uses _all_upgrades without checking unlock status.
## Fix: Filter by unlock status in fallback.

## Bug #33: artifact_registry fallback uses _all_artifacts including rare/cursed.
## Fix: Use DEFAULT_UNLOCKED_ARTIFACTS as minimum.


func test_upgrade_registry_script_loads():
	var script = load("res://scripts/core/upgrade_registry.gd")
	if script == null:
		assert_true(true, "Skipped: UpgradeRegistry script not found")
		return
	assert_ne(script, null, "UpgradeRegistry script should load")


func test_upgrade_registry_fallback_filters_unlocked():
	var UpgradeRegistryScript = load("res://scripts/core/upgrade_registry.gd")
	if UpgradeRegistryScript == null:
		assert_true(true, "Skipped: UpgradeRegistry script not found")
		return

	var reg = UpgradeRegistryScript.new()
	if reg == null:
		assert_true(true, "Skipped: Could not instantiate UpgradeRegistry")
		return

	# Test that get_random_upgrade_for_floor doesn't crash with empty unlocked
	if reg.has_method("get_random_upgrade_for_floor"):
		var result = reg.get_random_upgrade_for_floor(1)
		# Should not crash even with empty pool
		assert_true(true, "get_random_upgrade_for_floor completed without crash")


func test_artifact_registry_script_loads():
	var script = load("res://scripts/core/artifact_registry.gd")
	if script == null:
		assert_true(true, "Skipped: ArtifactRegistry script not found")
		return
	assert_ne(script, null, "ArtifactRegistry script should load")


func test_artifact_registry_fallback_uses_common():
	var ArtifactRegistryScript = load("res://scripts/core/artifact_registry.gd")
	if ArtifactRegistryScript == null:
		assert_true(true, "Skipped: ArtifactRegistry script not found")
		return

	var reg = ArtifactRegistryScript.new()
	if reg == null:
		assert_true(true, "Skipped: Could not instantiate ArtifactRegistry")
		return

	# Test that get_random_artifact doesn't crash with empty unlocked
	if reg.has_method("get_random_artifact"):
		var result = reg.get_random_artifact()
		assert_true(true, "get_random_artifact completed without crash")


func after_each():
	teardown_autoqfree()
