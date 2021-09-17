class_name TerrainGenerator
extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}

const CHUNK_SIZE = 16
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE
# This MAP_SIZE refers to cells
const MAP_SIZE = 256
const MAP_MIDPOINT = Vector2(0.5, 0.5) * MAP_SIZE

const LAND_THRESHOLD = -0.35

onready var map

func _ready():
	pass

static func generate(chunk, random_seed):
	var data = {}
	
	# Generate Terrain
	var noise = OpenSimplexNoise.new()

	noise.seed = random_seed
	noise.octaves = 5
	noise.period = 64
	noise.persistence = 0.8
	
	for i in range(CHUNK_SIZE):
		for j in range(CHUNK_SIZE):
			if (noise.get_noise_2d(
						CHUNK_SIZE * chunk.chunk_position.x + i,
						CHUNK_SIZE * chunk.chunk_position.y + j)
						- _get_falloff_value(
						CHUNK_SIZE * chunk.chunk_position.x + i,
						CHUNK_SIZE * chunk.chunk_position.y + j)) > LAND_THRESHOLD:
				
				data[Vector3(i, j, TERRAIN)] = LAND
				
				# Set the nearby cells to LAND to avoid bitmask problems.
				# The returned array from the range function will not include
				# the second argument, so it is "i(j) + 2" here.
				for m in range(i - 1, i + 2):
					for n in range(j - 1, j + 2):
						if (m >= 0 and m <= 15) and (n >= 0 and n <= 15):
							data[Vector3(m, n, TERRAIN)] = LAND
			else:
				if not data.has(Vector3(i, j, TERRAIN)):
					data[Vector3(i, j, TERRAIN)] = WATER
	
	chunk.data = data
	
	return OK


static func _get_falloff_value(x, y):
	var value = max(abs(x - MAP_MIDPOINT.x) / (0.5 * MAP_SIZE), abs(y - MAP_MIDPOINT.y) / (0.5 * MAP_SIZE))
	
	var a = 3
	var b = 2.2
	value = pow(value, a) / (pow(value, a) + pow(b - b * value, a))
	
	return value
