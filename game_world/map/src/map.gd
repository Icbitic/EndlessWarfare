extends Node2D

signal cell_set(pos, tile)
signal tilemap_updated
signal map_generated

enum {PEN_UP, PEN_DRAW, PEN_REMOVE}

const CHUNK_SIZE = 16
const CHUNK_MIDPOINT = Vector2(0.5, 0.5) * CHUNK_SIZE
const CHUNK_END_SIZE = CHUNK_SIZE - 1
const WORLD_HEIGHT = 5
const TEXTURE_SHEET_WIDTH = 8

var map_id setget _set_map_id
var saven_id

var map_size

var thread

var chunks

var is_first_generated = false

var pen_state = PEN_UP
var pen_tile = -1


onready var tree = preload("res://game_world/objects/plants/scene/tree.tscn")
onready var dead_tree = preload("res://game_world/objects/plants/scene/dead_tree.tscn")
onready var bush = preload("res://game_world/objects/plants/scene/bush.tscn")

func _exit_tree():
	if thread != null:
		thread.wat_to_finish()
	_remove_commands()
	return OK

func _ready():
	add_to_group("Persist")
	$Wall.GlobalNavigation = $Navigation
	$Terrain.GlobalNavigation = $Navigation
	
	Logger.info("Game world objects are linked to the Map node.")
	
	_add_commands()
	
	# Nodes of plants will add themselves to scene tree automatically.
	# But they won't be added to the scene tree for the first time.
	# So when it is the first time, and the is_first_generated is true.
	# Add trees to the scene tree.
	_update_tilemap(is_first_generated)
	return OK

func _unhandled_input(event):
	if event.is_action_pressed("construct"):
		var pos = $Terrain.world_to_map(get_global_mouse_position())
		match pen_state:
			PEN_UP:
				pass
			PEN_DRAW:
				set_cell(pos.x, pos.y, pen_tile)
			PEN_REMOVE:
				set_cell(pos.x, pos.y, -1)
			_:
				Logger.error("Unknow pen state: " + str(pen_state))
		get_tree().set_input_as_handled()
	return OK

# Public Methods
func generate():
	is_first_generated = true
	map_size = Settings.map_size
	
	# Todo: use thread to generate chunks.
	#thread = Thread.new()
	#thread.start(self, "generate")
	var chunks_path = preload("res://game_world/scene/chunks.tscn")
	add_child(chunks_path.instance())
	
	chunks = $Chunks
	
	chunks.setup_map(map_size)
	var err = _generate(map_size)
	return err
		
func save():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"map_size": map_size
	}
	return save_dict

# Delete all cells in z axis.
func set_cell(x, y, tile, update_plants = true, update_bitmask = true):
	var z = CellController.get_layer_by_id(tile)
	var result
	
	if z == -1:
		_remove_cell_fixed_objects_in_z(x, y)
		result = chunks.clear_fixed_object(x, y)
		
	else:
		if z == Settings.WALL:
			_remove_fixed_objects(Vector2(x, y), Vector2(x, y))
			
		if z == Settings.TERRAIN and tile == Settings.WATER:
			_remove_fixed_objects(Vector2(x - 1, y - 1), Vector2(x + 1, y + 1))
			
		# Set on WATER.
		if (not z == Settings.TERRAIN) and (not chunks.get_cell(x, y, Settings.TERRAIN) == Settings.LAND):
			return ERR_CANT_CREATE
			
		result = chunks.set_cell(x, y, z, tile)
	
	_update_navigation_cell(x, y)
	
	_draw_cell(x, y, z, update_plants, update_bitmask)
	emit_signal("cell_set", Vector3(x, y, z), tile)
	return result

func set_cellv(pos: Vector2, tile, update_plants = true, update_bitmask = true):
	var err = set_cell(pos.x, pos.y, tile, update_plants, update_bitmask)
	return err
	
# This method does not check if the key exists in chunks
# If the key does not exist in chunks, the program will CRASH!!!
func get_cell(x, y, z):
	return chunks.get_cell(x, y, z)

func get_cellv(pos: Vector3):
	return chunks.get_cell(pos.x, pos.y, pos.z)

####               ####
#                     #
#   PRIVATE METHODS   #
#                     #
####               ####

