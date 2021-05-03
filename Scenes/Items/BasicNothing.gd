var item_name = "BasicNothing"

var item_owner = false


func _init(player):
	item_owner = player


func can_use(_time_since_last_use):
	return false


func use():
	pass
