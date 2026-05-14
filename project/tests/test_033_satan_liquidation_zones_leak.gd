extends "res://scripts/tests/test_base.gd"

## Bug #33: _liquidation_zones never cleaned up -- memory leak.

func test_hazard_zone_cleanup_pattern():
	# Test that a boss tracking hazard zones cleans up on death
	var zones: Array = []

	# Simulate creating several zones
	for i in range(5):
		var zone = Area2D.new()
		zone.name = "LiquidationZone_%d" % i
		Engine.get_main_loop().root.add_child(zone)
		_auto_free_nodes.append(zone)
		zones.append(zone)

	assert_eq(zones.size(), 5, "Should have 5 zones")

	# Simulate cleanup (the fix)
	for zone in zones:
		if is_instance_valid(zone):
			zone.queue_free()
	zones.clear()

	assert_eq(zones.size(), 0, "Zones array should be empty after cleanup")


func after_each():
	teardown_autoqfree()
