extends Node2D

var packs
var map = preload("res://game_world/world.tscn")

func _ready():
	Logger.output_format = "[{TIME}][{LVL}]{MSG}"
	# Load mods from the mods folder.
	
	Logger.info("Starting loading mods.")
	
	if $PacksManager.load_packs("mods") == OK:
		Logger.info(str($PacksManager.get_packs().size()) + " mod(s) loaded successfully.")
		packs = $PacksManager.get_packs()
		
		for i in packs.keys():
			if packs[i].check_compatibility() == false:
				Logger.warn("Warning! " + packs[i].name + " is not compatible with this version")
			# Todo: put an enable option condition here
			else:
				var node = packs[i].get_data().scene.instance()
				self.add_child(node)
				Logger.info("Mod actived: " + packs[i].get_data().name + ".")
	
	map = map.instance()
	add_child(map)
	
	# Test the game functions to check if they are OK. 
	$Test.test()
	
# Public Methods

# Private Methods
