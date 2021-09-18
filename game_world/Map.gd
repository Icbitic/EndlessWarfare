extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}

const CHUNK_SIZE = 16
# This MAP_SIZE refers to cells
const MAP_SIZE = 256
const MAP_MIDPOINT = Vector2(0.5, 0.5) * MAP_SIZE
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE
const CHUNK_END_SIZE = CHUNK_SIZE - 1
const WORLD_HEIGHT = 5

var player
var thread

var chunks = {}

onready var world = get_parent()

func _ready():
	player = world.get_node("Players/" + str(world.player_id))
	
	$Wall.GlobalNavigation = $Navigation
	$Terrain.GlobalNavigation = $Navigation
	
	
	# Todo: check if there is a existing saven
	
	#thread = Thread.new()
	#thread.start(self, "_generate")
	
	_generate()
	
	for i in chunks.keys():
		draw_chunk(chunks[i].chunk_position, false)
	
	$Terrain.update_bitmask_region()
	
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
			

func draw_chunk(chunk_position, update = false):
	var _chunk = chunks[chunk_position]
	for z in range(WORLD_HEIGHT):
		for i in range(CHUNK_SIZE):
			for j in range(CHUNK_SIZE):
				draw_cell(i + chunk_position.x * CHUNK_SIZE,
						j + chunk_position.y * CHUNK_SIZE, z, update)
	return OK
	
func set_cell(x, y, z, tile, update_bitmask = true):
	var chunk_position = Vector2(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
	chunks[chunk_position].set_cell(x - CHUNK_SIZE * chunk_position.x,
			y - CHUNK_SIZE * chunk_position.y, z, tile)
	draw_cell(x, y, z, update_bitmask)

func get_cell(x, y, z):
	var chunk_position = Vector2(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
	if chunks[chunk_position].data.has(Vector3(
			x - CHUNK_SIZE * chunk_position.x,
			y - CHUNK_SIZE * chunk_position.y, z)):
		return chunks[chunk_position].data[Vector3(
				x - CHUNK_SIZE * chunk_position.x,
				y - CHUNK_SIZE * chunk_position.y, z)]
	return ERR_DOES_NOT_EXIST

func _generate():
	# The random_seed is required to keep sync of all the chunks' random seed
	randomize()
	var random_seed = randi()
	
	LogRecorder.record("Starting generating the world.")
	var initial_time = OS.get_ticks_msec()
	
	# If MAP_SIZE / CHUNK_SIZE cannot be a integer
	# Use the closest integer smaller than it instead
	# warning-ignore:integer_division
	for i in range(MAP_SIZE / CHUNK_SIZE):
		# warning-ignore:integer_division
		for j in range(MAP_SIZE / CHUNK_SIZE):
			var _chunk = Chunk.new()
			var _chunk_position = Vector2(i, j)
			_chunk.chunk_position = _chunk_position
			chunks[_chunk_position] = _chunk
			$Chunks.add_child(_chunk)
	
	var terrain_generator = TerrainGenerator.new()
	
	terrain_generator.map = chunks
	
	for i in chunks.keys():
		terrain_generator.generate(chunks[i], random_seed)
	
	# Post process the map
	# First to remove the cells of wrong bitmasks
	var template1 = {
		Vector2(-1, -1): LAND, Vector2(0, -1): LAND, Vector2(1, -1): WATER,
		Vector2(-1, 0): LAND, Vector2(0, 0): LAND, Vector2(1, 0): LAND,
		Vector2(-1, 1): WATER, Vector2(0, 1): LAND, Vector2(1, 1): LAND
	}
	var template2 = {
		Vector2(-1, -1): WATER, Vector2(0, -1): LAND, Vector2(1, -1): LAND,
		Vector2(-1, 0): LAND, Vector2(0, 0): LAND, Vector2(1, 0): LAND,
		Vector2(-1, 1): LAND, Vector2(0, 1): LAND, Vector2(1, 1): WATER
	}
	
	# Create a cache array of the map to access data more quickly.
	# Use an array because data in an array can be searched faster.
	# The cache can make the cost time of this kind of post process
	# reduce by 0.686s per 65535 cells on my laptop.
	var _map_cache = []
	_map_cache.resize(MAP_SIZE)
	var _column_cache = []
	_column_cache.resize(MAP_SIZE)
	for i in range(MAP_SIZE):
		_map_cache[i] = _column_cache

	for i in range(MAP_SIZE):
		for j in range(MAP_SIZE):
			_map_cache[i][j] = get_cell(i, j, TERRAIN)

	# The edge of the map must be WATER, so we don't need to care about them
	for i in range(1, MAP_SIZE - 1):
		for j in range(1, MAP_SIZE - 1):
			var nearby = {
				Vector2(-1, -1): _map_cache[i - 1][j - 1], Vector2(0, -1): _map_cache[i][j - 1], Vector2(1, -1): _map_cache[i + 1][j - 1],
				Vector2(-1, 0): _map_cache[i - 1][j], Vector2(0, 0): _map_cache[i][j], Vector2(1, 0): _map_cache[i + 1][j],
				Vector2(-1, 1): _map_cache[i - 1][j + 1], Vector2(0, 1): _map_cache[i][j + 1], Vector2(1, 1): _map_cache[i + 1][j + 1]
			}
			if (nearby.hash() == template1.hash() or 
					nearby.hash() == template2.hash()):
				for m in range(i - 1, i + 2):
					for n in range(j - 1, j + 2):
						set_cell(m, n, TERRAIN, LAND)
	var final_time = OS.get_ticks_msec()
	LogRecorder.record("Finished generating the world, with the time of " + str(((final_time as float) - (initial_time as float)) / 1000) + "s")
	return OK
