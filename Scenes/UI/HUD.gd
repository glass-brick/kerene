extends CanvasLayer

signal dialogue_finished

export (int) var message_time = 1
var time_passed = 0
var paused = false


func _ready():
	$Death_msg.hide()
	$Restart.hide()  # Replace with function body.
	$Yes.hide()
	$No.hide()


func _physics_process(delta):
	var restart = Input.is_action_just_pressed("ui_end")
	if restart:
		if not paused:
			self.ask_restart()
		else:
			self._on_No_pressed()
	if time_passed > message_time:
		$Message.modulate = Color(
			$Message.modulate.r,
			$Message.modulate.g,
			$Message.modulate.b,
			$Message.modulate.a - delta
		)
	elif $Message.modulate.a < 1:
		$Message.modulate = Color(
			$Message.modulate.r,
			$Message.modulate.g,
			$Message.modulate.b,
			$Message.modulate.a + delta
		)
	else:
		time_passed += delta


func update_health(health):
	$Health.text = str(health)
	$Health.show()
	$Health_bat.set_value(health)


func player_is_dead():
	$Death_msg.show()


func update_active_item(item):
	$Weapons/Sword/Sword_image.modulate = Color(255, 255, 255, 255)
	$Weapons/Sword/Label.modulate = Color(255, 255, 255, 255)
	$Weapons/Wand/Wand_image.modulate = Color(255, 255, 255, 255)
	$Weapons/Wand/Label.modulate = Color(255, 255, 255, 255)
	$Weapons/Wand.modulate = Color(255, 255, 255, 255)
	if item == "basic_attack":
		$Weapons/Sword.show()
		$Weapons/Sword/Sword_image.modulate = Color(255, 255, 0, 255)
		$Weapons/Sword/Label.modulate = Color(0, 0, 255, 255)
	if item == "basic_projectile_attack":
		$Weapons/Wand.show()
		$Weapons/Wand/Wand_image.modulate = Color(255, 255, 0, 255)
		$Weapons/Wand/Label.modulate = Color(0, 0, 255, 255)


func ask_restart():
	paused = true
	$Restart.show()
	$Yes.show()
	$No.show()
	$Controls.show()
	get_tree().paused = true


func _on_Yes_pressed():
	paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_No_pressed():
	paused = false
	$Restart.hide()  # Replace with function body.
	$Yes.hide()
	$No.hide()
	$Controls.hide()
	get_tree().paused = false


func show_message(message, time):
	time_passed = 0
	message_time = time
	$Message.text = message
	$Message.modulate = Color($Message.modulate.r, $Message.modulate.g, $Message.modulate.b, 0)
	$Message.show()


func start_dialogue(messages, options = {}):
	$DialogueBox.start_dialogue(messages, options)


func _on_dialogue_finished():
	emit_signal("dialogue_finished")


func _on_message_finished():
	emit_signal("message_finished")
