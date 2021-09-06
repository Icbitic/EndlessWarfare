extends Node2D

var pcks


func _ready():
	
	LogRecorder.record("Starting loading mods.")
	
	if PacksManager.load_pck("mods") == OK:
		LogRecorder.record(str(PacksManager.get_pcks().size()) + " mod(s) loaded successfully.")
		
		for i in PacksManager.get_pcks():
			if i.check_compatibility() == false:
				LogRecorder.record("Warning! " + i.name
						+ " is not compatible with this version")
			# Todo: put an enable option condition here
			else:
				var node = i.get_data().scene.instance()
				self.add_child(node)

# Public Methods

# Private Methods
