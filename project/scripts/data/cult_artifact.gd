class_name CultArtifact
extends Resource

## CultArtifact — Data resource for cult artifacts (trade-off modifiers).
## Each artifact is a "deal with the devil" with bonus + cost.

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var flavor_text: String = ""
@export var rarity: int = 1  # 1=common, 2=rare, 3=cursed
@export var stat_mods: Dictionary = {}  # e.g. "ranged_damage_mult": +0.30
@export var trigger: String = "passive"  # passive, on_hit_dealt, on_kill, on_pickup, on_player_death, on_dash_activate, on_limb_sever
@export var trade_off_text: String = ""
@export var unlock_condition: String = ""  # empty = available from floor 1
@export var visual_id: String = ""
