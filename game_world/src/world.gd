extends Node

var player_id = 0
var player

func _ready():
	pass
	
func get_navigation():
	if $Map.has_node("Navigation"):
		return $Map/Naviation
	else:
		Logger.error("Unable to find Navigation node.")
		return ERR_DOES_NOT_EXIST

func get_resources_on_map():
	if has_node("Map"):
		return $Map.get_resources()
	else:
		Logger.error("Unable to find Map node.")
		return ERR_DOES_NOT_EXIST
