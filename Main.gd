extends Node2D

var packs
var map = preload("res://game_world/world.tscn")

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
	
	map = map.instance()
	add_child(map)
	
	# Test the game functions to check if they are OK. 
	$Test.test()
	
	
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
				var scene = load("res://" + packs[i].name + "//" + packs[i].name + ".tscn")
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
