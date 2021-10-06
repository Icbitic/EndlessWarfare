extends PersistObject

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
	for i in _get_all_children():
		if i.has_method("exit_loading"):
			i.exit_loading()

func get_persist_data():
	var save_dict = {
		"filename": get_filename(),
		"is_generated": is_generated,
		"parent" : get_parent().get_path()
	}
	return save_dict

func get_navigation():
	return $Navigation
