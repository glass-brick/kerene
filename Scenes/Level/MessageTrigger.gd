extends Area2D

signal show_message

export (String) var message = "Message"
export (int) var time = 2

func _on_MusicTrigger_body_entered(body):
	print("trigger")
	if body.has_method("_on_heal"):
		emit_signal("show_message", message, time)
		self.queue_free()

