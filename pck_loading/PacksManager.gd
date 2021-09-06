extends Node

var pcks = []

# Public Methods

func load_pck(path):
	# Don't send res:// here
	return _search_pck(path)
	
func get_pcks():
	return pcks
	
# Privare Methods
func _search_pck(path, intended = false):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and !intended:
				pass
				_search_pck(path + "//" + file_name, true)
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
						
						if !ProjectSettings.load_resource_pack(dir.get_current_dir()
								+ "//" + file_name):
							LogRecorder.record("Unable to load "
									+ dir.get_current_dir()+ "//" + file_name, 1)
							break
								
						var scene = load(info.name + ".tscn")
						var pack_data = {
							"scene": scene,
							"name": info.name,
							"version": info.version,
							"version_support": info.version_support
						}
						var package = Pack.new()
						package.setup_data(pack_data)
						pcks.append(package)
						LogRecorder.record(str(pack_data.name) + " is loaded successfully.")
						
			file_name = dir.get_next()
	else:
		LogRecorder.record(path + " is missing")
		return ERR_DOES_NOT_EXIST
	dir.list_dir_end()
	return OK
