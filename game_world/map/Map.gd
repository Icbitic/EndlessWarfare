extends Node

signal cell_set(pos, tile)
signal tilemap_updated
signal map_generated

enum {TERRAIN, PATH, FLOOR, FENCE, WALL, PLANT}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD, CEMENT_ROAD, MUD_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}
enum {TREE, DEAD_TREE, BUSH}

const CHUNK_SIZE = 16
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE
const CHUNK_END_SIZE = CHUNK_SIZE - 1
const WORLD_HEIGHT = 5
const TEXTURE_SHEET_WIDTH = 8

var map_id setget _set_map_id
var saven_id

var map_size

var thread

var chunks: Chunks
var chunks_data: Dictionary setget _set_chunks_data

var trees = {}

var is_generated = false

onready var tree = preload("res://game_world/objects/plants/tree/tree.tscn")
onready var dead_tree = preload("res://game_world/objects/plants/tree/dead_tree.tscn")
onready var bush = preload("res://game_world/objects/plants/tree/bush.tscn")

func _exit_tree():
	if thread != null:
		thread.wat_to_finish()
	_remove_commands()

func _ready():
	add_to_group("Persist")
	$Wall.GlobalNavigation = $Navigation
	$Terrain.GlobalNavigation = $Navigation
	
	Logger.info("Game world objects are linked to the Map node.")
	
	_add_commands()
	
	if not is_generated:
		map_size = Settings.map_size
		
		# Todo: use thread to generate chunks.
		#thread = Thread.new()
		#thread.start(self, "generate")
		
		chunks = Chunks.new()
		chunks.setup(map_size)
		_generate(map_size)
		
		is_generated = true
	
	_update_tilemap()

# Public Methods
func save():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"chunks_data": chunks.get_persist_data(),
		"map_size": map_size,
		"is_generated": is_generated
	}
	return save_dict

func set_cell(x, y, z, tile, update_bitmask = true):
	var result = chunks.set_cell(x, y, z, tile)
	
	if z == TERRAIN and tile == WATER:
		_remove_fixed_objects(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1))
	if not z == TERRAIN and chunks.get_cell(x, y, TERRAIN) == LAND:
		return ERR_CANT_CREATE
	
	_update_navigation_cell(x, y)
	
	_draw_cell(x, y, z, update_bitmask)
	emit_signal("cell_set", Vector3(x, y, z), tile)
	return result

# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cell(x, y, z):
	return chunks.get_cell(x, y, z)

