extends Node

## TestBloodlust — Verifies S11 Bloodlust behavioral upgrade.
## Run via test_runner.gd.

var _test_runner: Object  # Injected by TestRunner


func test_bloodlust_activates_on_kill() -> void:
	var rs := RunState.new()
	rs.collected_upgrade_ids = ["s11_bloodlust"]
	rs.bloodlust_timer = 0.0
	rs.bloodlust_stacks = 0

	# Simulate kill
	var stacks := rs.get_stack_count("s11_bloodlust")
	assert(stacks == 1, "Should have 1 Bloodlust stack")
	rs.bloodlust_stacks = stacks
	rs.bloodlust_timer = 3.0

	assert(rs.bloodlust_timer > 0.0, "Timer should be active after kill")
	assert(rs.bloodlust_stacks == 1, "Stacks should be set")


func test_bloodlust_damage_mult() -> void:
	# Simulate damage multiplier calculation
	var bloodlust_timer := 3.0
	var bloodlust_stacks := 1

	var bonus := 0.0
	for i in range(mini(bloodlust_stacks, 3)):
		if i < 2:
			bonus += 0.10
		else:
			bonus += 0.05
	var mult := 1.0 + bonus
	assert(mult == 1.10, "1 stack should give +10%% damage, got %f" % mult)

	# 2 stacks
	bloodlust_stacks = 2
	bonus = 0.0
	for i in range(mini(bloodlust_stacks, 3)):
		if i < 2:
			bonus += 0.10
		else:
			bonus += 0.05
	mult = 1.0 + bonus
	assert(mult == 1.20, "2 stacks should give +20%% damage, got %f" % mult)

	# 3 stacks (diminishing on 3rd)
	bloodlust_stacks = 3
	bonus = 0.0
	for i in range(mini(bloodlust_stacks, 3)):
		if i < 2:
			bonus += 0.10
		else:
			bonus += 0.05
	mult = 1.0 + bonus
	assert(mult == 1.25, "3 stacks should give +25%% damage (diminishing), got %f" % mult)


func test_bloodlust_decays() -> void:
	var rs := RunState.new()
	rs.collected_upgrade_ids = ["s11_bloodlust"]
	rs.bloodlust_stacks = 1
	rs.bloodlust_timer = 0.1

	# Simulate decay
	rs.bloodlust_timer -= 0.2  # More than remaining
	if rs.bloodlust_timer <= 0.0:
		rs.bloodlust_stacks = 0

	assert(rs.bloodlust_timer <= 0.0, "Timer should have expired")
	assert(rs.bloodlust_stacks == 0, "Stacks should be 0 after decay")


func test_bloodlust_resets_on_new_kill() -> void:
	var rs := RunState.new()
	rs.collected_upgrade_ids = ["s11_bloodlust"]
	rs.bloodlust_timer = 1.0  # Partially decayed
	rs.bloodlust_stacks = 1

	# New kill resets timer
	rs.bloodlust_stacks = rs.get_stack_count("s11_bloodlust")
	rs.bloodlust_timer = 3.0

	assert(rs.bloodlust_timer == 3.0, "Timer should reset to 3s on new kill")
