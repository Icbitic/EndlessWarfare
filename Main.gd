extends Node2D

var packs
var world = preload("res://game_world/world.tscn")

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
	
	if load_game() == ERR_DOES_NOT_EXIST:
		world = world.instance()
		add_child(world)
		world.setup()
	
	# Test the game functions to check if they are OK. 
	$Test.test()
	
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	Logger.info("Loading game from " + "user://savegame.save")
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return ERR_DOES_NOT_EXIST# Error! We don't have a save to load.

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
	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var res = save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data: Dictionary = parse_json(save_game.get_line())

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object: Node = load(node_data["filename"]).instance()
		
		if node_data.has("pos_x") and node_data.has("pos_y"):
			new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
			
		if node_data.has("is_generated"):
			new_object.is_generated = node_data.is_generated
			
		get_node(node_data["parent"]).add_child(new_object)
			
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "is_generated":
				continue
			new_object.set(i, node_data[i])
			
		if new_object.has_method("setup"):
			new_object.call("setup")
		

	save_game.close()
	Logger.info("Game was loaded from " + "user://savegame.save")

# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	Logger.info("Saving game to " + "user://savegame.save")
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			Logger.warn("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			Logger.warn("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(to_json(node_data))
	save_game.close()
	Logger.info("Game was saved to " + "user://savegame.save")

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
	Console.write_line("Saving game to " + "user://savegame.save")
	save_game()
	Console.write_line("Game was saved to " + "user://savegame.save")

func load_game_cmd():
	Console.write_line("Loading game from " + "user://savegame.save")
	load_game()
	Console.write_line("Game was loaded from " + "user://savegame.save")
