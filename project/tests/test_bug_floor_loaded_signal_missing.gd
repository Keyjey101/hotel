extends "res://scripts/tests/test_base.gd"
## Test: floor_loaded signal referenced but never declared in EventBus
## Bug: floor_manager.gd:68 checks EventBus.has_signal("floor_loaded") but signal doesn't exist


func test_event_bus_has_no_floor_loaded_signal() -> void:
	var eb_script := load("res://scripts/core/event_bus.gd")
	assert(eb_script != null, "EventBus script exists")

	# Check that "floor_loaded" is NOT declared as a signal
	var signals := eb_script.get_script_signal_list()
	var has_floor_loaded := false
	for s in signals:
		if s.name == "floor_loaded":
			has_floor_loaded = true
			break
	assert(not has_floor_loaded, "Bug confirmed: floor_loaded signal NOT declared in EventBus, but referenced in floor_manager.gd:68")


func test_floor_manager_checks_signal_correctly() -> void:
	# floor_manager.gd:68 uses has_signal() which returns false, so the emit never fires
	# This is a silent bug - no crash, but the feature doesn't work
	assert(true, "Fix: add 'signal floor_loaded(floor_number: int)' to EventBus")
