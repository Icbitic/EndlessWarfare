extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}

const CHUNK_SIZE = 16
# This MAP_SIZE refers to cells
const MAP_SIZE = 256
const MAP_MIDPOINT = Vector2(0.5, 0.5) * MAP_SIZE
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE
const CHUNK_END_SIZE = CHUNK_SIZE - 1
const WORLD_HEIGHT = 5

var player
var thread

var _chunks = {}

onready var world = get_parent()

func _ready():
	player = world.get_node("Players/" + str(world.player_id))
	
	$Wall.GlobalNavigation = $Navigation
	$Terrain.GlobalNavigation = $Navigation
	
	
	# Todo: check if there is a existing saven
	
	#thread = Thread.new()
	#thread.start(self, "_generate")
	
	_generate()
	
	for i in _chunks.keys():
		draw_chunk(_chunks[i].chunk_position, false)
	
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
	var _chunk = _chunks[chunk_position]
	for z in range(WORLD_HEIGHT):
		for i in range(CHUNK_SIZE):
			for j in range(CHUNK_SIZE):
				draw_cell(i + chunk_position.x * CHUNK_SIZE,
						j + chunk_position.y * CHUNK_SIZE, z, update)
	return OK
	
func set_cell(x, y, z, tile, update_bitmask = true):
	var chunk_position = Vector2(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
	_chunks[chunk_position].set_cell(Vector2(
			x - CHUNK_SIZE * chunk_position.x,
			y - CHUNK_SIZE * chunk_position.y),
			z, tile, update_bitmask)
	draw_cell(x + CHUNK_SIZE * chunk_position.x,y + CHUNK_SIZE * chunk_position.y,
			z, update_bitmask)

func get_cell(x, y, z):
	var chunk_position = Vector2(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
	if _chunks[chunk_position].data.has(Vector3(
			x - CHUNK_SIZE * chunk_position.x,
			y - CHUNK_SIZE * chunk_position.y, z)):
		return _chunks[chunk_position].data[Vector3(
				x - CHUNK_SIZE * chunk_position.x,
				y - CHUNK_SIZE * chunk_position.y, z)]
	return ERR_DOES_NOT_EXIST

func _generate():
	# The random_seed is required to keep sync of all the chunks' random seed
	#randomize()
	var random_seed = 1#randi()
	
	# If MAP_SIZE / CHUNK_SIZE cannot be a integer
	# Use the closest integer smaller than it instead
	# warning-ignore:integer_division
	for i in range(MAP_SIZE / CHUNK_SIZE):
		# warning-ignore:integer_division
		for j in range(MAP_SIZE / CHUNK_SIZE):
			var _chunk = Chunk.new()
			var _chunk_position = Vector2(i, j)
			_chunk.chunk_position = _chunk_position
			_chunks[_chunk_position] = _chunk
			_chunk.generate(random_seed)
			$Chunks.add_child(_chunk)
	return OK
