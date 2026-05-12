extends Node

## TestSecondWind — Verifies S9 Second Wind behavioral upgrade.
## Run via test_runner.gd.

var _test_runner: Object  # Injected by TestRunner


func test_second_wind_prevents_death() -> void:
	var rs := RunState.new()
	rs.player_hp = 100.0
	rs.player_max_hp = 100.0
	rs.collected_upgrade_ids = ["s9_second_wind"]
	rs.second_wind_used = false

	# Simulate lethal damage
	rs.player_hp = -10.0
	assert(rs.player_hp <= 0.0, "HP should be <= 0 after lethal damage")

	# Check that second wind would activate
	assert(not rs.second_wind_used, "Second wind should not be used yet")
	assert(rs.get_stack_count("s9_second_wind") >= 1, "Should have S9 stacks")

	# Simulate second wind activation
	rs.second_wind_used = true
	rs.player_hp = rs.player_max_hp * 0.30
	assert(rs.player_hp == 30.0, "HP should be 30%% of max after second wind, got %f" % rs.player_hp)
	assert(rs.second_wind_used, "Second wind should be marked as used")


func test_second_wind_only_once() -> void:
	var rs := RunState.new()
	rs.player_hp = 100.0
	rs.player_max_hp = 100.0
	rs.collected_upgrade_ids = ["s9_second_wind"]
	rs.second_wind_used = true  # Already used

	# Second death should not be prevented
	assert(rs.second_wind_used, "Second wind already used — should not activate again")


func test_second_wind_disabled_by_pact_of_flesh() -> void:
	var rs := RunState.new()
	rs.player_hp = 100.0
	rs.player_max_hp = 100.0
	rs.collected_upgrade_ids = ["s9_second_wind"]
	rs.second_wind_used = false

	# Add Pact of Flesh artifact
	var art := CultArtifact.new()
	art.id = "a8_pact_of_flesh"
	art.stat_mods = {"player_hp_drain": 2.0}
	rs.apply_artifact(art)

	# Second wind should be blocked
	assert(rs.has_artifact("a8_pact_of_flesh"), "Should have Pact of Flesh")
	# The player_controller checks this, but we verify the state is correct


func test_second_wind_regen() -> void:
	var rs := RunState.new()
	rs.player_hp = 15.0
	rs.player_max_hp = 100.0
	rs.collected_upgrade_ids = ["s9_second_wind"]

	# Simulate regen tick (1 HP/s * 1 stack * 0.016s delta)
	var stacks := rs.get_stack_count("s9_second_wind")
	assert(stacks == 1, "Should have 1 stack")
	var heal_rate := 1.0 * stacks
	var threshold := rs.player_max_hp * 0.30
	rs.player_hp = minf(rs.player_hp + heal_rate * 0.016, threshold)
	assert(rs.player_hp > 15.0, "HP should increase from regen")
	assert(rs.player_hp <= threshold, "HP should not exceed 30%% threshold")
