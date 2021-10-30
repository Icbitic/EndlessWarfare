extends Node

var name_to_id = {}
var id_to_name = {}

func _ready():
	Console.add_command("listmapping", self, "_list_mapping_cmd")\
	.set_description("List current cell id mapping")\
	.register()

func save():
	var save_dict = {
		"name_to_id": name_to_id
	}
	return save_dict

func get_mapping():
	return name_to_id

func add_cell(name: String):
	if name_to_id.has(name):
		return ERR_ALREADY_EXISTS
	var id = name_to_id.size()
	name_to_id[name] = id
	id_to_name[id] = name
	# Returns the global id.
	return id
	
func get_id_by_name(name: String):
	if not name_to_id.has(name):
		return ERR_DOES_NOT_EXIST
	return int(name_to_id[name])

func get_name_by_id(id):
	if not id_to_name.has(id):
		return ERR_DOES_NOT_EXIST
	return int(id_to_name[id])

func _list_mapping_cmd():
	Console.write(JSON.print(name_to_id, "\t"))
	Console.write("\n")
