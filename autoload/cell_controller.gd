extends Node

var name_to_cell = {} setget _set_name_to_id
var id_to_name = {}

func _ready():
	Console.add_command("listmapping", self, "_list_mapping_cmd")\
	.set_description("List current cell id mapping")\
	.register()
	return OK

func save():
	var save_dict = {
		"name_to_cell": name_to_cell
	}
	return save_dict

func get_mapping():
	return name_to_cell

func add_cell(cell_name: String, layer):
	if name_to_cell.has(cell_name):
		return ERR_ALREADY_EXISTS
	var id = name_to_cell.size()
	
	var cell_data = {
		"id": id,
		"layer": layer
	}
	
	name_to_cell[cell_name] = cell_data
	id_to_name[id] = cell_name
	# Returns the global id.
	return id
	
# cell_name -> id
func get_id_by_name(cell_name: String):
	if not name_to_cell.has(cell_name):
		return ERR_DOES_NOT_EXIST
	return name_to_cell[cell_name].id

# id -> cell_name
func get_name_by_id(id):
	if id == -1:
		return "NULL"
	if not id_to_name.has(id):
		return ERR_DOES_NOT_EXIST
	return id_to_name[id]

# cell_name -> layer
func get_layer_by_name(cell_name):
	return name_to_cell[cell_name].layer

# id -> layer
func get_layer_by_id(id):
	if id == -1:
		return -1
	var layer = name_to_cell[id_to_name[id]].layer
	return layer

####               ####
#                     #
#   PRIVATE METHODS   #
#                     #
####               ####

func _list_mapping_cmd():
	Console.write(JSON.print(name_to_cell, "\t"))
	Console.write("\n")
	return OK

func _set_name_to_id(value):
	for i in value.keys():
		var cell_data = {
			"id": int(value[i].id),
			"layer": int(value[i].layer)
		}
		name_to_cell[i] = cell_data
		id_to_name[cell_data.id] = i
	return OK
