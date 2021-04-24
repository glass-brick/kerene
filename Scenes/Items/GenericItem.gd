extends Area2D


export (Node) var weapon_script

func pick_up_item():
	self.queue_free()

func _on_Area2D_body_entered(body):
	if body.has_method("pickup_item"):
		body.pickup_item(weapon_script)
	print("item is being pass oon")


