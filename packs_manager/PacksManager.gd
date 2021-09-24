extends Node

var packs = {}

# Public Methods

func load_packs(path):
	# Don't send res:// here
	return _search_packs(path)
	
func get_packs():
	return packs
	
# Privare Methods
func _search_packs(path, intended = false):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and !intended:
				pass
				_search_packs(path + "//" + file_name, true)
			else:
				if file_name.match("*.pck"):
					if dir.get_current_dir() != path:
						var file = File.new()
						var info
						if (file.open(dir.get_current_dir() + "//info.json", File.READ)) == OK:
							info = parse_json(file.get_as_text())
						else:
							Logger.info("Unable to load" + dir.get_current_dir() + "//info.json")
						
						
						if not ProjectSettings.load_resource_pack(dir.get_current_dir()
								+ "//" + file_name):
							Logger.error("Error occurred when trying to load " + dir.get_current_dir()+ "/" + file_name, ERR_CANT_RESOLVE)
							break
						
						var scene = load("res://" + info.name + "//" + info.name + ".tscn")
						var pack_data = {
							"scene": scene,
							"name": info.name,
							"version": info.version,
							"version_support": info.version_support
						}
						var package = Pack.new()
						package.setup_data(pack_data)
						packs[pack_data.name] = package
						Logger.info(str(pack_data.name) + " is loaded successfully.")
						
			file_name = dir.get_next()
	else:
		Logger.info(path + " is missing")
		return ERR_DOES_NOT_EXIST
	dir.list_dir_end()
	return OK
