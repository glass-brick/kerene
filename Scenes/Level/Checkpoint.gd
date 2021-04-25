extends Area2D

var active = false


func _process(_delta):
	if not active and not get_overlapping_bodies().empty():
		active = true
		var root = get_tree().get_root().get_child(0)
		root.current_checkpoint = get_path()
