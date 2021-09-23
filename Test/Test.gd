extends Node

func _ready():
	Logger.record("Starting testing game functions.")
	var initial_time = OS.get_ticks_msec()
	if Settings.enable_test_set:
		
		var data = Database.new()
		
		# Test Database
		data.set_value("text", "Database tested")
		Logger.record(data.get_value("text") + " successfully")
	
	var final_time = OS.get_ticks_msec()
	Logger.record("Finished testing game functions in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