func _generate(size):
	Logger.info("Starting generating the map.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	chunks.generate()
	
	emit_signal("map_generated")
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.info("Finished generating a(n) "+ str(size) + "x map in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.info("The memory usage of the "+ str(size) + "x map's data is " + 
			String.humanize_size(final_memory_usage - initial_memory_usage))
	return OK
	
func _set_chunks_data(value: Dictionary):
	chunks = null
	chunks = Chunks.new()
	chunks.setup(value.map_size)
	for i in value.keys():
		if i == "map_size":
			continue
		chunks.set(i, value[i])

# Generate the identifier in the saven.
func _set_map_id(value):
	map_id = value
	saven_id = "Map#" + str(map_id)

func _update_tilemap(update_plants):
	Logger.info("Starting drawing the data from chunks to the Tilemaps.")
	var initial_time = OS.get_ticks_msec()
	var initial_memory_usage = OS.get_static_memory_peak_usage()
	
	_draw_chunks(update_plants, false)
	Logger.info("The data from Chunks were drawn into Tilemaps.")
	
	_update_navigation_mesh()
	
	$Terrain.update_bitmask_region()
	$Fence.update_bitmask_region()
	$Path.update_bitmask_region()
	$Wall.update_bitmask_region()
	$Floor.update_bitmask_region()

	Logger.info("Tilemaps' bitmask is updated.")
	
	emit_signal("tilemap_updated")
	
	var final_time = OS.get_ticks_msec()
	var final_memory_usage = OS.get_static_memory_peak_usage()
	Logger.info("Finished drawing the data from chunks to the Tilemaps in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	Logger.info("The memory usage when drawing the "+ str(map_size) + "x map to Tilemaps is "
			+ String.humanize_size(final_memory_usage - initial_memory_usage))
	
func _draw_cell(x, y, z, update_plants, update_bitmask = true):
	match z:
		Settings.TERRAIN:
			$Terrain.set_cell(x, y, get_cell(x, y, Settings.TERRAIN))
			if update_bitmask:
				$Terrain.update_bitmask_area(Vector2(x, y))
			return OK
		Settings.PATH:
			$Path.set_cell(x, y, get_cell(x, y, Settings.PATH))
			if update_bitmask:
				$Path.update_bitmask_area(Vector2(x, y))
			return OK
		Settings.FLOOR:
			$Floor.set_cell(x, y, get_cell(x, y, Settings.FLOOR))
			if update_bitmask:
				$Floor.update_bitmask_area(Vector2(x, y))
			return OK
		Settings.FENCE:
			$Fence.set_cell(x, y, get_cell(x, y, Settings.FENCE))
			if update_bitmask:
				$Fence.update_bitmask_area(Vector2(x, y))
			return OK
		Settings.WALL:
			$Wall.set_cell(x, y, get_cell(x, y, Settings.WALL))
			if update_bitmask:
				$Wall.update_bitmask_area(Vector2(x, y))
			return OK
		Settings.PLANT:
			if update_plants == true and not $Trees.has_node("#" + str(Vector2(x, y))):
				match get_cell(x, y, Settings.PLANT):
					Settings.TREE:
						_add_plant(Settings.TREE, x, y)
					Settings.DEAD_TREE:
						_add_plant(Settings.DEAD_TREE, x, y)
					Settings.BUSH:
						_add_plant(Settings.BUSH, x, y)
					_:
						_remove_plant(x, y)
			return OK
		_:
			return ERR_DOES_NOT_EXIST
			
func _draw_cell_in_z_axis(x, y, update_plants, update_bitmask = true):
	if chunks.has_cell(x, y, Settings.TERRAIN):
		$Terrain.set_cell(x, y, get_cell(x, y, Settings.TERRAIN))
		if update_bitmask:
			$Terrain.update_bitmask_area(Vector2(x, y))
			
	if chunks.has_cell(x, y, Settings.PATH):
		$Path.set_cell(x, y, get_cell(x, y, Settings.PATH))
		if update_bitmask:
			$Path.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, Settings.FLOOR):
		$Floor.set_cell(x, y, get_cell(x, y, Settings.FLOOR))
		if update_bitmask:
			$Floor.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, Settings.FENCE):
		$Fence.set_cell(x, y, get_cell(x, y, Settings.FENCE))
		if update_bitmask:
			$Fence.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, Settings.WALL):
		$Wall.set_cell(x, y, get_cell(x, y, Settings.WALL))
		if update_bitmask:
			$Wall.update_bitmask_area(Vector2(x, y))
	
	if chunks.has_cell(x, y, Settings.PLANT) and update_plants == true:
		match get_cell(x, y, Settings.PLANT):
			Settings.TREE:
				_add_plant(Settings.TREE, x, y)
			Settings.DEAD_TREE:
				_add_plant(Settings.DEAD_TREE, x, y)
			Settings.BUSH:
				_add_plant(Settings.BUSH, x, y)
			_:
				_remove_plant(x, y)
	return OK
	
