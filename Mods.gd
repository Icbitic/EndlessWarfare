extends Node2D

var main_scene = []

func load_mods():
	LogRecorder.record("Starting loading mods")
	dir_contents("res://mods")
	LogRecorder.record(str(main_scene.size()) + "mod(s) are loaded successfully")
	
func dir_contents(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				if file_name.match("*.pck"):
					var mod_name = dir.get_current_dir()
					if mod_name != "mod":
						ProjectSettings.load_resource_pack(mod_name 
								+ file_name)
						main_scene.append(load("res://mod//" 
								+ mod_name + "Main.tscn").instance())
						LogRecorder.record(mod_name + "loaded sucessfully")
						
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
