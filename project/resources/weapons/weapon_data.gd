class_name WeaponData
extends Resource

## WeaponData — Data resource defining a weapon's properties.

enum WeaponType { MELEE, RANGED, IMPROVISED }
enum ThrowArc { STRAIGHT, ARC, SPIN, TUMBLE, FLOAT }

@export var weapon_name: String = "Weapon"
@export var weapon_id: String = ""
@export var weapon_type: WeaponType = WeaponType.MELEE

# Melee / base stats
@export_group("Base Stats")
@export var damage: float = 20.0
@export var limb_damage_multiplier: float = 1.0
@export var attack_speed: float = 0.2          # Seconds between attacks
@export var attack_range: float = 45.0          # Pixels
@export var knockback: float = 15.0
@export var stun_chance: float = 0.1
@export var stun_duration: float = 0.3
@export var sever_chance: float = 0.1

# Ranged
@export_group("Ranged")
@export var ammo: int = -1                      # -1 = infinite (melee)
@export var projectile_speed: float = 600.0
@export var projectile_spread: float = 0.0      # Degrees
@export var projectile_count: int = 1
@export var piercing: bool = false

# Throw
@export_group("Throw")
@export var throw_damage: float = 15.0
@export var throw_speed: float = 400.0
@export var throw_arc: ThrowArc = ThrowArc.TUMBLE
@export var throw_effect: String = ""           # Effect identifier
@export var throw_effect_chance: float = 0.0

# Visuals
@export_group("Visuals")
@export var sprite_path: String = ""
@export var attack_frame_count: int = 5
@export var throw_frame_count: int = 4
