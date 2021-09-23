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

var player
var thread

var chunks: Chunks

onready var world = get_parent()

func _ready():
	$Wall.GlobalNavigation = $Navigation
	$Terrain.GlobalNavigation = $Navigation
	
	
	#thread = Thread.new()
	#thread.start(self, "generate")
	player = world.get_node("Players/" + str(world.player_id))
	
	Logger.record("Game world objects are linked to the Map node.")
	
	# Todo: check if there is a existing saven
	
	chunks = Chunks.new()
	map_size = Settings.map_size
	chunks.setup(map_size)
	
	generate(map_size)
	
	Logger.record("Starting drawing the data from chunks to the Tilemaps.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	draw_chunks(false)
	Logger.record("The data from Chunks were drawn into Tilemaps.")
	
	$Terrain.update_bitmask_region()
	Logger.record("Terrain's bitmask is updated.")
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.record("Finished drawing the data from chunks to the Tilemaps in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.record("The memory usage when drawing the "+ str(map_size) + "x map to Tilemaps is "
			+ str(((final_memory_usage as float) - (initial_memory_usage as float)) / 1048576)
			+ " MB.")
	
	
func _exit_tree():
	if thread != null:
		thread.wait_to_finish()

func draw_cell(x, y, z, update_bitmask = true):
	match z:
		TERRAIN:
			$Terrain.set_cell(x, y, get_cell(x, y, TERRAIN))
			if update_bitmask:
				$Terrain.update_bitmask_region()
			return OK
		PATH:
			$Path.set_cell(x, y, get_cell(x, y, PATH))
			return OK
		FLOOR:
			$Floor.set_cell(x, y, get_cell(x, y, FLOOR))
			return OK
		FENCE:
			$Fence.set_cell(x, y, get_cell(x, y, FENCE))
			return OK
		WALL:
			$Wall.set_cell(x, y, get_cell(x, y, WALL))
			return OK
		_:
			return ERR_DOES_NOT_EXIST
			

func draw_chunks(update_bitmask = false):
	for position in chunks.get_all_cells().keys():
		draw_cell(position.x, position.y, position.z, update_bitmask)
	for i in range(chunks.map_size):
		for j in range(chunks.map_size):
			draw_cell(i, j, TERRAIN, update_bitmask)
	return OK

func set_cell(x, y, z, tile, update_bitmask = true):
	var result = chunks.set_cell(x, y, z, tile)
	draw_cell(x, y, z, update_bitmask)
	return result

# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cell(x, y, z):
	return chunks.get_cell(x, y, z)

func generate(size):
	Logger.record("Starting generating the map.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	chunks.map_size = size
	
	chunks.generate()
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.record("Finished generating a(n) "+ str(size) + "x map in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.record("The memory usage of the "+ str(size) + "x map's data is " + 
			str(((final_memory_usage as float) - (initial_memory_usage as float)) / 1048576)
			+ " MB.")
	return OK
