extends Area2D

signal start_music


export (String) var music_track
export (bool) var fadein


func _on_MusicTrigger_body_entered(body):
	print("suena")
	if body.has_method("_on_heal"):
		emit_signal("start_music", music_track, fadein)
		self.queue_free()
	

