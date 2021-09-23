class_name Chunks
extends Resource

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
const CHUNK_SIZE = 16

var map_size = 256
# Only store cells except TERRIAN.
var _data = {}
# Seperate the terrian to use less memory.
var _terrian = []

func setup(size):
	Logger.record("Chunks of a " + str(size) + "x map was set up.")
	map_size = size
	# Initialize the terrian array
	# Since the terrian cells can fill the map, so use an array to store them.
	_terrian.resize(map_size)
	for i in range(map_size):
		var _terrian_column = []
		_terrian_column.resize(map_size)
		_terrian[i] = _terrian_column
	
# Only returns cells except TERRIAN.
func get_all_cells():
	return _data
	
func get_terrian():
	return _terrian
	
func set_cell(x, y, z, tile):
	if z == TERRAIN:
		_terrian[x][y] = tile
		return OK
	else:
		_data[Vector3(x, y, z)] = tile
		return OK
		
# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cell(x, y, z):
	if z == TERRAIN:
		return _terrian[x][y]
	else:
		return _data[Vector3(x, y, z)]

func has_cell(x, y, z):
	if z == TERRAIN:
		return true
	else:
		return _data.has(Vector3(x, y, z))

func generate():
	var terrain_generator = TerrainGenerator.new()
	
	terrain_generator.generate(self)
