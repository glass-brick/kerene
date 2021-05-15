extends Node

signal message_finished
signal dialogue_finished

onready var hud = get_node('/root/Level/HUD')
onready var player = get_node('/root/Level/Player')


func _ready():
	hud.connect("message_finished", self, "on_message_finished")
	hud.connect("dialogue_finished", self, "on_dialogue_finished")


func show_message(message, time):
	hud.show_message(message, time)


func start_dialogue(messages, options = {}):
	hud.start_dialogue(messages, options)


func on_message_finished():
	emit_signal("message_finished")


func on_dialogue_finished():
	emit_signal("dialogue_finished")


var music_fading_in = []
var fade_in_speed = 6


func start_music(name, fadein):
	stop_music(false)
	var targetNode = get_node("/root/Level/Music/" + str(name))
	if targetNode.has_method("play"):
		if fadein:
			music_fading_in.append(targetNode)
			targetNode.volume_db = -60
		else:
			targetNode.volume_db = 0

		targetNode.play()


var music_fading_out = []
var fade_out_speed = 3


func stop_music(fadeout):
	for node in get_node("/root/Level/Music").get_children():
		if node.has_method('stop') and node.is_playing():
			if fadeout:
				music_fading_out.append(node)
			else:
				node.stop()


func _process(delta):
	for node in music_fading_in:
		node.volume_db += delta * fade_in_speed
		if node.volume_db > 0:
			music_fading_in.remove(music_fading_in.bsearch(node))
	for node in music_fading_out:
		node.volume_db -= delta * fade_out_speed
		if node.volume_db < -80:
			music_fading_out.remove(music_fading_out.bsearch(node))
			node.stop()


func save_checkpoint():
	player.save()


func restart_level():
	music_fading_in = []
	music_fading_out = []
	get_tree().reload_current_scene()
