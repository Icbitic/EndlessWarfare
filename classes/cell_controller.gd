extends Node

var name_to_global = {}
var global_to_local = {}

func _ready():
	Console.add_command("listmapping", self, "_list_mapping_cmd")\
	.set_description("List current cell id mapping")\
	.register()

func save():
	var save_dict = {
		"name_to_global": name_to_global,
		"global_to_local": global_to_local
	}
	return save_dict

func get_mapping():
	return name_to_global

func add_cell(name: String, id):
	if name_to_global.has(name):
		return ERR_ALREADY_EXISTS
	name_to_global[name] = name_to_global.size()
	global_to_local[name_to_global.size()] = id
	# Returns the global id.
	return name_to_global.size()
	
func get_id_by_name(name: String):
	if not name_to_global.has(name):
		return ERR_DOES_NOT_EXIST
	return int(global_to_local[name_to_global[name]])

func _list_mapping_cmd():
	Console.write_line("Name-to-global: ")
	Console.write(JSON.print(name_to_global, "\t"))
	Console.write("\n")
	Console.write_line("Global-to-local: ")
	Console.write(JSON.print(global_to_local, "\t"))
	Console.write("\n")
