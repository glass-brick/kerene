extends Camera2D

var isZoomedOut = false


func _process(_delta):
	var enter = Input.is_action_just_pressed("zoom")

	if enter:
		isZoomedOut = not isZoomedOut
		if isZoomedOut:
			zoom.x = 1
			zoom.y = 1
		else:
			zoom.x = 0.5
			zoom.y = 0.5
