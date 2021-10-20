extends Node

var persist_value = "null"

func _ready():
	add_to_group("Persist")

func save():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"persist_value": "ok"
	}
	return save_dict

func test():
	if Settings.enable_test_set:
		# Test game saving.
		if persist_value == "ok":
			return true
		else:
			return false
	
