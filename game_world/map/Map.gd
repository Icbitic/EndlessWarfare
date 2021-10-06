extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}

const CHUNK_SIZE = 16
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE
const CHUNK_END_SIZE = CHUNK_SIZE - 1
const WORLD_HEIGHT = 5

var map_size

var thread

var chunks: Chunks
var chunks_data: Dictionary setget set_chunks_data

var is_generated = false

func _exit_tree():
	if thread != null:
		thread.wat_to_finish()

func exit_loading():
	remove_commands()

func setup():
	$Wall.GlobalNavigation = $Navigation
	$Terrain.GlobalNavigation = $Navigation
	
	Logger.info("Game world objects are linked to the Map node.")
	
	add_commands()
	
	if not is_generated:
		map_size = Settings.map_size
		
		# Todo: use thread to generate chunks.
		#thread = Thread.new()
		#thread.start(self, "generate")
		
		chunks = Chunks.new()
		chunks.setup(map_size)
		generate(map_size)
		
		is_generated = true
	
	update_tilemap()

func add_commands():
	Console.add_command("setterrain", self, "setterrain_cmd")\
	.set_description("Set terrain.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setpath", self, "setpath_cmd")\
	.set_description("Set path.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setfloor", self, "setfloor_cmd")\
	.set_description("Set floor.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setfence", self, "setfence_cmd")\
	.set_description("Set fence.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setwall", self, "setwall_cmd")\
	.set_description("Set wall.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setcell", self, "setcell_cmd")\
	.set_description("Set cell.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("pos_z", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
func remove_commands():
	Console.remove_command("setterrain")
	Console.remove_command("setpath")
	Console.remove_command("setfloor")
	Console.remove_command("setfence")
	Console.remove_command("setwall")
	Console.remove_command("setcell")
	
func get_persist_data():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"chunks_data": chunks.get_persist_data(),
		"map_size": map_size,
		"is_generated": is_generated
	}
	return save_dict

func set_chunks_data(value: Dictionary):
	chunks = null
	chunks = Chunks.new()
	chunks.setup(value.map_size)
	for i in value.keys():
		if i == "map_size":
			continue
		chunks.set(i, value[i])

