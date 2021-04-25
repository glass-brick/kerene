extends TileMap


func mine(tile_position):
	set_cellv(tile_position, -1)
	update_bitmask_region()


func is_mineable(tile_position):
	return get_cellv(tile_position) == 0


func is_stair(tile_position):
	return get_cellv(tile_position) == 2
