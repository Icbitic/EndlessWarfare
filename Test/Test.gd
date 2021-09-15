extends Node

func _ready():
	if Settings.enable_test_set:
		
		var data = Database.new()
		
		# Test Database
		data.set_value("text", "Database tested")
		LogRecorder.record(data.get_value("text") + " successfully")
