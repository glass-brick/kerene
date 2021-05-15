extends Control

signal message_finished
signal dialogue_finished

var queued_messages = []
var current_message = null
var progress = 0
var finished = false
var speed = 1


func _ready():
	self.visible = false


func _process(delta):
	if not current_message:
		return

	var key_pressed = Input.is_action_just_pressed('click')

	if key_pressed:
		if finished:
			continue_dialogue()
		else:
			progress = 1

	progress = min(progress + speed * delta, 1)
	$Dialogue.percent_visible = progress

	if progress == 1:
		finished = true
		$Caret.visible = true


func continue_dialogue():
	if queued_messages.empty():
		self.visible = false
		current_message = null
		emit_signal("dialogue_finished")
	else:
		display_message(queued_messages[0])
		queued_messages.pop_front()
		emit_signal("message_finished")


func display_message(message):
	self.visible = true
	current_message = message
	progress = 0
	$Dialogue.text = current_message
	$Dialogue.percent_visible = progress
	$Caret.visible = false


func start_dialogue(messages, options = {}):
	display_message(messages[0])
	if "speed" in options:
		speed = options["speed"]
	queued_messages = messages
	queued_messages.pop_front()
