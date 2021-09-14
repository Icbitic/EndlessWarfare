class_name Chunk
extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}


const CHUNK_SIZE = 16
const WORLD_HEIGHT = 5
const TEXTURE_SHEET_WIDTH = 8

const CHUNK_LAST_INDEX = CHUNK_SIZE - 1
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH

var data = {} setget _set_data
var chunk_position = Vector2()

var map

func generate():
	self.data = TerrainGenerator.generate(chunk_position)
	
	
func _set_data(value):
	data = value
	_draw_chunk()
	
func _draw_chunk():
	for z in range(WORLD_HEIGHT):
		for i in range(CHUNK_SIZE):
			for j in range(CHUNK_SIZE):
				if data.has(Vector3(i, j, z)):
					map.set_cell(CHUNK_SIZE * chunk_position.x + i, CHUNK_SIZE * chunk_position.y + j, z, data[Vector3(i, j ,z)])
