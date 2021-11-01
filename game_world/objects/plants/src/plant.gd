extends Sprite
class_name Plant


func _ready():
	add_to_group("Persist")
	
func save():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"position": position,
		"name": name
	}
	return save_dict
