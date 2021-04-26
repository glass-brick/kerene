extends CanvasLayer

var paused = false
func _ready():
	$Death_msg.hide()
	$Restart.hide() # Replace with function body.
	$Yes.hide()
	$No.hide()

func _physics_process(delta):
	var restart = Input.is_action_just_pressed("ui_end")
	if restart:
		if not paused:
			self.ask_restart()
		else:
			self._on_No_pressed()


func update_health(health):
	$Health.text = "Health: " + str(health)
	$Health.show()
	
func player_is_dead():
	$Death_msg.show()

func update_active_item(item):
	$CurrentItem.text = "Current Item: " + str(item)
	$CurrentItem.show()

func ask_restart():
	paused = true
	$Restart.show()
	$Yes.show()
	$No.show()
	get_tree().paused = true


func _on_Yes_pressed():
	paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_No_pressed():
	paused = false
	$Restart.hide() # Replace with function body.
	$Yes.hide()
	$No.hide()
	get_tree().paused = false

