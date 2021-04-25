extends Area2D


export (int) var life = 20


func _on_Node2D_body_entered(body):
	if body.has_method('_on_heal'):
		body._on_heal(self.life)
		self.queue_free()
