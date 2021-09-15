extends PlaneMap

var GlobalNavigation

func set_cell(x, y, tile, flip_x = false, flip_y = false, transpose = false, autotile_coord = Vector2()):
	if tile == 1:
		GlobalNavigation.remove_cell(x, y)
	else:
		GlobalNavigation.add_cell(x, y)
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
