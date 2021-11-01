extends Node

enum {TERRAIN, PATH, FLOOR, FENCE, WALL, PLANT}
enum {
	LAND, WATER, 
	DIRT_ROAD, STONE_ROAD, CEMENT_ROAD, MUD_ROAD,
	CLEAN_FLOOR, CRACKED_FLOOR, CRACKED_FLOOR2,
	WOODDEN_FENCE,
	BLACK_WALL,
	TREE, DEAD_TREE, BUSH
}

var version = "0.3.1"

var map_size = 256

var saven_path = "user://test_saven"

var echo_recordings = true
var restore_logs_to_memory = false
var logs_in_milliseconds = false
var record_navigation_details = false
var enable_test_set = false
var draw_chunk_outline = false
var draw_cell_outline = false
var save_before_quit = true

var verification_code = "1234"
var is_offical = true

func _ready():
	Console.add_command("saveset", self, "_save_settings_cmd")\
	.set_description("Save settings")\
	.register()
	
	Console.add_command("loadset", self, "_load_settings_cmd")\
	.set_description("Load settings")\
	.register()
	
	var err = load_settings()
	
	if err == ERR_CANT_OPEN:
		save_settings()
	
	return OK
	
func load_settings():
	var config = ConfigFile.new()
	#var err = config.load("user://settings.cfg")
	var err = config.load_encrypted_pass("user://settings.cfg", "123456")
	
	if err != OK:
		Logger.error("Error occurred when trying to load settings.cfg.")
		return err
	
	echo_recordings = config.get_value("Tech", "echo_recordings")
	restore_logs_to_memory = config.get_value("Tech", "restore_logs_to_memory")
	logs_in_milliseconds = config.get_value("Tech", "logs_in_milliseconds")
	record_navigation_details = config.get_value("Tech", "record_navigation_details")
	enable_test_set = config.get_value("Tech", "enable_test_set")
	draw_chunk_outline = config.get_value("Tech", "draw_chunk_outline")
	draw_cell_outline = config.get_value("Tech", "draw_cell_outline")
	save_before_quit = config.get_value("Tech", "save_before_quit")
	
	var code
	code = config.get_value("Verification", "verification_code")
	
	if code != verification_code:
		is_offical = false
	
	Logger.info("Verification Code: " + str(verification_code))
	
	return OK
	
func save_settings():
	var config = ConfigFile.new()
	config.set_value("Tech", "echo_recordings", echo_recordings)
	config.set_value("Tech", "restore_logs_to_memory", restore_logs_to_memory)
	config.set_value("Tech", "logs_in_milliseconds", logs_in_milliseconds)
	config.set_value("Tech", "record_navigation_details", record_navigation_details)
	config.set_value("Tech", "enable_test_set", enable_test_set)
	config.set_value("Tech", "draw_chunk_outline", draw_chunk_outline)
	config.set_value("Tech", "draw_cell_outline", draw_cell_outline)
	config.set_value("Tech", "save_before_quit", save_before_quit)
	
	config.set_value("Verification", "verification_code", verification_code)
	
	#config.save("user://settings.cfg")
	config.save_encrypted_pass("user://settings.cfg", "123456")
	
	return OK

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

####               ####
#                     #
#   PRIVATE METHODS   #
#                     #
####               ####

func _save_settings_cmd():
	var err = save_settings()
	
	if err != OK:
		Console.write_line("Error occurred when trying to save settings to user://settings.cfg.")
		return OK
	Console.write_line("Saved settings to user://settings.cfg.")
	return OK
	
func _load_settings_cmd():
	var err = load_settings()
	
	if err != OK:
		Console.write_line("Error occurred when trying to load settings to user://settings.cfg.")
		return OK
	Console.write_line("Loaded settings to user://settings.cfg.")
	
	return OK
