extends Node

signal game_saved
signal game_loaded

var packs

onready var test = preload("res://test/test.tscn")
onready var test2 = preload("res://test/test2.tscn")
onready var map = preload("res://game_world/map.tscn")
onready var camera = preload("res://game_world/camera.tscn")

var map_amount = 0

const ignore_keys = [
	"filename", "parent"
]

func _ready():
	#var file = File.new()
	
	#print(file.get_md5("res://"))
	Logger.get_module("main").set_output_level(Logger.DEBUG)
	Logger.output_format = "[{TIME}][{LVL}]{MSG}"
	# Load mods from the mods folder.
	
	_load_mods_to_project()
	var load_res = load_game()
	
	if typeof(load_res) == TYPE_INT:
		if load_res == ERR_DOES_NOT_EXIST or load_res == ERR_FILE_NOT_FOUND:
			_register_cells()
			var map_node = map.instance()
			map_node.map_id = map_amount
			map_amount += 1
			map_node.generate()
			$World.add_child(map_node)
			add_child(test.instance())
			$Test.add_child(test2.instance())
			add_child(camera.instance())
			
			_add_packs_to_scene_tree()
			
	_add_commands()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Logger.info("Received quit request.")
		if Settings.save_before_quit:
			save_game()
		get_tree().quit()

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
		
	for i in range(save_nodes.size() - 1, -1, -1):
		#print(save_nodes[i].get_path())
		save_nodes[i].queue_free()
		yield(save_nodes[i], "tree_exited")
	
	var res = _search_savens("user://test_saven")
	_load_file(res)
	
	_load_mapping_file()
	if OS.is_debug_build() and typeof(res) == TYPE_STRING:
		# Test the game functions to check if they are OK. 
		$Test.test()
	
	
	emit_signal("game_loaded")
	
	return res

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	var save_nodes = _get_node_in_group_in_order("Persist")
	
	var path = Settings.saven_path.plus_file("saven.ews")
	Logger.info("Saving game to " + path)
	var save_game = File.new()
	if save_game.open(path, File.WRITE) == ERR_FILE_NOT_FOUND:
		var dir = Directory.new()
		dir.open("user://")
		dir.make_dir(Settings.saven_path)
		
	save_game.open(path, File.WRITE)
	
	var save_dict = {}
	
	var order = 0
	for node in save_nodes:
		# Store the save dictionary as a new line in the save file.
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			Logger.warn("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			Logger.warn("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		save_dict[order] = node.call("save")
		order += 1
		
	save_game.store_line(to_json(save_dict))
	save_game.close()
	emit_signal("game_saved")
	Logger.info("Game was saved to " + path)
	
	_save_mapping()

func _get_node_in_group_in_order(group, nodes = [], node = self):
	for i in node.get_children():
		if i.is_in_group("Persist"):
			nodes.append(i)
	for i in node.get_children():
		nodes = _get_node_in_group_in_order(group, nodes, i)
	return nodes

func _save_mapping():
	var path = Settings.saven_path.plus_file("mapping.ews")
	var save_mapping = File.new()
	save_mapping.open(path, File.WRITE)
	save_mapping.store_line(to_json(CellController.save()))
	save_mapping.close()
	return OK

func _register_cells():
	CellController.add_cell("LAND", Settings.TERRAIN)
	CellController.add_cell("WATER", Settings.TERRAIN)
	CellController.add_cell("DIRT_ROAD", Settings.PATH)
	CellController.add_cell("STONE_ROAD", Settings.PATH)
	CellController.add_cell("CEMENT_ROAD", Settings.PATH)
	CellController.add_cell("MUD_ROAD", Settings.PATH)
	CellController.add_cell("CLEAN_FLOOR", Settings.FLOOR)
	CellController.add_cell("CRACKED_FLOOR", Settings.FLOOR)
	CellController.add_cell("CRACKED_FLOOR2", Settings.FLOOR)
	CellController.add_cell("WOODDEN_FENCE", Settings.FENCE)
	CellController.add_cell("BLACK_WALL", Settings.WALL)
	CellController.add_cell("TREE", Settings.PLANT)
	CellController.add_cell("DEAD_TREE", Settings.PLANT)
	CellController.add_cell("BUSH", Settings.PLANT)
	
func _add_commands():
	Console.add_command("loadmods", self, "_loadmods_cmd")\
	.set_description("Load .pck files in mods folder.")\
	.register()
	
	Console.add_command("loadoff", self, "_loadoff_cmd")\
	.set_description("Load off all .pck files.")\
	.register()
	
	Console.add_command("listmods", self, "_listmods_cmd")\
	.set_description("Load off all .pck files.")\
	.register()
	
	Console.add_command("savegame", self, "_savegame_cmd")\
	.set_description("Save game data to disk.")\
	.register()
	
	Console.add_command("loadgame", self, "_loadgame_cmd")\
	.set_description("Load game data from disk.")\
	.register()
	
	Console.add_command("listpersist", self, "_listpersist_cmd")\
	.set_description("List all persist mods.")\
	.register()
	
	Console.add_command("osinfo", self, "_osinfo_cmd")\
	.set_description("List OS info.")\
	.register()
	
	Console.add_command("orphan", self, "_orphan_cmd")\
	.set_description("List orphan nodes.")\
	.register()
	

func _load_mods_to_project():
	Logger.info("Starting loading mods.")
	if $PacksManager.import_packs("mods") == OK:
		Logger.info(str($PacksManager.get_packs().size()) + " mod(s) are loaded successfully.")
	# Return the amount of mods.
	return $PacksManager.get_packs().size()

func _clear_loaded_packs():
	return $PacksManager.clear_loaded_packs()
	
func _add_packs_to_scene_tree():
	packs = $PacksManager.get_packs()
	
	for i in packs.keys():
		if Settings.check_compatibility(packs[i].version_support) == false:
			Logger.warn("Warning! " + packs[i].name + " is not compatible with this version")
		elif packs[i].is_enabled:
			var scene = load("res://" + packs[i].name.plus_file(packs[i].name + ".tscn"))
			packs[i].scene = scene
			var node = scene.instance()
			self.add_child(node)
			Logger.info("Mod actived: " + packs[i].name + ".")
	
func _search_savens(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.match("saven.ews"):
					return dir.get_current_dir().plus_file(file_name)
			file_name = dir.get_next()
	else:
		Logger.info(path + " is missing")
		return ERR_DOES_NOT_EXIST
	dir.list_dir_end()
	return ERR_FILE_NOT_FOUND

func _load_node(node, node_data):
	# Now we set the r.keys():
	for i in node_data.keys():
		if ignore_keys.has(i):
			continue
			
		if typeof(node_data[i]) == TYPE_STRING:
			if node_data[i].match("(*,*,*)"):
				var pos = node_data[i].substr(1, node_data[i].length() - 2).split(",")
				node.set(i, Vector3(pos[0].to_float(), pos[1].to_float(), pos[2].to_float()))
				continue
			if node_data[i].match("(*,*)"):
				var pos = node_data[i].substr(1, node_data[i].length() - 2).split(",")
				node.set(i, Vector2(pos[0].to_float(), pos[1].to_float()))
				continue
		node.set(i, node_data[i])

func _load_file(path):
	# Path is ERR_*.
	if typeof(path) == TYPE_INT:
		return path
		
	Logger.info("Loading game data from " + path)
	var save_game = File.new()
	if not save_game.file_exists(path):
		return ERR_DOES_NOT_EXIST# Error! We don't have a save to load.

	
	var res = save_game.open(path, File.READ)
	
	var node_data: Dictionary = parse_json(save_game.get_line())

	for node in node_data.keys():
		
		var new_object: Node = load(node_data[node]["filename"]).instance()
		_load_node(new_object, node_data[node])
		get_node(node_data[node]["parent"]).add_child(new_object)
			
	save_game.close()
	Logger.info("Game data was loaded from " + path)
	return res

func _load_mapping_file():
	var path = Settings.saven_path.plus_file("mapping.ews")
	Logger.info("Loading mapping data from " + path)
	var save_mapping = File.new()
	var res = save_mapping.open(path, File.READ)
	if res == OK:
		var mappings: Dictionary = parse_json(save_mapping.get_line())
		
		for i in mappings.keys():
			CellController.set(i, mappings[i])
		
		save_mapping.close()
		Logger.info("Game mapping data was loaded from " + path)
	else:
		Logger.info("Can't open" + path)
	return res

func _get_all_children(node = self, children: Array = []):
	for i in node.get_children():
		_get_all_children(i, children)
	if not node == self:
		children.append(node)
	return children

func _loadmods_cmd():
	Console.write_line(str(_load_mods_to_project()) + " mod(s) are loaded successfully.")

func _loadoff_cmd():
	Console.write_line(str(_clear_loaded_packs()) + " mod(s) are loaded off.")

func _listmods_cmd():
	Console.write_line($PacksManager.list_mods())

func _listpersist_cmd():
	var nodes = get_tree().get_nodes_in_group("Persist")
	for i in nodes:
		Console.write_line(i.get_path())
		
func _savegame_cmd():
	Console.write_line("Starting saving game.")
	save_game()
	Console.write_line("Finished saving game.")

func _loadgame_cmd():
	Console.write_line("Starting loading game.")
	load_game()
	Console.write_line("Finished loading game.")

func _osinfo_cmd():
	Console.write_line("Vertical synchronization (Vsync): " + str(OS.vsync_enabled))
	
	Console.write_line("Audio drivers:")
	for i in range(OS.get_audio_driver_count()):
		Console.write_line(str(i) + ": " + OS.get_audio_driver_name(i))
	
	Console.write_line("Current executable engine path: " + OS.get_executable_path())
	
	Console.write_line("Model name: " + OS.get_model_name())
	
	Console.write_line("OS name: " + OS.get_name())
	
	Console.write_line("Power percent left: " + str(OS.get_power_percent_left()))
	Console.write_line("Power seconds left: " + str(OS.get_power_seconds_left()))
	
	Console.write_line("Process id: " + str(OS.get_process_id()))
	
	Console.write_line("Process count: " + str(OS.get_processor_count()))
	
	Console.write_line("Window size: " + str(OS.get_real_window_size()))
	
	Console.write_line("Screen dpi: " + str(OS.get_screen_dpi()))
	
	Console.write_line("Static memory peak usage: " + String.humanize_size(OS.get_static_memory_peak_usage()))
	Console.write_line("Static memory usage: " + String.humanize_size(OS.get_static_memory_usage()))
	Console.write_line("Thread id: " + str(OS.get_thread_caller_id()))
	
	if OS.is_debug_build() == true:
		Console.write_line("Debug build: true")
	else:
		Console.write_line("Debug build: false")
		
func _orphan_cmd():
	print_stray_nodes()
	Console.write_line("Orphan nodes are printed in logger.")
