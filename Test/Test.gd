extends Node2D

func _ready():
	if Info.settings.enable_test_set:
		# Test GlobalNavigation
		GlobalNavigation.search_path(Vector2(0, 0), Vector2(0, 1))
		
		# Test Database
		Database.add_area("BaseGame")
		Database.set_value("BaseGame", "text", "Database tested")
		LogRecorder.record(Database.get_value("TestMod", "text") + " successfully")
