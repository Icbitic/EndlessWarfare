extends Navigation2D

signal cell_added(pos)
signal cell_removed(pos)
signal updated

# Public Methods
func add_cell(x, y):
	$TileMap.set_cell(x, y, 0)
	emit_signal("cell_added", Vector2(x, y))
	
func add_cellv(pos):
	$TileMap.set_cell(pos, 0)
	emit_signal("cell_added", pos)

func remove_cell(x, y):
	$TileMap.set_cell(x, y, -1)
	emit_signal("cell_removed", Vector2(x, y))
	
func remove_cellv(pos):
	$TileMap.set_cell(pos, -1)
	emit_signal("cell_removed", pos)
	
func update():
	$TileMap.update_dirty_quadrants()
	emit_signal("updated")
	
func search_path(start: Vector2, end: Vector2, optimize: bool = true):
	
	if Settings.record_navigation_details:
		if optimize:
			Logger.info("Calculated optimized path from " + str(start) + " to " + str(end))
		else:
			Logger.info("Calculated path from " + str(start) + " to " + str(end))
	
	return get_simple_path(start * Settings.cell_size, end * Settings.cell_size, optimize)
