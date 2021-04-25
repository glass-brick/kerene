extends CanvasLayer

func _ready():
	$Death_msg.hide()

func update_health(health):
	$Health.text = "Health: " + str(health)
	$Health.show()
	
func player_is_dead():
	$Death_msg.show()

func update_active_item(item):
	$CurrentItem.text = "Current Item: " + str(item)
	$CurrentItem.show()

	
