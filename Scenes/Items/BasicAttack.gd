var item_name = "BasicAttack"

var item_owner = false

func use():
	# Copy paste furioso del codigo en cursor
	item_owner.play_cut_audio()
	var target = item_owner.get_global_mouse_position()
	var space_state = item_owner.get_world_2d().direct_space_state

	var intersections = space_state.intersect_point(target, 1, [item_owner, item_owner.tilemap])
	if not intersections.empty():
		var target_thing = intersections[0].collider

		if target_thing.collision_layer == 2:
			if target_thing.has_method('_on_hit'):
				target_thing.call('_on_hit', item_owner.damage)

