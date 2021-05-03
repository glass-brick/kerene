var item_name = "basic_attack"

var item_owner = false
var cooldown = 0.5


func _init(player):
	item_owner = player


func can_use(time_since_last_use):
	return time_since_last_use > cooldown


func use():
	item_owner.play_cut_audio()
	var is_left_side = item_owner.sprite.flip_h

	if is_left_side:
		item_owner.player_attack.attack_left(30)
	else:
		item_owner.player_attack.attack_right(30)
