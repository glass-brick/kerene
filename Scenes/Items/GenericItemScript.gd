extends Script

var item_name = "generic_item"

var item_owner = false

func use():
	print("hola pibe")
	item_owner.spend_active_item()

