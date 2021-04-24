extends Camera2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var enter = Input.is_action_pressed("ui_accept")
	if enter:
		zoom.x = 1
		zoom.y = 1
	else:
		zoom.x = 0.5
		zoom.y = 0.5
