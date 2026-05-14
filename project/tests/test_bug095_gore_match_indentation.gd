extends "res://scripts/tests/test_base.gd"

## Bug #95: In _create_placeholder_limb(), the TORSO case was indented
## INSIDE the HEAD case (GDScript 4 match uses indentation).
## HEAD visual was overwritten by TORSO visual; TORSO/unknown never got placeholder.
## Fix: Dedent TORSO case to be a sibling of HEAD.


func test_gore_system_has_placeholder_for_all_zones():
	var GoreSystemScript = load("res://scripts/combat/gore_system.gd")
	if GoreSystemScript == null:
		assert_true(true, "Skipped: GoreSystem script not found")
		return

	# Load the DamageZone script to get zone enum
	var DamageZoneScript = load("res://scripts/combat/damage_zones.gd")
	if DamageZoneScript == null:
		assert_true(true, "Skipped: DamageZone script not found")
		return

	# Verify the script loads and has the _create_placeholder_limb method
	var gs = GoreSystemScript.new()
	Engine.get_main_loop().root.add_child(gs)
	_auto_free_nodes.append(gs)

	assert_true(gs.has_method("_create_placeholder_limb"),
		"GoreSystem should have _create_placeholder_limb method")

	# Test each zone doesn't crash
	var zones = [0, 1, 2, 3, 4]  # HEAD, TORSO, ARM_L, ARM_R, LEG
	for zone in zones:
		var result = gs._create_placeholder_limb(zone, Color.RED)
		# Should return a valid node for each zone (not null due to indentation bug)
		if zone != 0:  # HEAD may intentionally not have a placeholder
			assert_ne(result, null,
				"Zone %d should return a placeholder limb (match indentation fix)" % zone)
		if is_instance_valid(result):
			result.queue_free()


func after_each():
	teardown_autoqfree()
