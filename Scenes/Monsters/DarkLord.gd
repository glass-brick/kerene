extends Area2D

signal start_music
signal stop_music
signal show_message

enum Actions { MESSAGE, PLAY_MUSIC, STOP_MUSIC, CHANGE_SPRITE, BREAK_TILEMAP }

export (Array, Actions) var actions = []
export (Array) var data = []
export (Array, int) var timings = []
var active = false
var current_action_index = 0
var player


func play_action():
	if current_action_index >= actions.size():
		return

	var current_action = actions[current_action_index]
	var current_timing = timings[current_action_index]
	var current_data = data[current_action_index]

	if current_action == Actions.MESSAGE:
		emit_signal("show_message", current_data, current_timing)
	elif current_action == Actions.PLAY_MUSIC:
		emit_signal("start_music", current_data, false)
	elif current_action == Actions.STOP_MUSIC:
		emit_signal("stop_music", false)
	elif current_action == Actions.CHANGE_SPRITE:
		$AnimatedSprite.play(current_data)
	elif current_action == Actions.BREAK_TILEMAP:
		var children = get_children()
		for child in children:
			if child is TileMap:
				child.queue_free()

	$Timer.wait_time = current_timing
	$Timer.start()


func _on_Timer_timeout():
	current_action_index += 1
	if current_action_index >= actions.size() and player.has_method('unlock'):
		player.unlock()
	play_action()


func _on_DarkLord_body_entered(body):
	player = body
	if player.has_method('lock'):
		player.lock()
	active = true
	play_action()