# Private Methods
func _generate(size):
	Logger.info("Starting generating the map.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	chunks.generate()
	
	emit_signal("map_generated")
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.info("Finished generating a(n) "+ str(size) + "x map in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.info("The memory usage of the "+ str(size) + "x map's data is " + 
			String.humanize_size(final_memory_usage - initial_memory_usage))
	return OK
	
func _set_chunks_data(value: Dictionary):
	chunks = null
	chunks = Chunks.new()
	chunks.setup(value.map_size)
	for i in value.keys():
		if i == "map_size":
			continue
		chunks.set(i, value[i])

# Generate the identifier in the saven.
func _set_map_id(value):
	map_id = value
	saven_id = "Map#" + str(map_id)

func _update_tilemap():
	Logger.info("Starting drawing the data from chunks to the Tilemaps.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	_draw_chunks(false)
	Logger.info("The data from Chunks were drawn into Tilemaps.")
	
	_update_navigation_mesh()
	
	$Terrain.update_bitmask_region()
	$Fence.update_bitmask_region()
	$Path.update_bitmask_region()
	$Wall.update_bitmask_region()
	$Floor.update_bitmask_region()

	Logger.info("Tilemaps' bitmask is updated.")
	
	emit_signal("tilemap_updated")
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.info("Finished drawing the data from chunks to the Tilemaps in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.info("The memory usage when drawing the "+ str(map_size) + "x map to Tilemaps is "
			+ String.humanize_size(final_memory_usage - initial_memory_usage))
	
func _draw_cell(x, y, z, update_bitmask = true):
	match z:
		TERRAIN:
			$Terrain.set_cell(x, y, get_cell(x, y, TERRAIN))
			if update_bitmask:
				$Terrain.update_bitmask_area(Vector2(x, y))
			return OK
		PATH:
			$Path.set_cell(x, y, get_cell(x, y, PATH))
			if update_bitmask:
				$Path.update_bitmask_area(Vector2(x, y))
			return OK
		FLOOR:
			$Floor.set_cell(x, y, get_cell(x, y, FLOOR))
			if update_bitmask:
				$Floor.update_bitmask_area(Vector2(x, y))
			return OK
		FENCE:
			$Fence.set_cell(x, y, get_cell(x, y, FENCE))
			if update_bitmask:
				$Fence.update_bitmask_area(Vector2(x, y))
			return OK
		WALL:
			$Wall.set_cell(x, y, get_cell(x, y, WALL))
			if update_bitmask:
				$Wall.update_bitmask_area(Vector2(x, y))
			return OK
		PLANT:
			match get_cell(x, y, PLANT):
				TREE:
					_add_plant(TREE, x, y)
				DEAD_TREE:
					_add_plant(DEAD_TREE, x, y)
				BUSH:
					_add_plant(BUSH, x, y)
				_:
					_remove_plant(x, y)
			return OK
		_:
			return ERR_DOES_NOT_EXIST
			
func _draw_cell_in_z_axis(x, y, update_bitmask = true):
	if chunks.has_cell(x, y, TERRAIN):
		$Terrain.set_cell(x, y, get_cell(x, y, TERRAIN))
		if update_bitmask:
			$Terrain.update_bitmask_area(Vector2(x, y))
			
	if chunks.has_cell(x, y, PATH):
		$Path.set_cell(x, y, get_cell(x, y, PATH))
		if update_bitmask:
			$Path.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, FLOOR):
		$Floor.set_cell(x, y, get_cell(x, y, FLOOR))
		if update_bitmask:
			$Floor.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, FENCE):
		$Fence.set_cell(x, y, get_cell(x, y, FENCE))
		if update_bitmask:
			$Fence.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, WALL):
		$Wall.set_cell(x, y, get_cell(x, y, WALL))
		if update_bitmask:
			$Wall.update_bitmask_area(Vector2(x, y))
	
	if chunks.has_cell(x, y, PLANT):
		match get_cell(x, y, PLANT):
			TREE:
				_add_plant(TREE, x, y)
			DEAD_TREE:
				_add_plant(DEAD_TREE, x, y)
			BUSH:
				_add_plant(BUSH, x, y)
			_:
				_remove_plant(x, y)
	
func _remove_cell_fixed_objects_in_z(x, y, update_bitmask = true):
	if chunks.has_cell(x, y, PATH):
		$Path.set_cell(x, y, -1)
		if update_bitmask:
			$Path.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, FLOOR):
		$Floor.set_cell(x, y, -1)
		if update_bitmask:
			$Floor.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, FENCE):
		$Fence.set_cell(x, y, -1)
		if update_bitmask:
			$Fence.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, WALL):
		$Wall.set_cell(x, y, -1)
		if update_bitmask:
			$Wall.update_bitmask_area(Vector2(x, y))
	
	if chunks.has_cell(x, y, PLANT):
		_remove_plant(x, y)
	
func _add_plant(plant_type, pos_x, pos_y):
	var tree_node
	
	if not trees.has(Vector2(pos_x, pos_y)):
		match plant_type:
			TREE:
				tree_node = tree.instance()
			DEAD_TREE:
				tree_node = dead_tree.instance()
			BUSH:
				tree_node = bush.instance()
				
		trees[Vector2(pos_x, pos_y)] = tree_node
		tree_node.position = Vector2(pos_x * TEXTURE_SHEET_WIDTH, pos_y * TEXTURE_SHEET_WIDTH)
		$Trees.add_child(tree_node)
		
