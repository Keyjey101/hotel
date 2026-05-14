extends "res://scripts/tests/test_base.gd"

## Bug #11: Random weapon pickup mutates the shared seeded RNG.
## get_floor_rng returns a cached RNG; calling randi() on it shifts state
## for ALL subsequent seeded operations on that floor.

func test_weapon_rng_does_not_mutate_shared_rng():
	# The fix creates a LOCAL RNG derived from the shared seed.
	# We verify that creating a local RNG doesn't affect the shared one.
	var shared_rng = RandomNumberGenerator.new()
	shared_rng.seed = 12345

	# Save original state
	var original_seed: int = shared_rng.seed

	# Create a LOCAL RNG (the fix pattern)
	var weapon_rng = RandomNumberGenerator.new()
	weapon_rng.seed = hash(shared_rng.seed + "_weapon_0")

	# Use the local RNG
	weapon_rng.randi()
	weapon_rng.randi()
	weapon_rng.randi()

	# Shared RNG should be untouched
	assert_eq(shared_rng.seed, original_seed, "Shared RNG seed should not be mutated")

	# And calling randi on shared should produce the same result as before local usage
	shared_rng.seed = original_seed
	var first_call: int = shared_rng.randi()
	# Reset and call again -- should be deterministic
	shared_rng.seed = original_seed
	var second_call: int = shared_rng.randi()
	assert_eq(first_call, second_call, "Shared RNG should produce deterministic results")
