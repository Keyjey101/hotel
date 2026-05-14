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


## IMPORTANT: EventBus is a singleton Autoload. Do NOT re-instantiate or reload it.

var _conn_limb_severed: Callable
var _conn_weapon_thrown: Callable
var _conn_basement_escaped: Callable


func _ready() -> void:
	_conn_limb_severed = func(_e, _z): limb_severed.emit()
	_conn_weapon_thrown = func(_w, _o, _d): weapon_was_thrown.emit()
	enemy_limb_severed.connect(_conn_limb_severed)
	weapon_thrown.connect(_conn_weapon_thrown)
	if GameManager != null and GameManager.has_signal("basement_escaped"):
		_conn_basement_escaped = func(): basement_was_escaped.emit()
		GameManager.basement_escaped.connect(_conn_basement_escaped)
	elif GameManager == null:
		get_tree().node_added.connect(_on_node_added_for_gamemanager)


func _exit_tree() -> void:
	if enemy_limb_severed.is_connected(_conn_limb_severed):
		enemy_limb_severed.disconnect(_conn_limb_severed)
	if weapon_thrown.is_connected(_conn_weapon_thrown):
		weapon_thrown.disconnect(_conn_weapon_thrown)
	if _conn_basement_escaped.is_valid() and GameManager != null and GameManager.basement_escaped.is_connected(_conn_basement_escaped):
		GameManager.basement_escaped.disconnect(_conn_basement_escaped)
	if get_tree().node_added.is_connected(_on_node_added_for_gamemanager):
		get_tree().node_added.disconnect(_on_node_added_for_gamemanager)


func _on_node_added_for_gamemanager(node: Node) -> void:
	if node.name == "GameManager" and node.has_signal("basement_escaped"):
		if not _conn_basement_escaped.is_valid():
			_conn_basement_escaped = func(): basement_was_escaped.emit()
		if not node.basement_escaped.is_connected(_conn_basement_escaped):
			node.basement_escaped.connect(_conn_basement_escaped)
		if get_tree().node_added.is_connected(_on_node_added_for_gamemanager):
			get_tree().node_added.disconnect(_on_node_added_for_gamemanager)
