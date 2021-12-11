extends TileMap

var GlobalNavigation

# Terrain cells must be on the top of the mapping list to improve performance.
func set_cell(x, y, tile, flip_x = false, flip_y = false, transpose = false, autotile_coord = Vector2()):
	# Moved to Node Map.
#	if tile == WATER:
#		GlobalNavigation.remove_cell(x, y)
#	else:
#		GlobalNavigation.add_cell(x, y)
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
