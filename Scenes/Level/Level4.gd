extends Node2D

var music_fading_in = []
var music_fading_out = []
export (int) var fade_in_speed = 6
export (int) var fade_out_speed = 3
var player

func _ready():
	for node in get_children():
		if node.get_filename() == "res://Scenes/Level/MusicTrigger.tscn": 
			node.connect("start_music", self, "_play_music")
		if node.get_filename() == "res://Scenes/Level/MusicStopper.tscn": 
			node.connect("stop_music", self, "_stop_music")
		if node.get_filename() == "res://Scenes/Level/MessageTrigger.tscn": 
			node.connect("show_message", self, "_show_message")
			print("encuentra uno")
		if node.get_filename() == "res://Scenes/Player/Player.tscn":
			player = node

func _play_music(name, fadein):
	_stop_music(false)
	var targetNode = get_node("Music/"+str(name))
	if targetNode.has_method("play"):
		if fadein:
			music_fading_in.append(targetNode)
			targetNode.volume_db = -60
		targetNode.play()
		
		
func _stop_music(fadeout):
	for node in get_node("Music").get_children():
		if node.has_method('stop'):
			if fadeout:
				music_fading_out.append(node)
			else:
				node.stop()

func _show_message(message, time):
	player.show_message(message, time)
	
func _physics_process(delta):
	for node in music_fading_in:
		node.volume_db += delta * fade_in_speed
		if node.volume_db > 0:
			music_fading_in.remove(music_fading_in.bsearch(node))
	for node in music_fading_out:
		node.volume_db -= delta * fade_out_speed
		if node.volume_db < -80:
			music_fading_out.remove(music_fading_in.bsearch(node))
			node.stop()

