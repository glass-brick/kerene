extends Area2D

export (Script) var weapon_script
export (String) var weapon_name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if body.has_method("pickup_item"):
		if body.pickup_item(weapon_name):
			self.queue_free()
