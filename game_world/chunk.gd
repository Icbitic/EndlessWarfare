class_name Chunk
extends Node2D

enum {TERRAIN, PATH, FLOOR, FENCE, WALL}


const CHUNK_SIZE = 16
const WORLD_HEIGHT = 5
const TEXTURE_SHEET_WIDTH = 8

const CHUNK_LAST_INDEX = CHUNK_SIZE - 1

var data = {}
var chunk_position = Vector2()

func _ready():
	position = chunk_position * CHUNK_SIZE * TEXTURE_SHEET_WIDTH
	
	if Settings.draw_chunk_outline:
		var line = Line2D.new()
		line.name = "ChunkOutline"
		var points = [
			Vector2(0, 0),
			Vector2(CHUNK_SIZE * TEXTURE_SHEET_WIDTH, 0),
			Vector2(CHUNK_SIZE * TEXTURE_SHEET_WIDTH, CHUNK_SIZE * TEXTURE_SHEET_WIDTH),
			Vector2(0, CHUNK_SIZE * TEXTURE_SHEET_WIDTH)]
				
		line.points = PoolVector2Array(points)
		line.width = 1
		line.default_color = Color(0, 0, 0, 1)
		add_child(line)
		
	if Settings.draw_cell_outline:
		var line = Line2D.new()
		
		line.name = "cell_outline"
		
		var points = []
		
		for i in range(CHUNK_SIZE + 1):
			for j in range(CHUNK_SIZE + 1):
				var vectors = [
					Vector2(0, 0),
					Vector2(i * TEXTURE_SHEET_WIDTH, 0),
					Vector2(i * TEXTURE_SHEET_WIDTH, j * TEXTURE_SHEET_WIDTH),
					Vector2(0, j * TEXTURE_SHEET_WIDTH),
				]
				points.append_array(vectors)
		
		line.points = PoolVector2Array(points)
		line.width = 1
		add_child(line)

func generate(random_seed):
	data = TerrainGenerator.generate(chunk_position, random_seed)
	return OK

func set_cell(x, y, z, tile, update_bitmask = true):
	if data.has(Vector3(x, y, z)):
		data[Vector3(x, y, z)] = tile
		return OK
	else:
		return ERR_DOES_NOT_EXIST

