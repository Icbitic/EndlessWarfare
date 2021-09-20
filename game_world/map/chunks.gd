class_name Chunks
extends Resource

const CHUNK_SIZE = 16

var map_size = 25
var data = {}

func _ready():
	pass

func set_cell(x, y, z, tile):
	data[Vector3(x, y, z)] = tile

func get_cell(x, y, z):
	if data.has(Vector3(x, y, z)):
		return get_cellf(x, y, z)
	return ERR_DOES_NOT_EXIST

# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cellf(x, y, z):
	return data[Vector3(x, y, z)]

func generate():
	var terrain_generator = TerrainGenerator.new()
	
	terrain_generator.generate(self)
