extends Node2D

var subnode_data setget set_subnode_data

func save():
	var save_dict = {
		"subnode_data": {}
	}
	for i in get_children():
		if i.has_method("save"):
			save_dict.subnode_data[i.get_path()] = i.save()
	return save_dict

func set_subnode_data(value: Dictionary):
	for i in value.keys():
		if value[i].has("pos_x") and value[i].has("pos_y"):
			get_node(i).set("position", Vector2(value[i].pos_x, value[i].pos_y))
		for j in value[i].keys():
			get_node(i).set(j, value[i][j])
			if j == "pos_x" or j == "pos_y":
				continue
		if get_node(i).has_method("setup"):
			get_node(i).call("setup")


func _ready():
	pass
