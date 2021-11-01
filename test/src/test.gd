extends Node

signal tested(result)

var persist_value = "null"

func _ready():
	add_to_group("Persist")

func save():
	var save_dict = {
		"filename": get_filename(),
		"parent" : get_parent().get_path(),
		"persist_value": "ok"
	}
	return save_dict

func test():
	var result = true
	if Settings.enable_test_set:
		Logger.info("Starting testing game functions.")
		var initial_time = OS.get_ticks_msec()
		
		# Test game saving.
		if persist_value == "ok":
			Logger.info("Game saving tested successfully")
		else:
			result = false
			Logger.error("Failed to test game saving.")
		
		var res = $Test2.test()
		
		if res:
			Logger.info("Game in-stages saving tested successfully")
		else:
			result = false
			Logger.error("Failed to test game in-stages saving.")
		
		emit_signal("tested", result)
		
		var final_time = OS.get_ticks_msec()
		Logger.info("Finished testing game functions in " +
				str(((final_time as float) - (initial_time as float)) / 1000) + "s.")
	
