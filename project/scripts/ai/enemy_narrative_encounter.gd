extends CharacterBody2D

## NarrativeEncounter — Placeholder interactive entity for Floor 9 (Satan's Sanctum).
## Used for The Sister and special story encounters.
## NOT a combatant — stands in place with a dialogue trigger zone.
## Will be replaced with full Sister/Satan boss scripts in M7.4.

signal interaction_triggered(entity: CharacterBody2D)

@export var entity_name: String = "Narrative Entity"

var _player_nearby: bool = false


func _ready() -> void:
	# Create interaction area for player proximity detection
	var interaction_area := Area2D.new()
	interaction_area.name = "InteractionArea"
	var shape := CircleShape2D.new()
	shape.radius = 40.0
	var collision := CollisionShape2D.new()
	collision.shape = shape
	interaction_area.add_child(collision)
	add_child(interaction_area)

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		interaction_triggered.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
