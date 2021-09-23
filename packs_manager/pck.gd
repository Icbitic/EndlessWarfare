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
	
func check_compatibility():
	if data.has("version_support") == false:
		return ERR_DOES_NOT_EXIST
	match typeof(data.version_support):
		TYPE_STRING:
			return Settings.info.version.match(data.version_support)
		TYPE_ARRAY:
			var res = false
			for i in data.version_support:
				if Settings.version.match(i):
					res = true
			return res
		_:
			Logger.record("Unknow type of version_support", 1)
			return ERR_DOES_NOT_EXIST
