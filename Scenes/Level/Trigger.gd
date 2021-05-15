tool
extends Area2D

enum TriggerTypes { MESSAGE, MUSIC_START, MUSIC_STOP, CHECKPOINT }

export (TriggerTypes) var trigger_type setget set_trigger_type, get_trigger_type
var music_track
var fadeout
var fadein
var message = "Message"
var time = 2


func set_trigger_type(new_type):
	trigger_type = new_type
	property_list_changed_notify()


func get_trigger_type():
	return trigger_type


func _get_property_list():
	if trigger_type == TriggerTypes.MESSAGE:
		return [
			{
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
				"name": "message",
				"type": TYPE_STRING
			},
			{
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
				"name": "time",
				"type": TYPE_INT
			}
		]
	elif trigger_type == TriggerTypes.MUSIC_START:
		return [
			{
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
				"name": "music_track",
				"type": TYPE_STRING
			},
			{
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
				"name": "fadein",
				"type": TYPE_BOOL
			}
		]
	elif trigger_type == TriggerTypes.MUSIC_STOP:
		return [
			{
				"hint": PROPERTY_HINT_NONE,
				"usage": PROPERTY_USAGE_DEFAULT,
				"name": "fadeout",
				"type": TYPE_BOOL
			}
		]
	return []


func _on_Trigger_body_entered(_body):
	print(_body)
	var globals = get_node('/root/Globals')
	if trigger_type == TriggerTypes.MESSAGE:
		globals.show_message(message, time)
	elif trigger_type == TriggerTypes.MUSIC_START:
		globals.start_music(music_track, fadein)
	elif trigger_type == TriggerTypes.MUSIC_STOP:
		globals.stop_music(fadeout)
	elif trigger_type == TriggerTypes.CHECKPOINT:
		globals.save_checkpoint()
	self.queue_free()
