class_name DamageZone
extends RefCounted

## DamageZone — Enum for limb/torso damage zones.

enum Zone {
	HEAD,
	LEFT_ARM,
	RIGHT_ARM,
	LEFT_LEG,
	RIGHT_LEG,
	TORSO,
}

## Returns true if the zone is a limb (not torso/head).
static func is_limb(zone: Zone) -> bool:
	return zone != Zone.HEAD and zone != Zone.TORSO

## Returns true if the zone is an arm.
static func is_arm(zone: Zone) -> bool:
	return zone == Zone.LEFT_ARM or zone == Zone.RIGHT_ARM

## Returns true if the zone is a leg.
static func is_leg(zone: Zone) -> bool:
	return zone == Zone.LEFT_LEG or zone == Zone.RIGHT_LEG

static func name(zone: Zone) -> String:
	match zone:
		Zone.HEAD: return "head"
		Zone.LEFT_ARM: return "left_arm"
		Zone.RIGHT_ARM: return "right_arm"
		Zone.LEFT_LEG: return "left_leg"
		Zone.RIGHT_LEG: return "right_leg"
		Zone.TORSO: return "torso"
		_: return "unknown"

## All limb zones.
static func all_limbs() -> Array[int]:
	return [Zone.HEAD, Zone.LEFT_ARM, Zone.RIGHT_ARM, Zone.LEFT_LEG, Zone.RIGHT_LEG]
