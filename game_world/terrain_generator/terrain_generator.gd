class_name TerrainGenerator
extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}

const CHUNK_SIZE = 16
# This MAP_SIZE refers to cells
const MAP_SIZE = 256

const LAND_THRESHOLD = -0.35

func _ready():
	pass

static func generate(chunk_position, random_seed):
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
						CHUNK_SIZE * chunk_position.x + i,
						CHUNK_SIZE * chunk_position.y + j)
						- _get_falloff_value(
						CHUNK_SIZE * chunk_position.x + i,
						CHUNK_SIZE * chunk_position.y + j)) > LAND_THRESHOLD:
				
				data[Vector3(i, j, TERRAIN)] = LAND
			else:
				data[Vector3(i, j, TERRAIN)] = WATER
	
	return data


static func _get_falloff_value(x, y):
	var value = max(abs(x) / (0.5 * MAP_SIZE), abs(y) / (0.5 * MAP_SIZE))
	
	var a = 3
	var b = 2.2
	value = pow(value, a) / (pow(value, a) + pow(b - b * value, a))
	
	return value
