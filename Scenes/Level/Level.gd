extends Node2D
signal on_player_lose

export (NodePath) var current_checkpoint = null


func _ready():
	randomize()
	print(current_checkpoint)
	if current_checkpoint != null:
		$Player.position = get_node(current_checkpoint).position


func _on_Player_player_died():
	emit_signal("on_player_lose")
