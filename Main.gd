extends Node2D

var packs
var world = preload("res://game_world/world.tscn")

const ignore_data = [
	"filename", "parent",
	"pos_x", "pos_y",
	"is_generated"
	]

func _ready():
	Logger.output_format = "[{TIME}][{LVL}]{MSG}"
	# Load mods from the mods folder.
	
	load_mods()
	
	Console.add_command("loadmods", self, "load_mods_cmd")\
	.set_description("Load .pck files in mods folder.")\
	.register()
	
	Console.add_command("loadoff", self, "load_off_cmd")\
	.set_description("Load off all .pck files.")\
	.register()
	
	Console.add_command("listmods", self, "list_mods_cmd")\
	.set_description("Load off all .pck files.")\
	.register()
	
	Console.add_command("savegame", self, "save_game_cmd")\
	.set_description("Save game data to disk.")\
	.register()
	
	Console.add_command("loadgame", self, "load_game_cmd")\
	.set_description("Load game data from disk.")\
	.register()
	
	var load_res = load_game()
	
	if typeof(load_res) != TYPE_ARRAY:
		if load_res == ERR_DOES_NOT_EXIST:
			world = world.instance()
			add_child(world)
			world.setup()
	
	# Test the game functions to check if they are OK. 
	$Test.test()
	
func load_file(path):
	# Path is ERR_*.
	if typeof(path) == TYPE_INT:
		return path
		
	Logger.info("Loading game data from " + path)
	var save_game = File.new()
	if not save_game.file_exists(path):
		return ERR_DOES_NOT_EXIST# Error! We don't have a save to load.

	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var res = save_game.open(path, File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data: Dictionary = parse_json(save_game.get_line())

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object: Node = load(node_data.ori["filename"]).instance()
		get_node(node_data.ori["parent"]).add_child(new_object)
		
		for i in node_data.keys():
			if i == "ori":
				if node_data[i].has("pos_x") and node_data[i].has("pos_y"):
					new_object.position = Vector2(node_data[i]["pos_x"], node_data[i]["pos_y"])
					
				if node_data[i].has("is_generated"):
					new_object.is_generated = node_data[i].is_generated
					
				# Now we set the remaining variables.
				for j in node_data[i].keys():
					if ignore_data.has(i):
						continue
					new_object.set(j, node_data[i][j])
					
				if new_object.has_method("setup"):
					
					new_object.call("setup")
					
				continue
				
			if node_data[i].has("pos_x") and node_data[i].has("pos_y"):
				get_node(i).position = Vector2(node_data[i]["pos_x"], node_data[i]["pos_y"])
				
			if node_data[i].has("is_generated"):
				get_node(i).is_generated = node_data[i].is_generated
				
			# Now we set the remaining variables.
			for j in node_data[i].keys():
				if ignore_data.has(i):
					continue
				get_node(i).set(j, node_data[i][j])
			
			if get_node(i).has_method("setup"):
				get_node(i).call("setup")
		

	save_game.close()
	Logger.info("Game data was loaded from " + path)

	
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
		
	for i in save_nodes:
		if i.has_method("exit_loading"):
			i.exit_loading()
		i.queue_free()
		yield(i, "tree_exited")
	
	var res = _search_savens("user://test_saven")
	
	for i in res:
		load_file(i)
		
	return res
	
func save_node(node):
	var path = Settings.saven_path.plus_file(node.name + ".ews")
	Logger.info("Saving game to " + path)
	var save_game = File.new()
	if save_game.open(path, File.WRITE) == ERR_FILE_NOT_FOUND:
		var dir = Directory.new()
		dir.open("user://")
		dir.make_dir(Settings.saven_path)
		
	save_game.open(path, File.WRITE)
	# Check the node is an instanced scene so it can be instanced again during load.
	if node.filename.empty():
		Logger.warn("persistent node '%s' is not an instanced scene, skipped" % node.name)

	# Check the node has a save function.
	if !node.has_method("save"):
		Logger.warn("persistent node '%s' is missing a save() function, skipped" % node.name)
	# Call the node's save function.
	var node_data = node.call("save")

	# Store the save dictionary as a new line in the save file.
	save_game.store_line(to_json(node_data))
	save_game.close()
	Logger.info("Game was saved to " + path)
	
# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		save_node(node)


func load_mods_cmd():
	Console.write_line(str(load_mods()) + " mod(s) are loaded successfully.")
	
func load_mods():
	Logger.info("Starting loading mods.")
	if $PacksManager.load_packs("mods") == OK:
		Logger.info(str($PacksManager.get_packs().size()) + " mod(s) are loaded successfully.")
		packs = $PacksManager.get_packs()
		
		for i in packs.keys():
			if Settings.check_compatibility(packs[i].version_support) == false:
				Logger.warn("Warning! " + packs[i].name + " is not compatible with this version")
			# Todo: put an enable option condition here
			elif packs[i].is_enabled:
				if not ProjectSettings.load_resource_pack(packs[i].path):
					Logger.error("Error occurred when trying to load " + packs[i].path, ERR_CANT_RESOLVE)
					break
				var scene = load("res://" + packs[i].name.plus_file(packs[i].name + ".tscn"))
				packs[i].scene = scene
				var node = scene.instance()
				self.add_child(node)
				Logger.info("Mod actived: " + packs[i].name + ".")
	
	# Return the amount of mods.
	return $PacksManager.get_packs().size()

func load_off_cmd():
	Console.write_line(str(load_off()) + " mod(s) are loaded off.")

func load_off():
	return $PacksManager.load_off()
	
func list_mods_cmd():
	Console.write_line($PacksManager.list_mods())

func save_game_cmd():
	Console.write_line("Starting saving game.")
	save_game()
	Console.write_line("Finished saving game.")

func load_game_cmd():
	Console.write_line("Starting loading game.")
	load_game()
	Console.write_line("Finished loading game.")

func _search_savens(path):
	var paths = []
	
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
				paths.append_array(_search_savens(path.plus_file(file_name)))
			else:
				if file_name.match("*.ews"):
					paths.append(dir.get_current_dir().plus_file(file_name))
			file_name = dir.get_next()
	else:
		return ERR_DOES_NOT_EXIST
		Logger.info(path + " is missing")
	dir.list_dir_end()
	return paths
