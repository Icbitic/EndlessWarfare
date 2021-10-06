extends PersistObject

func get_persist_data():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"Hello": "World!"
	}
	return save_dict

func test():
	add_to_group("Persist")
	Logger.info("Starting testing game functions.")
	var initial_time = OS.get_ticks_msec()
	if Settings.enable_test_set:
		
		var data = Database.new()
		
		# Test Database
		data.set_value("text", "Database tested")
		Logger.info(data.get_value("text") + " successfully")
	
	var final_time = OS.get_ticks_msec()
	Logger.info("Finished testing game functions in " +
			str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	
