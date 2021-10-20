extends PlaneMap

enum {LAND, WATER}

var GlobalNavigation

func set_cell(x, y, tile, flip_x = false, flip_y = false, transpose = false, autotile_coord = Vector2()):
	# Moved to Node Map.
#	if tile == WATER:
#		GlobalNavigation.remove_cell(x, y)
#	else:
#		GlobalNavigation.add_cell(x, y)
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