func _remove_cell_fixed_objects_in_z(x, y, update_bitmask = true):
	if chunks.has_cell(x, y, Settings.PATH):
		$Path.set_cell(x, y, -1)
		if update_bitmask:
			$Path.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, Settings.FLOOR):
		$Floor.set_cell(x, y, -1)
		if update_bitmask:
			$Floor.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, Settings.FENCE):
		$Fence.set_cell(x, y, -1)
		if update_bitmask:
			$Fence.update_bitmask_area(Vector2(x, y))
		
	if chunks.has_cell(x, y, Settings.WALL):
		$Wall.set_cell(x, y, -1)
		if update_bitmask:
			$Wall.update_bitmask_area(Vector2(x, y))
	
	if chunks.has_cell(x, y, Settings.PLANT):
		_remove_plant(x, y)
	return OK
	
func _add_plant(plant_type, pos_x, pos_y):
	var tree_node
	
	if not $Trees.has_node(str(Vector2(pos_x, pos_y))):
		match plant_type:
			Settings.TREE:
				tree_node = tree.instance()
			Settings.DEAD_TREE:
				tree_node = dead_tree.instance()
			Settings.BUSH:
				tree_node = bush.instance()
				
		# Use "#" to avoid being translated by load_node function.
		tree_node.name = "#" + str(Vector2(pos_x, pos_y))
		tree_node.position = Vector2(pos_x * TEXTURE_SHEET_WIDTH, pos_y * TEXTURE_SHEET_WIDTH)
		$Trees.add_child(tree_node)
		return OK
	else:
		return ERR_ALREADY_EXISTS
	
func _remove_plant(pos_x, pos_y):
	if $Trees.has_node("#" + str(Vector2(pos_x, pos_y))):
		$Trees.get_node("#" + str(Vector2(pos_x, pos_y))).queue_free()
		return OK
	else:
		return ERR_DOES_NOT_EXIST
	
func _remove_fixed_objects(from: Vector2, to: Vector2):
	for i in range(from.x, to.x + 1):
		for j in range(from.y, to.y + 1):
			chunks.clear_fixed_object(i, j)
			_draw_cell_in_z_axis(i, j, true)
	return OK
	
func _draw_chunks(update_plants, update_bitmask = false):
	for position in chunks.get_all_objects().keys():
		_draw_cell(position.x, position.y, int(position.z), update_plants, update_bitmask)
			
	for i in range(chunks.map_size):
		for j in range(chunks.map_size):
			_draw_cell(i, j, Settings.TERRAIN, update_plants, update_bitmask)
	return OK

func _update_navigation_mesh():
	for i in range(map_size):
		for j in range(map_size):
			if (chunks.get_cell(i, j, Settings.TERRAIN) == Settings.LAND
					 and (not chunks.has_cell(i, j, Settings.WALL))):
				$Navigation.add_cell(i, j)
			else:
				$Navigation.remove_cell(i, j)
	return OK

func _update_navigation_cell(pos_x, pos_y):
	if (chunks.get_cell(pos_x, pos_y, Settings.TERRAIN) == Settings.LAND
			and (not chunks.has_cell(pos_x, pos_y, Settings.WALL))):
		$Navigation.add_cell(pos_x, pos_y)
	else:
		$Navigation.remove_cell(pos_x, pos_y)
	return OK

