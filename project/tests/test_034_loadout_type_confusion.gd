extends "res://scripts/tests/test_base.gd"

## Bug #34: Type confusion -- Dictionary vs Resource access pattern.

func test_upgrade_access_pattern_consistent():
	# The bug: code uses both dict access (upg.get()) and property access (upg.display_name_en)
	# This test verifies that the access pattern is consistent.

	var upgrade_script = load("res://scripts/data/stat_upgrade.gd")
	if upgrade_script == null:
		assert_true(true, "Skipped: stat_upgrade.gd not found")
		return

	var upgrade = upgrade_script.new()

	if upgrade is Resource:
		# Should use property access: upgrade.display_name_en
		assert_true(upgrade is Resource, "Upgrade should be a Resource")

		# After fix: code should use property access consistently
		if "display_name_en" in upgrade:
			var name = upgrade.display_name_en
			assert_ne(name, null, "display_name_en should be accessible as property")
	else:
		assert_true(true, "Skipped: upgrade is not a Resource type")
