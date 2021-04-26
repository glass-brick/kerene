var item_name = "basic_attack"

var item_owner = false
var cooldown = -1


func _init(player):
	item_owner = player


func use(time_since_last_use):
	if time_since_last_use > cooldown:
		item_owner.play_cut_audio()
		var is_left_side = item_owner.sprite.flip_h

		if is_left_side:
			item_owner.player_attack.attack_left(10)
		else:
			item_owner.player_attack.attack_right(10)
		return true
	return false
