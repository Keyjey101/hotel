class_name StatUpgrade
extends Resource

## StatUpgrade — Data resource for stat upgrades (numerical bonuses).
## Pure benefit, stacks additively.

@export var id: String = ""  # "s1_vitality_shard" .. "s11_bloodlust"
@export var display_name: String = ""
@export var description: String = ""
@export var stat_key: String = ""  # "max_hp", "speed", "damage_melee", etc.
@export var delta: float = 0.0
@export var type: String = "additive"  # additive, additive_percent, multiplicative_percent, conditional_passive, conditional_temporary
@export var max_stacks: int = 3
@export var diminishing_3rd: float = 0.5
@export var spawn_weight: int = 5
@export var spawn_floors: String = "1-9"  # "1-9" or "3-9"
@export var visual_id: String = ""
@export var behavioral_id: String = ""  # "second_wind", "bloodlust" for S9/S11
