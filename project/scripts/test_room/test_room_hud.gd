extends CanvasLayer

## TestRoomHUD — Live debug HUD for the test room.

@onready var hp_bar: ColorRect = %HPBar
@onready var hp_bg: ColorRect = %HPBarBG
@onready var debug_label: RichTextLabel = %DebugLabel

var _player: CharacterBody2D


func _ready() -> void:
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if not _player or not is_instance_valid(_player):
		return

	# HP bar
	var hp := _player.get_hp()
	var max_hp := _player.get_max_hp()
	var ratio := hp / maxf(max_hp, 1.0)
	hp_bar.size.x = 120.0 * ratio

	# Debug info
	var pos := _player.global_position
	var state := GameManager.run_state
	var enemies := get_tree().get_nodes_in_group("enemy").size()

	debug_label.text = "[color=yellow]HP: %.0f/%.0f[/color]  Pos: %.0f,%.0f  Enemies: %d" % [hp, max_hp, pos.x, pos.y, enemies]