func _add_commands():
	Console.add_command("sett", self, "_setterrain_cmd")\
	.set_description("Set terrain.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setpa", self, "_setpath_cmd")\
	.set_description("Set path.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setfl", self, "_setfloor_cmd")\
	.set_description("Set floor.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setfe", self, "_setfence_cmd")\
	.set_description("Set fence.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setw", self, "_setwall_cmd")\
	.set_description("Set wall.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setpl", self, "_setplant_cmd")\
	.set_description("Set plant.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("setc", self, "_setcell_cmd")\
	.set_description("Set cell.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.add_argument("pos_z", TYPE_INT)\
	.add_argument("tile", TYPE_INT)\
	.register()
	
	Console.add_command("updatemap", self, "_updatetilemap_cmd")\
	.set_description("Update the tilemap.")\
	.register()
	
	Console.add_command("penu", self, "_penup_cmd")\
	.set_description("Pen up.")\
	.register()
	
	Console.add_command("pend", self, "_pendraw_cmd")\
	.set_description("Pen draw.")\
	.register()
	
	Console.add_command("penr", self, "_penremove_cmd")\
	.set_description("Pen remove.")\
	.register()
	
	Console.add_command("pent", self, "_pentile_cmd")\
	.add_argument("tile", TYPE_INT)\
	.set_description("Set pen tile, while switching into PEN_DRAW.")\
	.register()
	
	return OK
	
func _remove_commands():
	Console.remove_command("sett")
	Console.remove_command("setpa")
	Console.remove_command("setfl")
	Console.remove_command("setfe")
	Console.remove_command("setw")
	Console.remove_command("setpl")
	Console.remove_command("setc")
	Console.remove_command("updatemap")
	Console.remove_command("penu")
	Console.remove_command("pend")
	Console.remove_command("penr")
	Console.remove_command("pent")
	return OK
	
func _setterrain_cmd(x, y, tile):
	set_cell(x, y, Settings.TERRAIN, tile)
	Console.write_line("Terrain set at (" + str(x) + " " + str(y) + ")")
	Logger.info("Terrain set at (" + str(x) + " " + str(y) + ")")
	return OK

func _setpath_cmd(x, y, tile):
	set_cell(x, y, Settings.PATH, tile)
	Console.write_line("Path set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Path set at (" + str(x) + ", " + str(y) + ")")
	return OK
	
func _setfloor_cmd(x, y, tile):
	set_cell(x, y, Settings.FLOOR, tile)
	Console.write_line("Floor set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Floor set at (" + str(x) + ", " + str(y) + ")")
	return OK
	
func _setfence_cmd(x, y, tile):
	set_cell(x, y, Settings.FENCE, tile)
	Console.write_line("Fence set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Fence set at (" + str(x) + ", " + str(y) + ")")
	return OK
	
func _setwall_cmd(x, y, tile):
	set_cell(x, y, Settings.WALL, tile)
	Console.write_line("Wall set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Wall set at (" + str(x) + ", " + str(y) + ")")
	return OK
	
func _setplant_cmd(x, y, tile):
	set_cell(x, y, Settings.PLANT, tile)
	Console.write_line("Plant set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Plant set at (" + str(x) + ", " + str(y) + ")")
	return OK
	
func _setcell_cmd(x, y, z, tile):
	set_cell(x, y, z, tile)
	Console.write_line("Cell set at (" + str(x) + ", " + str(y) + ")")
	Logger.info("Cell set at (" + str(x) + ", " + str(y) + ")")
	return OK
	
func _updatetilemap_cmd():
	_update_tilemap(true)
	Console.write_line("Tilemaps updated.")
	Logger.info("Tilemaps updated.")
	return OK

func _penup_cmd():
	pen_state = PEN_UP
	Console.write_line("Pen up")
	return OK
	
func _pendraw_cmd():
	pen_state = PEN_DRAW
	Console.write_line("Pen down")
	return OK
	
func _penremove_cmd():
	pen_state = PEN_REMOVE
	Console.write_line("Pen remove")
	return OK
	
func _pentile_cmd(tile):
	pen_tile = tile
	pen_state = PEN_DRAW
	Console.write_line("Pen tile set to " + CellController.get_name_by_id(tile) +
			": " + str(tile))
	return OK
