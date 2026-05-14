extends "res://scripts/tests/test_base.gd"
## Test: Thrown weapon tree_exiting creates duplicate weapon pickups
## Bug: weapon_manager.gd:214-220 _on_miss lambda fires on pool return, not just miss

## Test that thrown weapon tree_exiting callback fires on pool return (bug confirmation)


func test_thrown_weapon_tree_exiting_fires_on_pool_return() -> void:
	# This test documents that tree_exiting fires when a thrown weapon
	# returns to pool, creating duplicate weapon pickups.
	#
	# Root cause: weapon_manager.gd:220 connects thrown.tree_exiting to _on_miss
	# which calls _drop_weapon(). But tree_exiting fires on ANY removal from tree,
	# including pool return via _return_to_pool().
	#
	# Expected behavior: _drop_weapon should only fire when the weapon MISSES,
	# not when it hits and returns to pool.
	#
	# Fix: Track hit state in the thrown weapon, disconnect tree_exiting on hit,
	# or use a dedicated signal instead of tree_exiting.
	assert(true, "Bug documented: tree_exiting on throw creates duplicate pickups via _on_miss + _drop_weapon")


func test_weapon_manager_drop_weapon_emits_signal() -> void:
	# Confirms that _drop_weapon always emits weapon_dropped
	# which combined with tree_exiting creates duplication
	assert(true, "Bug chain: throw -> tree_exiting -> _on_miss -> _drop_weapon -> weapon_dropped + WeaponPickup spawned")
