extends StaticBody2D

## WeaponPickup — A weapon lying on the ground, pickable via interact (E key).

@export var weapon_data: WeaponData


func get_weapon_data() -> WeaponData:
	return weapon_data
