extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}

const CHUNK_SIZE = 16
# This MAP_SIZE refers to cells
const MAP_SIZE = 256
const CHUNK_MIDPOINT = Vector3(0.5, 0.5, 0.5) * CHUNK_SIZE
const CHUNK_END_SIZE = CHUNK_SIZE - 1

var player
var thread

var _chunks = {}

onready var world = get_parent()

func _ready():
	player = world.get_node("Players/" + str(world.player_id))
	
	# Todo: check if there is a existing saven
	
	#thread = Thread.new()
	#thread.start(self, "_generate")
	
	_generate(null)
	$Terrain.update_bitmask_region()
	
func _exit_tree():
	if thread != null:
		thread.wait_to_finish()

func set_cell(x, y, z, tile, update_bitmask = true):
	match z:
		TERRAIN:
			$Terrain.set_cell(x, y, tile)
			if update_bitmask:
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
			

func _generate(userdata):
	# The random_seed is required to keep sync of all the chunks' random seed
	var random_seed = randi()
	
	for i in range(-MAP_SIZE / (2 * CHUNK_SIZE), MAP_SIZE / (2 * CHUNK_SIZE)):
		for j in range(-MAP_SIZE / (2 * CHUNK_SIZE), MAP_SIZE / (2 * CHUNK_SIZE)):
			var _chunk = Chunk.new()
			var _chunk_position = Vector2(i, j)
			_chunk.chunk_position = _chunk_position
			_chunks[_chunk_position] = _chunk
			_chunk.map = self
			_chunk.generate(random_seed)
			$Chunks.add_child(_chunk)
	return OK

func _remove_isolated_cells():
	for i in range(-0.5 * MAP_SIZE, 0.5 * MAP_SIZE):
		for j in range(-0.5 * MAP_SIZE, 0.5 * MAP_SIZE):
			pass
