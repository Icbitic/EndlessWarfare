extends PlaneMap

var GlobalNavigation

enum {LEFT, LEFTTOP, TOP}

var map_size = Settings.map_size
var shadow = []

func _ready():
	pass
	shadow.resize(map_size)
	for i in range(map_size):
		var shadow_column = []
		shadow_column.resize(map_size)
		shadow[i] = shadow_column
		# [0]: lefttop, [1]: top, [2]: left.
		for j in range(map_size):
			shadow[i][j] = []
			shadow[i][j].resize(3)
			for k in range(3):
				shadow[i][j][k] = false
	
	
func set_cell(x, y, tile, flip_x = false, flip_y = false, transpose = false, autotile_coord = Vector2()):
	if tile == -1:
		# Delete the cell.
		shadow[x + 1][y][2] = false
		shadow[x + 1][y + 1][0] = false
		shadow[x][y + 1][1] = false
		
		update_shadow(x + 1, y)
		update_shadow(x + 1, y + 1)
		update_shadow(x, y + 1)
		
		GlobalNavigation.add_cell(x, y)
	else:
		shadow[x + 1][y][2] = true
		shadow[x + 1][y + 1][0] = true
		shadow[x][y + 1][1] = true
		
		update_shadow(x + 1, y)
		update_shadow(x + 1, y + 1)
		update_shadow(x, y + 1)
		
		GlobalNavigation.remove_cell(x, y)
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)

func update_shadow(x, y):
	if get_cell(x, y) != -1:
		return
	match shadow[x][y]:
		[false, false, false]:
			$Shadow.set_cell(x, y, -1)
		[false, false, true]:
			$Shadow.set_cell(x, y, 0)
		[false, true, false]:
			$Shadow.set_cell(x, y, 2)
		[false, true, true]:
			$Shadow.set_cell(x, y, 7)
		[true, false, false]:
			$Shadow.set_cell(x, y, 1)
		[true, false, true]:
			if randi() % 2 == 1:
				$Shadow.set_cell(x, y, 5)
			else:
				$Shadow.set_cell(x, y, 6)
		[true, true, false]:
			if randi() % 2 == 1:
				$Shadow.set_cell(x, y, 3)
			else:
				$Shadow.set_cell(x, y, 4)
		[true, true, true]:
			$Shadow.set_cell(x, y, 7)
