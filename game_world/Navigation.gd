extends Navigation2D



# Public Methods
func search_path(start: Vector2, end: Vector2, optimize: bool = true):
	
	if Info.settings.record_navigation_details:
		if optimize:
			LogRecorder.record("Calculated optimized path from "
					+ str(start) + " to " + str(end))
		else:
			LogRecorder.record("Calculated path from "
					+ str(start) + " to " + str(end))
	
	return get_simple_path(start * Info.constant.cell_size,
			end * Info.constant.cell_size, optimize)
