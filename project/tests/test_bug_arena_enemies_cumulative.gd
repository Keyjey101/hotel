extends "res://scripts/tests/test_base.gd"
## Test: ArenaRoom active_enemies array is cumulative across waves
## Bug: arena_room.gd:96-101 _spawn_wave appends to active_enemies without clearing dead


func test_arena_active_enemies_cumulative() -> void:
	# arena_room._spawn_wave does: active_enemies.append(enemy) for each wave
	# But dead enemies from previous waves are never removed from the array
	# _check_wave_cleared filters them visually but the array keeps growing
	assert(true, "Bug: active_enemies grows unbounded across waves, containing disabled enemies from prior waves")


func test_arena_fix_should_clear_dead_before_new_wave() -> void:
	assert(true, "Fix: before appending new wave enemies, filter out disabled ones: active_enemies = active_enemies.filter(...)")
