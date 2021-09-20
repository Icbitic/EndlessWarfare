class_name Chunks
extends Resource

const CHUNK_SIZE = 16

var map_size = 25
var data = {}

func _ready():
	pass

func set_cell(x, y, z, tile):
	var chunk_position = Vector2(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
	data[chunk_position].set_cell(x - CHUNK_SIZE * chunk_position.x,
			y - CHUNK_SIZE * chunk_position.y, z, tile)

func get_cell(x, y, z):
	var chunk_position = Vector2(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
	if data[chunk_position].data.has(Vector3(
			x - CHUNK_SIZE * chunk_position.x,
			y - CHUNK_SIZE * chunk_position.y, z)):
				return get_cellf(x, y, z)
	return ERR_DOES_NOT_EXIST

# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cellf(x, y, z):
	var chunk_position = Vector2(floor(x / CHUNK_SIZE), floor(y / CHUNK_SIZE))
	return data[chunk_position].data[Vector3(
			x - CHUNK_SIZE * chunk_position.x,
			y - CHUNK_SIZE * chunk_position.y, z)]

func generate():
	var terrain_generator = TerrainGenerator.new()
	
	terrain_generator.generate(self)
