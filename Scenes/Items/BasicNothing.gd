var item_name = "BasicNothing"

var item_owner = false


func _init(player):
	item_owner = player


func use(time_since_last_use):
	return false
