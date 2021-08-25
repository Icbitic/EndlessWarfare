extends Node2D

var mods = []
func _ready():
	LogRecorder.record("Starting loading mods")
	#Don't use res://mods here
	dir_contents("mods")
	
	LogRecorder.record(str(mods.size()) + " mod(s) loaded successfully")
	check_mod()
	
	for i in mods:
		var node = i.scene.instance()
		self.add_child(node)
		
func check_mod():
	for i in mods:
		if is_compatible(i) == false:
			LogRecorder.record("Warning! " + i.name
					+ " is not compatible with this version")
		
func is_compatible(mod):
	return Info.info.version.match(mod.version_support)
	
func dir_contents(path, intended = false):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and !intended:
				pass
				dir_contents(path + "//" + file_name, true)
			else:
				if file_name.match("*.pck"):
					if dir.get_current_dir() != "mods":
						var file = File.new()
						var info
						if (file.open(dir.get_current_dir()
								+ "//info.json", File.READ)) == OK:
							info = parse_json(file.get_line())
						else:
							LogRecorder.record("info.json is missing")
						
						ProjectSettings.load_resource_pack(dir.get_current_dir()
								+ "//" + file_name)
								
						var scene = load(info.name + ".tscn")
						var mod = {
							"scene": scene,
							"name": info.name,
							"version": info.version,
							"version_support": info.version_support
						}
						mods.append(mod)
						
			file_name = dir.get_next()
	else:
		LogRecorder.record("Mods folder is missing")
	dir.list_dir_end()
