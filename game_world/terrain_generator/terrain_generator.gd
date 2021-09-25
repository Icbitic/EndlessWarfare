class_name TerrainGenerator
extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}

const CHUNK_SIZE = 16
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE

const LAND_THRESHOLD = -0.35

var map_size_default = Settings.map_size

# The map_size is in cells.
# The map_size is 256 by default.
var map_size = 256

var map_midpoint = Vector2(0.5, 0.5) * map_size

func _ready():
	pass

func generate(chunks):
	randomize()
	
	map_size = chunks.map_size
	map_midpoint = Vector2(0.5, 0.5) * map_size
	
	# Generate Terrain
	var noise = OpenSimplexNoise.new()
	
	noise.seed = randi()
	noise.octaves = 5
	noise.period = 64
	noise.persistence = 0.8
	for i in range(map_size):
		for j in range(map_size):
			if noise.get_noise_2d(i, j) - _get_falloff_value(i, j) > LAND_THRESHOLD:
				
				# Set the nearby cells to LAND to avoid bitmask problems.
				# The returned array from the range function will not include
				# the second argument, so it is "i(j) + 2" here.
				for m in range(i - 1, i + 2):
					for n in range(j - 1, j + 2):
						if (m >= 0 and m <= map_size - 1) and (n >= 0 and n <= map_size - 1):
							chunks.set_cell(m, n, TERRAIN, LAND)
			else:
				if not chunks.get_cell(i, j, TERRAIN) == LAND:
					chunks.set_cell(i, j, TERRAIN, WATER)
	
	# Post process the map
	# First to remove the cells of wrong bitmasks
	var template1 = [
		LAND, LAND, WATER,
		LAND, LAND, LAND,
		WATER, LAND, LAND
	]
	var template2 = [
		WATER, LAND, LAND,
		LAND, LAND, LAND,
		LAND, LAND, WATER
	]
	
	# Create a cache array of the map to access data more quickly.
	# Use an array because data in an array can be searched faster.
	# The cache can make the cost time of this kind of post process
	# reduce by 0.686s per 65535 cells on my laptop.
	var _map_cache = []
	_map_cache.resize(map_size)
	for i in range(map_size):
		var _column_cache = []
		_column_cache.resize(map_size)
		_map_cache[i] = _column_cache

	for i in range(map_size):
		for j in range(map_size):
			_map_cache[i][j] = chunks.get_cell(i, j, TERRAIN)

	# The edge of the map must be WATER, so we don't need to care about them
	for i in range(1, map_size - 1):
		for j in range(1, map_size - 1):
			var nearby = [
				_map_cache[i - 1][j - 1], _map_cache[i][j - 1], _map_cache[i + 1][j - 1],
				_map_cache[i - 1][j], _map_cache[i][j], _map_cache[i + 1][j],
				_map_cache[i - 1][j + 1], _map_cache[i][j + 1], _map_cache[i + 1][j + 1]
			]
			if (nearby.hash() == template1.hash() or 
					nearby.hash() == template2.hash()):
				for m in range(i - 1, i + 2):
					for n in range(j - 1, j + 2):
						chunks.set_cell(m, n, TERRAIN, LAND)
	return OK


func _get_falloff_value(x, y):
	var value = max(abs(x - map_midpoint.x) / (0.5 * map_size), abs(y - map_midpoint.y) / (0.5 * map_size))

	value = pow(value, 3) / (pow(value, 3) + pow(2.2 - 2.2 * value, 3))
	
	return value