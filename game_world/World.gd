extends Node2D

var player_id = 0
var player

var is_generated = false

onready var map = $Map

var subnode_data setget set_subnode_data

func setup():
	add_to_group("Persist")
	player = get_node("Players/" + str(player_id))
	if not is_generated:
		map.setup()
		is_generated = true
		
func exit_loading():
	$Map.exit_loading()
	
func save():
	var save_dict = {
		"filename": get_filename(),
		"is_generated": is_generated,
		"parent" : get_parent().get_path(),
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

func get_navigation():
	return $Navigation
