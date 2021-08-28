extends Node2D

func _ready():
	if Info.settings.enable_test_set:
		GlobalNavigation.search_path(Vector2(0, 0), Vector2(0, 1))
