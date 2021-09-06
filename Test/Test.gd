extends Node

func _ready():
	if Info.settings.enable_test_set:
		# Test GlobalNavigation
		GlobalNavigation.search_path(Vector2(0, 0), Vector2(0, 1))
		
		var data = Database.new()
		
		# Test Database
		data.set_value("text", "Database tested")
		LogRecorder.record(data.get_value("text") + " successfully")
