var item_name = "generic_item"

var item_owner = false


func use(time_since_last_use):
	item_owner.spend_active_item()
	return true
