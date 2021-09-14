class_name TerrainGenerator
extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}
enum {LAND, WATER}
enum {DIRT_ROAD, STONE_ROAD}
enum {CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2}
enum {BLACK_WALL}

const CHUNK_SIZE = 16

const LAND_RATE = 0.5

func _ready():
	pass

static func generate(chunk_position):
	var data = {}
	
	# Generate Terrain
	var noise = OpenSimplexNoise.new()
	
	var threshold = 2 * LAND_RATE - 1
	
	for i in range(CHUNK_SIZE):
		for j in range(CHUNK_SIZE):
			if noise.get_noise_2d(CHUNK_SIZE * chunk_position.x + i, CHUNK_SIZE * chunk_position.y + j) > threshold:
				data[Vector3(i, j, TERRAIN)] = LAND
			else:
				data[Vector3(i, j, TERRAIN)] = WATER
	
	return data
