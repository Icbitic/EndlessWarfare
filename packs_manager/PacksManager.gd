extends Node

const pack_data_template = [
	"name",
	"version",
	"version_support",
	"is_enabled"
	]

var pack_paths = {}

var packs = {}

# Public Methods

func load_packs(path):
	# Don't send res:// here
	return _search_packs(path)

func load_off():
	Logger.info("All packs are loaded off.")
	var amount = packs.size()
	packs = {}
	return amount

func get_packs():
	return packs

func list_mods():
	if not packs.keys().size() == 0:
		var s = "Mods loaded: "
		for i in packs.keys():
			s += i + ", "
		s.erase(s.length() - 2, 2)
		return s
	else:
		return "No mods were loaded."

# Privare Methods
func _search_packs(path, intended = false):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and !intended:
				pass
				_search_packs(path + "/" + file_name, true)
			else:
				if file_name.match("*.pck"):
					if dir.get_current_dir() != path:
						var file = File.new()
						var info
						if (file.open(dir.get_current_dir() + "/info.json", File.READ)) == OK:
							info = parse_json(file.get_as_text())
							if not info.has_all(pack_data_template):
								Logger.error(dir.get_current_dir() + "/info.json doesn't match the template.")
								return ERR_FILE_NOT_FOUND
						else:
							Logger.info("Unable to load" + dir.get_current_dir() + "/info.json")
						
						
						
						var pack_data = {
							"path": dir.get_current_dir()+ "/" + file_name,
							"scene": null,
							"name": info.name,
							"version": info.version,
							"version_support": info.version_support,
							"is_enabled": info.is_enabled
						}
						
#						var package = Pack.new()
#						package.setup_data(pack_data)
						
						packs[pack_data.name] = pack_data
						Logger.info(str(pack_data.name) + " is loaded successfully.")
						
			file_name = dir.get_next()
	else:
		Logger.info(path + " is missing")
		return ERR_FILE_BAD_PATH
	dir.list_dir_end()
	return OK
