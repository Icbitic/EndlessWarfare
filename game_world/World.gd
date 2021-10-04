extends Node2D

var player_id = 0
var player

var is_generated = false

var map
var map_data: Dictionary setget set_map_data

func _ready():
	add_to_group("Persist")
	player = get_node("Players/" + str(player_id))
	$Map.setup()
	is_generated = true
	
func exit_loading():
	$Map.exit_loading()
	
func save():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"map_data": $Map.save(),
		"is_generated": is_generated
	}
	return save_dict

func set_map_data(value: Dictionary):
	for i in value.keys():
		$Map.set(i, value[i])

func get_navigation():
	return $Navigation
