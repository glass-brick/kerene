extends Area2D


func _on_Checkpoint_body_entered(body):
	if body.has_method("save"):
		body.save()
		self.queue_free()
