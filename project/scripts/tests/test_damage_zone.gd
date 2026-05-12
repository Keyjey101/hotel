extends "res://scripts/tests/test_base.gd"

## TestDamageZone — Tests for zone classification and helper functions.


func test_is_limb_arms() -> void:
	assert_true(DamageZone.is_limb(DamageZone.Zone.LEFT_ARM), "Left arm is a limb")
	assert_true(DamageZone.is_limb(DamageZone.Zone.RIGHT_ARM), "Right arm is a limb")


func test_is_limb_legs() -> void:
	assert_true(DamageZone.is_limb(DamageZone.Zone.LEFT_LEG), "Left leg is a limb")
	assert_true(DamageZone.is_limb(DamageZone.Zone.RIGHT_LEG), "Right leg is a limb")


func test_is_limb_head() -> void:
	assert_false(DamageZone.is_limb(DamageZone.Zone.HEAD), "Head is NOT a limb (not severable)")


func test_torso_not_limb() -> void:
	assert_false(DamageZone.is_limb(DamageZone.Zone.TORSO), "Torso is NOT a limb")


func test_is_arm() -> void:
	assert_true(DamageZone.is_arm(DamageZone.Zone.LEFT_ARM), "Left arm is arm")
	assert_true(DamageZone.is_arm(DamageZone.Zone.RIGHT_ARM), "Right arm is arm")
	assert_false(DamageZone.is_arm(DamageZone.Zone.HEAD), "Head is not arm")
	assert_false(DamageZone.is_arm(DamageZone.Zone.LEFT_LEG), "Leg is not arm")
	assert_false(DamageZone.is_arm(DamageZone.Zone.TORSO), "Torso is not arm")


func test_is_leg() -> void:
	assert_true(DamageZone.is_leg(DamageZone.Zone.LEFT_LEG), "Left leg is leg")
	assert_true(DamageZone.is_leg(DamageZone.Zone.RIGHT_LEG), "Right leg is leg")
	assert_false(DamageZone.is_leg(DamageZone.Zone.HEAD), "Head is not leg")
	assert_false(DamageZone.is_leg(DamageZone.Zone.LEFT_ARM), "Arm is not leg")
	assert_false(DamageZone.is_leg(DamageZone.Zone.TORSO), "Torso is not leg")


func test_name_returns_strings() -> void:
	assert_eq(DamageZone.name(DamageZone.Zone.HEAD), "head")
	assert_eq(DamageZone.name(DamageZone.Zone.LEFT_ARM), "left_arm")
	assert_eq(DamageZone.name(DamageZone.Zone.RIGHT_ARM), "right_arm")
	assert_eq(DamageZone.name(DamageZone.Zone.LEFT_LEG), "left_leg")
	assert_eq(DamageZone.name(DamageZone.Zone.RIGHT_LEG), "right_leg")
	assert_eq(DamageZone.name(DamageZone.Zone.TORSO), "torso")


func test_all_limbs_returns_5() -> void:
	var limbs := DamageZone.all_limbs()
	assert_eq(limbs.size(), 5, "5 limb zones")
	assert_true(limbs.has(DamageZone.Zone.HEAD), "Includes head")
	assert_true(limbs.has(DamageZone.Zone.LEFT_ARM), "Includes left arm")
	assert_true(limbs.has(DamageZone.Zone.RIGHT_ARM), "Includes right arm")
	assert_true(limbs.has(DamageZone.Zone.LEFT_LEG), "Includes left leg")
	assert_true(limbs.has(DamageZone.Zone.RIGHT_LEG), "Includes right leg")