func update_tilemap():
	Logger.info("Starting drawing the data from chunks to the Tilemaps.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	_draw_chunks(false)
	Logger.info("The data from Chunks were drawn into Tilemaps.")
	
	$Terrain.update_bitmask_region()
	$Fence.update_bitmask_region()
	$Path.update_bitmask_region()
	$Wall.update_bitmask_region()
	$Floor.update_bitmask_region()
	
	Logger.info("Terrain's bitmask is updated.")
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.info("Finished drawing the data from chunks to the Tilemaps in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.info("The memory usage when drawing the "+ str(map_size) + "x map to Tilemaps is "
			+ String.humanize_size(final_memory_usage - initial_memory_usage))

func setterrain_cmd(x, y, tile):
	set_cell(x, y, TERRAIN, tile)
	Console.write_line("Terrain set at (" + str(x) + " " + str(y) + ")")

func setpath_cmd(x, y, tile):
	set_cell(x, y, PATH, tile)
	Console.write_line("Path set at (" + str(x) + ", " + str(y) + ")")
	
func setfloor_cmd(x, y, tile):
	set_cell(x, y, FLOOR, tile)
	Console.write_line("Floor set at (" + str(x) + ", " + str(y) + ")")
	
func setfence_cmd(x, y, tile):
	set_cell(x, y, FENCE, tile)
	Console.write_line("Fence set at (" + str(x) + ", " + str(y) + ")")
	
func setwall_cmd(x, y, tile):
	set_cell(x, y, WALL, tile)
	Console.write_line("Wall set at (" + str(x) + ", " + str(y) + ")")
	
func setcell_cmd(x, y, z, tile):
	set_cell(x, y, z, tile)
	Console.write_line("Cell set at (" + str(x) + ", " + str(y) + ")")

func set_cell(x, y, z, tile, update_bitmask = true):
	var result = chunks.set_cell(x, y, z, tile)
	
	chunks.set_cell(x, y, z, tile)
	
	# BIG BIG BIG Todo: Detect if it is available to set the cell.
	
#	# Post process the map
#	# First to remove the cells of wrong bitmasks
#	var template1 = [
#		LAND, LAND, WATER,
#		LAND, LAND, LAND,
#		WATER, LAND, LAND
#	]
#	var template2 = [
#		WATER, LAND, LAND,
#		LAND, LAND, LAND,
#		LAND, LAND, WATER
#	]
#
#	var _map_cache = []
#	_map_cache.resize(5)
#	for i in range(5):
#		var _column_cache = []
#		_column_cache.resize(5)
#		_map_cache[i] = _column_cache
#
#	for i in range(5):
#		for j in range(5):
#			_map_cache[i][j] = chunks.get_cell(x - 2 + i, y - 2 + j, TERRAIN)
#
#	for i in range(x - 1, x + 2):
#		for j in range(y - 1, y + 2):
#			var nearby = [
#				_map_cache[i - x][j - y], _map_cache[i - x + 1][j - y], _map_cache[i + 2 - x][j - y],
#				_map_cache[i - x][j - y + 1], _map_cache[i - x + 1][j - y + 1], _map_cache[i + 2 - x][j - y + 1],
#				_map_cache[i - x][j + 2 - y], _map_cache[i - x + 1][j + 2 - y], _map_cache[i + 2 - x][j + 2 - y]
#			]
#			print(Vector2(i, j), nearby)
#			print(template2)
#			print(nearby.hash() == template2.hash())
#			if nearby.hash() == template1.hash() or nearby.hash() == template2.hash():
#				for m in range(i - 1, i + 2):
#					for n in range(j - 1, j + 2):
#						chunks.set_cell(m, n, TERRAIN, tile)
#						_draw_cell(m, n, TERRAIN, update_bitmask)
#	print("===============")

	_draw_cell(x, y, z, update_bitmask)
	return result

# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cell(x, y, z):
	return chunks.get_cell(x, y, z)

func generate(size):
	Logger.info("Starting generating the map.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	chunks.generate()
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.info("Finished generating a(n) "+ str(size) + "x map in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.info("The memory usage of the "+ str(size) + "x map's data is " + 
			String.humanize_size(final_memory_usage - initial_memory_usage))
	return OK
	
	
func _draw_cell(x, y, z, update_bitmask = true):
	match z:
		TERRAIN:
			$Terrain.set_cell(x, y, get_cell(x, y, TERRAIN))
			if update_bitmask:
				$Terrain.update_bitmask_region(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1))
			return OK
		PATH:
			$Path.set_cell(x, y, get_cell(x, y, PATH))
			if update_bitmask:
				$Path.update_bitmask_region(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1))
			return OK
		FLOOR:
			$Floor.set_cell(x, y, get_cell(x, y, FLOOR))
			if update_bitmask:
				$Floor.update_bitmask_region(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1))
			return OK
		FENCE:
			$Fence.set_cell(x, y, get_cell(x, y, FENCE))
			if update_bitmask:
				$Fence.update_bitmask_region(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1))
			return OK
		WALL:
			$Wall.set_cell(x, y, get_cell(x, y, WALL))
			if update_bitmask:
				$Wall.update_bitmask_region(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1))
			return OK
		_:
			return ERR_DOES_NOT_EXIST
			
func _draw_chunks(update_bitmask = false):
	for position in chunks.get_all_cells().keys():
		# This is for an unknow bug.
		if position.z == PATH:
			_draw_cell(position.x, position.y, PATH, update_bitmask)
		if position.z == FLOOR:
			_draw_cell(position.x, position.y, FLOOR, update_bitmask)
		if position.z == FENCE:
			_draw_cell(position.x, position.y, FENCE, update_bitmask)
		if position.z == WALL:
			_draw_cell(position.x, position.y, WALL, update_bitmask)
			
	for i in range(chunks.map_size):
		for j in range(chunks.map_size):
			_draw_cell(i, j, TERRAIN, update_bitmask)
	return OK
