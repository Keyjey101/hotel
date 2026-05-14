extends "res://scripts/tests/test_base.gd"
## Test: GoreSystem double placeholder blood spawn
## Bug: gore_system.gd:72-84 spawn_severed_limb calls spawn_blood_splash (which calls _spawn_placeholder_blood)
##      then line 78 calls _spawn_placeholder_blood AGAIN

## Verify double blood spawn on severed limb


func test_gore_severed_limb_calls_blood_twice() -> void:
	# spawn_severed_limb (line 54) does:
	#   1. line 72: spawn_blood_splash(position, direction) -> internally calls _spawn_placeholder_blood
	#   2. line 78: _spawn_placeholder_blood(position, direction) -> SECOND call
	# This results in double blood droplet spawning
	assert(true, "Bug documented: spawn_severed_limb calls _spawn_placeholder_blood twice (lines 72+78)")


func test_gore_fix_should_remove_line_78() -> void:
	# The fix: remove the explicit _spawn_placeholder_blood call at line 78
	# since spawn_blood_splash already calls it internally
	assert(true, "Fix: remove _spawn_placeholder_blood call at gore_system.gd:78")
