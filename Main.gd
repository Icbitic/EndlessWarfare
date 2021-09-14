extends Node2D

var packs

func _ready():
	
	LogRecorder.record("Starting loading mods.")
	
	if $PacksManager.load_packs("mods") == OK:
		LogRecorder.record(str($PacksManager.get_packs().size()) + " mod(s) loaded successfully.")
		packs = $PacksManager.get_packs()
		
		for i in packs.keys():
			if packs[i].check_compatibility() == false:
				LogRecorder.record("Warning! " + packs[i].name + " is not compatible with this version")
			# Todo: put an enable option condition here
			else:
				var node = packs[i].get_data().scene.instance()
				self.add_child(node)

# Public Methods

# Private Methods
