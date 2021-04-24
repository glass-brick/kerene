extends TileMap


func mine(tilePosition):
	set_cellv(tilePosition, -1)
	update_bitmask_region()


func is_mineable(tilePosition):
	return get_cellv(tilePosition) == 0
