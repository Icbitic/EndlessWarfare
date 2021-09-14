extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}

const CHUNK_SIZE = 16
# This MAP_SIZE refers to cells
const MAP_SIZE = 64
const CHUNK_MIDPOINT = Vector3(0.5, 0.5, 0.5) * CHUNK_SIZE
const CHUNK_END_SIZE = CHUNK_SIZE - 1

var player

var _chunks = {}

onready var world = get_parent()

func _ready():
	player = world.get_node("Players/" + str(world.player_id))
	
	# Todo: check if there is a existing saven
	_generate()

func set_cell(x, y, z, tile):
	match z:
		TERRAIN:
			$Terrain.set_cell(x, y, tile)
			$Terrain.update_bitmask_region()
			return OK
		PATH:
			$Path.set_cell(x, y, tile)
			return OK
		FLOOR:
			$Floor.set_cell(x, y, tile)
			return OK
		FENCE:
			$Fence.set_cell(x, y, tile)
			return OK
		WALL:
			$Wall.set_cell(x, y, tile)
			return OK
		_:
			return ERR_DOES_NOT_EXIST
			

func _generate():
	for i in range(-MAP_SIZE / (2 * CHUNK_SIZE), MAP_SIZE / (2 * CHUNK_SIZE)):
		for j in range(-MAP_SIZE / (2 * CHUNK_SIZE), MAP_SIZE / (2 * CHUNK_SIZE)):
			var _chunk = Chunk.new()
			var _chunk_position = Vector2(i, j)
			_chunk.chunk_position = _chunk_position
			_chunks[_chunk_position] = _chunk
			_chunk.map = self
			_chunk.generate()
			$Chunks.add_child(_chunk)
