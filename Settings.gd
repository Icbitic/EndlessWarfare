extends Node

var version = "0.2.1"

var map_size = 256

var saven_path = "user://test_saven"

var echo_recordings = true
var restore_logs_to_memory = false
var logs_in_milliseconds = false
var record_navigation_details = false
var enable_test_set = false
var draw_chunk_outline = false
var draw_cell_outline = false

func _ready():
	var file = File.new()
	if (file.open("res://settings.json", File.READ)) == OK:
		var settings: Dictionary = parse_json(file.get_as_text())
		
		for i in settings.keys():
			set(i, settings[i])
		# Todo: Find out a way to make mod able to add some settings here.
		
	else:
		Logger.info("Unable to load res://info.json")

func check_compatibility(version_support):
	match typeof(version_support):
		TYPE_STRING:
			return version.match(version_support)
		TYPE_ARRAY:
			var res = false
			for i in version_support:
				if version.match(i):
					res = true
			return res
		_:
			Logger.info("Unknow type of version_support", 1)
			return ERR_DOES_NOT_EXIST
