class_name Chunks
extends Resource

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
const CHUNK_SIZE = 16

var map_size = Settings.map_size
# Only store cells except TERRIAN.
var data = {}
# Seperate the terrian to use less memory.
var terrian = []

func save():
	var save_dict = {
		"data": data,
		"terrian": terrian,
		"map_size": map_size
	}
	return save_dict

func setup(size):
	Logger.info("Chunks of a " + str(size) + "x map was set up.")
	map_size = size
	# Initialize the terrian array
	# Since the terrian cells can fill the map, so use an array to store them.
	terrian.resize(map_size)
	for i in range(map_size):
		var terrian_column = []
		terrian_column.resize(map_size)
		terrian[i] = terrian_column
		
	
# Only returns cells except TERRIAN.
func get_all_cells():
	return data
	
func getterrian():
	return terrian
	
func set_cell(x, y, z, tile):
	if z == TERRAIN:
		terrian[x][y] = tile
		return OK
	else:
		data[Vector3(x, y, z)] = tile
		return OK
		
# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cell(x, y, z):
	if z == TERRAIN:
		return terrian[x][y]
	else:
		return data[Vector3(x, y, z)]

func has_cell(x, y, z):
	if z == TERRAIN:
		return true
	else:
		return data.has(Vector3(x, y, z))

func generate():
	var terrain_generator = TerrainGenerator.new()
	
	terrain_generator.generate(self)
