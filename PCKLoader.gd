extends Node2D

var pcks = []
func load_pck(path):
	
	#Don't use res:// here
	search_pck(path)
	
	
	for i in pcks:
		var node = i.scene.instance()
		self.add_child(node)
	return pcks
	
	
func search_pck(path, intended = false):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and !intended:
				pass
				search_pck(path + "//" + file_name, true)
			else:
				if file_name.match("*.pck"):
					if dir.get_current_dir() != path:
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
						var pck = {
							"scene": scene,
							"name": info.name,
							"version": info.version,
							"version_support": info.version_support
						}
						pcks.append(pck)
						
			file_name = dir.get_next()
	else:
		LogRecorder.record("pcks folder is missing")
	dir.list_dir_end()
