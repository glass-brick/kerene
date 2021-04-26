extends Area2D

signal stop_music

export (bool) var fadeout



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MusicTrigger_body_entered(body):
	if body.has_method("_on_heal"):
		emit_signal("stop_music", fadeout)
		self.queue_free()

