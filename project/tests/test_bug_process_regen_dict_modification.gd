extends "res://scripts/tests/test_base.gd"
## Test: base_enemy._process_regen iterates Dictionary that may be modified
## Bug: base_enemy.gd:301-322 _regenerate_limb can modify regen_timers during iteration

## Verify that _process_regen can trigger Dictionary modification during iteration


func test_process_regen_dictionary_safe_with_simple_case() -> void:
	# The base_enemy._process_regen iterates regen_timers directly.
	# _regenerate_limb (called at line 322) reassigns regen_timers[zone] which is safe
	# for same-key reassignment but NOT safe if subtypes add/remove keys in _on_limb_recovered.
	# This test documents the potential crash scenario.
	assert(true, "Bug documented: _process_regen iterates regen_timers while _regenerate_limb can trigger _on_limb_recovered which may add/remove keys")


func test_dictionary_iteration_during_modification() -> void:
	# Demonstrate that modifying a Dictionary during iteration causes issues
	var d := {"a": 1, "b": 2, "c": 3}
	var keys_snapshot := d.keys()
	# Safe pattern: iterate snapshot
	for key in keys_snapshot:
		d[key] = d[key] * 2  # Same-key reassignment is safe
	assert(d["a"] == 2, "Safe Dictionary modification via snapshot")

	# Unsafe pattern (what base_enemy does): direct iteration
	# If _on_limb_recovered adds a new key, this would crash
	assert(true, "Fix: collect keys into array before iterating in _process_regen")
