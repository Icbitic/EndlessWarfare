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

var chunks

onready var world = get_parent()

func _ready():
	player = world.get_node("Players/" + str(world.player_id))
	
	chunks = Chunks.new()
	
	$Wall.GlobalNavigation = $Navigation
	$Terrain.GlobalNavigation = $Navigation
	
	# Todo: check if there is a existing saven
	
	#thread = Thread.new()
	#thread.start(self, "generate")
	
	map_size = Settings.map_size
	
	generate(map_size)
	
	LogRecorder.record("Starting rendering the map.")
	var initial_time = OS.get_ticks_msec()
	
	draw_chunks(false)
	
	$Terrain.update_bitmask_region()
	
	var final_time = OS.get_ticks_msec()
	LogRecorder.record("Finished rendering the map in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	
	
func _exit_tree():
	if thread != null:
		thread.wait_to_finish()

func draw_cell(x, y, z, update_bitmask = true):
	match z:
		TERRAIN:
			$Terrain.set_cell(x, y, get_cell(x, y, z))
			if update_bitmask:
				$Terrain.update_bitmask_region()
			return OK
		PATH:
			$Path.set_cell(x, y, get_cell(x, y, z))
			return OK
		FLOOR:
			$Floor.set_cell(x, y, get_cell(x, y, z))
			return OK
		FENCE:
			$Fence.set_cell(x, y, get_cell(x, y, z))
			return OK
		WALL:
			$Wall.set_cell(x, y, get_cell(x, y, z))
			return OK
		_:
			return ERR_DOES_NOT_EXIST
			

func draw_chunks(update = false):
	for i in range(map_size):
		for j in range(map_size):
			draw_cell(i, j, TERRAIN, update)
	
	for chunk in chunks.data.keys():
		for position in chunks.data[chunk].data.keys():
			draw_cell(position.x + chunks.data[chunk].chunk_position.x * CHUNK_SIZE,
					position.y + chunks.data[chunk].chunk_position.y * CHUNK_SIZE,
					position.z)
	return OK
	
func set_cell(x, y, z, tile, update_bitmask = true):
	var result = chunks.set_cell(x, y, z, tile, update_bitmask)
	draw_cell(x, y, z, update_bitmask)
	return result

func get_cell(x, y, z):
	return chunks.get_cell(x, y, z)

# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cellf(x, y, z):
	return chunks.get_cellf(x, y, z)

func generate(size):
	LogRecorder.record("Starting generating the map.")
	var initial_time = OS.get_ticks_msec()
	
	chunks.map_size = size
	chunks.data = {}
	
	# If map_size / CHUNK_SIZE cannot be a integer
	# Use the closest integer smaller than it instead
	# warning-ignore:integer_division
	for i in range(size / CHUNK_SIZE):
		# warning-ignore:integer_division
		for j in range(size / CHUNK_SIZE):
			var _chunk = Chunk.new()
			var _chunk_position = Vector2(i, j)
			_chunk.chunk_position = _chunk_position
			chunks.data[_chunk_position] = _chunk
			$Chunks.add_child(_chunk)
	
	chunks.generate()
	
	var final_time = OS.get_ticks_msec()
	LogRecorder.record("Finished generating a "+ str(size) + "x map in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	return OK
