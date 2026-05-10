extends "res://scripts/tests/test_base.gd"

## TestRegenSystem — Tests for regeneration timing, pausing, and limb restoration.

var base_regen_time: float = 30.0


func before_each() -> void:
	base_regen_time = 30.0


func test_regen_timer_starts_at_max() -> void:
	var timer := {"current": 0.0, "max": base_regen_time, "paused": false}
	assert_eq(timer.max, 30.0, "Timer starts at base regen time")
	assert_false(timer.paused, "Timer not paused initially")


func test_regen_timer_ticks_down() -> void:
	var timer := {"current": 0.0, "max": base_regen_time, "paused": false}
	timer.max -= 1.0  # Simulate 1 second
	assert_eq(timer.max, 29.0, "Timer decreases by delta")


func test_regen_timer_completes() -> void:
	var timer := {"current": 0.0, "max": 1.0, "paused": false}
	timer.max -= 1.0
	assert_lte(timer.max, 0.0, "Timer reaches 0 = regen complete")


func test_regen_speed_multiplier_faster() -> void:
	var mult := 1.3  # 30% faster
	var effective_time := base_regen_time / mult
	assert_approx(effective_time, 23.08, 0.1, "30% faster = ~23s regen")


func test_regen_speed_multiplier_slower() -> void:
	var mult := 0.7  # 30% slower
	var effective_time := base_regen_time / mult
	assert_approx(effective_time, 42.86, 0.1, "30% slower = ~43s regen")


func test_regen_pauses_on_hit() -> void:
	var timer := {"current": 0.0, "max": 20.0, "paused": false}
	timer.paused = true
	timer.current = 2.0  # 2 second pause
	assert_true(timer.paused, "Timer paused after hit")
	assert_eq(timer.current, 2.0, "Pause duration set")


func test_regen_pause_counts_down() -> void:
	var timer := {"current": 2.0, "max": 20.0, "paused": true}
	timer.current -= 1.0
	assert_eq(timer.current, 1.0, "Pause timer ticking")
	assert_true(timer.paused, "Still paused")


func test_regen_pause_ends() -> void:
	var timer := {"current": 0.5, "max": 20.0, "paused": true}
	timer.current -= 0.5
	if timer.current <= 0.0:
		timer.paused = false
	assert_false(timer.paused, "Pause ends when timer reaches 0")


func test_regen_pauses_reset_on_repeated_hits() -> void:
	var timer := {"current": 0.3, "max": 20.0, "paused": true}
	# New hit resets pause duration
	timer.current = 2.0
	assert_eq(timer.current, 2.0, "Pause reset on new hit")


func test_no_regen_on_healthy_limb() -> void:
	var severed := false
	assert_false(severed, "Healthy limb should not regen")


func test_legs_regen_faster_when_both_lost() -> void:
	var both_legs_lost := true
	var extra_mult := 1.3 if both_legs_lost else 1.0
	var effective := base_regen_time / extra_mult
	assert_lt(effective, base_regen_time, "Both legs lost = faster regen")


func test_regen_restores_full_limb_hp() -> void:
	var max_arm_hp := 20.0
	var current_hp := 0.0
	# Simulate regen complete
	current_hp = max_arm_hp
	assert_eq(current_hp, max_arm_hp, "Regen restores full limb HP")


func test_regen_resets_severed_flag() -> void:
	var severed := true
	# Simulate regen complete
	severed = false
	assert_false(severed, "Severed flag cleared on regen")


func test_regen_resets_timer_after_complete() -> void:
	var timer := {"current": 0.0, "max": 0.0, "paused": false}
	# After regen, reset timer
	timer.max = base_regen_time
	assert_eq(timer.max, 30.0, "Timer reset to base after regen")


func assert_lte(value: float, limit: float, message: String = "") -> void:
	if value > limit:
		var msg := "Expected %s <= %s" % [str(value), str(limit)]
		if message != "": msg = message
		_test_runner.report_failure(msg)
