class_name Database
extends Node2D

var data = {}

# Public Methods
func set_value(key, value):
	data[key] = value
	return OK
	
func get_value(key):
	return data[key]

func remove_value(key):
	if not data.has(key):
		return ERR_DOES_NOT_EXIST
	data.erase(key)
	return OK
	
func get_data():
	return data
