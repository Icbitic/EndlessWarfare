extends PlaneMap

var cell = {
	-1: -1,
	6: 0,
	7: 1,
	8: 2
}

func set_cell(x, y, tile, flip_x = false, flip_y = false, transpose = false, autotile_coord = Vector2()):
	if cell.has(tile):
		.set_cell(x, y, cell[tile], flip_x, flip_y, transpose, autotile_coord)
		return OK
	else:
		return ERR_DOES_NOT_EXIST
