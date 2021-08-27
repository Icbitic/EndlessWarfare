extends Node2D

var data = {}

#APIs
func add_area(identifier):
	if data.has(identifier):
		return ERR_ALREADY_EXISTS
	data[identifier] = {}

func set_value(identifier, key, value):
	if data.has(identifier) == false:
		return ERR_DOES_NOT_EXIST
	data[identifier][key] = value
	
func get_value(identifier, key):
	return data[identifier][key]
