class_name TerrainGenerator
extends Resource


const CHUNK_SIZE = 16
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE

const LAND_THRESHOLD = -0.35

const TREE_DENSITY = 0.05
const TREE_DEATH_RATE = 0.05

const BUSH_DENSITY = 0.02

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
							chunks.set_cell(m, n, Settings.TERRAIN, Settings.LAND)
			else:
				if not chunks.get_cell(i, j, Settings.TERRAIN) == Settings.LAND:
					chunks.set_cell(i, j, Settings.TERRAIN, Settings.WATER)
	
	# Plant trees
	# warning-ignore:unused_variable
	for i in range(map_size * map_size * TREE_DENSITY):
		var pos_x = int(rand_range(0, map_size))
		var pos_y = int(rand_range(0, map_size))
		var is_surrounded = true
		for x in range(pos_x - 2, pos_x + 3):
			for y in range(pos_y - 2, pos_y + 3):
				if x >= 0 and x < map_size and y >= 0 and y < map_size:
					if not chunks.get_cell(x, y, Settings.TERRAIN) == Settings.LAND:
						is_surrounded = false
		if is_surrounded and chunks.has_fixed_objects(pos_x, pos_y):
			if randf() < TREE_DEATH_RATE:
				chunks.set_cell(pos_x, pos_y, Settings.PLANT, Settings.DEAD_TREE)
			else:
				chunks.set_cell(pos_x, pos_y, Settings.PLANT, Settings.TREE)
	
#	# Add Bushes
#	# warning-ignore:unused_variable
#	for i in range(map_size * map_size * BUSH_DENSITY):
#		var pos_x = int(rand_range(0, map_size))
#		var pos_y = int(rand_range(0, map_size))
#		var is_surrounded = true
#		for x in range(pos_x - 2, pos_x + 3):
#			for y in range(pos_y - 2, pos_y + 3):
#				if x >= 0 and x < map_size and y >= 0 and y < map_size:
#					if not chunks.get_cell(x, y, Settings.TERRAIN) == Settings.LAND:
#						is_surrounded = false
#		if is_surrounded and chunks.has_fixed_objects(pos_x, pos_y):
#			chunks.set_cell(pos_x, pos_y, Settings.PLANT, Settings.BUSH)
	
	# Post process the map
	# First to remove the cells of wrong bitmasks
	var template1 = [
		Settings.LAND, Settings.WATER, Settings.LAND,
		Settings.LAND, Settings.LAND, Settings.LAND,
		Settings.LAND, Settings.WATER, Settings.LAND
	]
	var template2 = [
		Settings.LAND, Settings.LAND, Settings.LAND,
		Settings.WATER, Settings.LAND, Settings.WATER,
		Settings.LAND, Settings.LAND, Settings.LAND
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
			_map_cache[i][j] = chunks.get_cell(i, j, Settings.TERRAIN)

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
						chunks.set_cell(m, n, Settings.TERRAIN, Settings.LAND)
	return OK

####               ####
#                     #
#   PRIVATE METHODS   #
#                     #
####               ####

func _get_falloff_value(x, y):
	var value = max(abs(x - map_midpoint.x) / (0.5 * map_size), abs(y - map_midpoint.y) / (0.5 * map_size))

	value = pow(value, 3) / (pow(value, 3) + pow(2.2 - 2.2 * value, 3))
	
	return value