func _remove_plant(pos_x, pos_y):
	if trees.has(Vector2(pos_x, pos_y)):
		trees[Vector2(pos_x, pos_y)].queue_free()
		trees.erase(Vector2(pos_x, pos_y))
		
func _remove_fixed_objects(from: Vector2, to: Vector2):
	for i in range(from.x, to.x + 1):
		for j in range(from.y, to.y + 1):
			chunks.clear_fixed_object(Vector2(i, j))
			_draw_cell_in_z_axis(i, j)
	return OK
	
func _draw_chunks(update_bitmask = false):
	for position in chunks.get_all_objects().keys():
		_draw_cell(position.x, position.y, int(position.z), update_bitmask)
			
	for i in range(chunks.map_size):
		for j in range(chunks.map_size):
			_draw_cell(i, j, TERRAIN, update_bitmask)
	return OK

func _update_navigation_mesh():
	for i in range(map_size):
		for j in range(map_size):
			if chunks.get_cell(i, j, TERRAIN) == LAND and (not chunks.has_cell(i, j, WALL)):
				$Navigation.add_cell(i, j)
			else:
				$Navigation.remove_cell(i, j)

func _update_navigation_cell(pos_x, pos_y):
	if chunks.get_cell(pos_x, pos_y, TERRAIN) == LAND and (not chunks.has_cell(pos_x, pos_y, WALL)):
		$Navigation.add_cell(pos_x, pos_y)
	else:
		$Navigation.remove_cell(pos_x, pos_y)

func _add_commands():
	Console.add_command("setterrain", self, "_setterrain_cmd")\
	.set_description("Set terrain.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setpath", self, "_setpath_cmd")\
	.set_description("Set path.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setfloor", self, "_setfloor_cmd")\
	.set_description("Set floor.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setfence", self, "_setfence_cmd")\
	.set_description("Set fence.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setwall", self, "_setwall_cmd")\
	.set_description("Set wall.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setplant", self, "_setplant_cmd")\
	.set_description("Set plant.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setcell", self, "_setcell_cmd")\
	.set_description("Set cell.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("pos_z", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("updatetilemap", self, "_updatetilemap_cmd")\
	.set_description("Update the tilemap.")\
	.register()
	
func _remove_commands():
	Console.remove_command("setterrain")
	Console.remove_command("setpath")
	Console.remove_command("setfloor")
	Console.remove_command("setfence")
	Console.remove_command("setwall")
	Console.remove_command("setplant")
	Console.remove_command("setcell")
	Console.remove_command("updatetilemap")
	
func _setterrain_cmd(x, y, tile):
	set_cell(x, y, TERRAIN, tile)
	Console.write_line("Terrain set at (" + str(x) + " " + str(y) + ")")
	Logger.info("Terrain set at (" + str(x) + " " + str(y) + ")")

func _setpath_cmd(x, y, tile):
	set_cell(x, y, PATH, tile)
	Console.write_line("Path set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Path set at (" + str(x) + ", " + str(y) + ")")
	
func _setfloor_cmd(x, y, tile):
	set_cell(x, y, FLOOR, tile)
	Console.write_line("Floor set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Floor set at (" + str(x) + ", " + str(y) + ")")
	
func _setfence_cmd(x, y, tile):
	set_cell(x, y, FENCE, tile)
	Console.write_line("Fence set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Fence set at (" + str(x) + ", " + str(y) + ")")
	
func _setwall_cmd(x, y, tile):
	set_cell(x, y, WALL, tile)
	Console.write_line("Wall set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Wall set at (" + str(x) + ", " + str(y) + ")")
	
func _setplant_cmd(x, y, tile):
	set_cell(x, y, PLANT, tile)
	Console.write_line("Plant set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Plant set at (" + str(x) + ", " + str(y) + ")")
	
func _setcell_cmd(x, y, z, tile):
	set_cell(x, y, z, tile)
	Console.write_line("Cell set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Cell set at (" + str(x) + ", " + str(y) + ")")
	
func _updatetilemap_cmd():
	_update_tilemap()
	Console.write_line("Tilemaps updated.")
	Logger.info("Tilemaps updated.")
