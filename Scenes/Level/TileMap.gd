extends TileMap


func mine(tile_position):
	set_cellv(tile_position, -1)


func is_mineable(tile_position):
	return get_cellv(tile_position) == 0


func is_stair(tile_position):
	return get_cellv(tile_position) == 2


func map_to_global(tile_position):
	return to_global(map_to_world(tile_position))


func global_to_map(global_pos):
	return world_to_map(to_local(global_pos))
