extends Navigation2D



# Public Methods
func add_cell(x, y):
	$TileMap.set_cell(x, y, 0)
	
func add_cellv(pos):
	$TileMap.set_cell(pos, 0)

func remove_cell(x, y):
	$TileMap.set_cell(x, y, -1)
	
func remove_cellv(pos):
	$TileMap.set_cell(pos, -1)
	
func search_path(start: Vector2, end: Vector2, optimize: bool = true):
	
	if Settings.record_navigation_details:
		if optimize:
			LogRecorder.record("Calculated optimized path from " + str(start) + " to " + str(end))
		else:
			LogRecorder.record("Calculated path from " + str(start) + " to " + str(end))
	
	return get_simple_path(start * Settings.cell_size, end * Settings.cell_size, optimize)
