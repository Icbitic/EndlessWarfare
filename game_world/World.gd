extends Node2D

var player_id = 0
var player

var is_generated = false

onready var map = $Map

func setup():
	add_to_group("Persist")
	player = get_node("Players/" + str(player_id))
	if not is_generated:
		map.setup()
		is_generated = true
		
func exit_loading():
	$Map.exit_loading()
	
func save():
	var persist_data = {}
	
	persist_data["ori"] = self.get_persist_data()
	
	for i in get_children():
		if i.has_method("save"):
			persist_data[i.get_path()] = i.save()
	return persist_data
	
func get_persist_data():
	var save_dict = {
		"filename": get_filename(),
		"is_generated": is_generated,
		"parent" : get_parent().get_path()
	}
	return save_dict

func get_navigation():
	return $Navigation
