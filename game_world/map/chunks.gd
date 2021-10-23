class_name Chunks
extends Resource

enum {TERRAIN, PATH, FLOOR, FENCE, WALL, PLANT}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}
enum {TREE, DEAD_TREE, BUSH}

const CHUNK_SIZE = 16

var map_size = Settings.map_size
# Only store cells except TERRIAN.
var objects = {} setget _set_objects
# Seperate the terrian to use less memory.
var terrian = []

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
		
func get_persist_data():
	for i in objects.keys():
		if objects[i] == -1:
			objects.erase(i)
	var save_dict = {
		"objects": objects,
		"terrian": terrian,
		"map_size": map_size
	}
	return save_dict

# Only returns cells except TERRIAN.
func get_all_objects():
	return objects
	
func getterrian():
	return terrian
	
func set_cell(x, y, z, tile):
	if z == TERRAIN:
		terrian[x][y] = tile
		return OK
	else:
		objects[Vector3(x, y, z)] = tile
		return OK
		
# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cell(x, y, z):
	if z == TERRAIN:
		return terrian[x][y]
	else:
		var res = objects[Vector3(x, y, z)]
		return int(res)

func has_cell(x, y, z):
	if z == TERRAIN:
		return true
	else:
		return objects.has(Vector3(x, y, z))
		
func has_fixed_objects(x, y):
	if objects.has(Vector3(x, y, PATH)):
		if not objects[Vector3(x, y, PATH)] == -1:
			return false
			
	if objects.has(Vector3(x, y, FLOOR)):
		if not objects[Vector3(x, y, FLOOR)] == -1:
			return false
			
	if objects.has(Vector3(x, y, FENCE)):
		if not objects[Vector3(x, y, FENCE)] == -1:
			return false
			
	if objects.has(Vector3(x, y, WALL)):
		if not objects[Vector3(x, y, WALL)] == -1:
			return false
			
	if objects.has(Vector3(x, y, PLANT)):
		if not objects[Vector3(x, y, PLANT)] == -1:
			return false
	return true
	
func clear_fixed_object(pos: Vector2):
	if objects.has(Vector3(pos.x, pos.y, PATH)):
		objects[Vector3(pos.x, pos.y, PATH)] = -1
		
	if objects.has(Vector3(pos.x, pos.y, FLOOR)):
		objects[Vector3(pos.x, pos.y, FLOOR)] = -1
		
	if objects.has(Vector3(pos.x, pos.y, FENCE)):
		objects[Vector3(pos.x, pos.y, FENCE)] = -1
		
	if objects.has(Vector3(pos.x, pos.y, WALL)):
		objects[Vector3(pos.x, pos.y, WALL)] = -1
		
	if objects.has(Vector3(pos.x, pos.y, PLANT)):
		objects[Vector3(pos.x, pos.y, PLANT)] = -1
	return OK
	
func generate():
	var terrain_generator = TerrainGenerator.new()
	
	terrain_generator.generate(self)

func _set_objects(value):
	for i in value.keys():
		var pos = i.substr(1, i.length() - 2).split(",")
		objects[Vector3(pos[0].to_int(), pos[1].to_int(), pos[2].to_int())] = value[i]
