class_name Pack
extends Node

var data = {
	"scene": null,
	"name": null,
	"version": null,
	"version_support": null
}

func _init():
	pass

func _ready():
	pass

# Public Methods
func get_data():
	return data
	
func setup_data(pack_data):
	data = pack_data
	
