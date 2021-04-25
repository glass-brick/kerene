extends Area2D

export (int) var damage = 20

func _on_Node2D_body_entered(body):
	if body.has_method('_on_hit'):
		body._on_hit(self.damage)
