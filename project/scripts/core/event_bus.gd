extends Node

## EventBus — Decoupled global event system autoload.
## All gameplay-relevant signals flow through here for loose coupling.

# === Combat Events ===
signal enemy_damaged(enemy: CharacterBody2D, zone: int, damage: float)
signal enemy_limb_severed(enemy: CharacterBody2D, zone: int)
signal enemy_fully_regenerated(enemy: CharacterBody2D)
signal enemy_disabled(enemy: CharacterBody2D)

signal player_damaged(amount: float)
signal player_healed(amount: float)
signal player_captured
signal dialog_choice_made(choice: String)
signal player_marked(duration: float)
signal player_weapon_changed(slot: int, weapon_data: Resource)

signal weapon_thrown(weapon_data: Resource, origin: Vector2, direction: Vector2)
signal weapon_hit_target(weapon_data: Resource, target: Node2D, damage: float)
signal weapon_picked_up(weapon_data: Resource)
signal weapon_dropped(weapon_data: Resource)

# === Counter Events (for achievement tracking) ===
signal limb_severed
signal weapon_was_thrown
signal basement_was_escaped
signal room_cleared_no_damage(floor_number: int, room_name: String)
signal demon_deal_made

# === Game Flow Events ===
signal room_entered(floor_number: int, room_name: String)
signal room_cleared(floor_number: int, room_name: String)
signal mini_boss_defeated(floor_number: int)
signal floor_completed(floor_number: int)
signal upgrade_collected(upgrade_data: Resource)
signal artifact_collected(artifact_data: Resource)


func _ready() -> void:
	# Bridge existing signals to counter signals
	enemy_limb_severed.connect(func(_e, _z): limb_severed.emit())
	weapon_thrown.connect(func(_w, _o, _d): weapon_was_thrown.emit())
