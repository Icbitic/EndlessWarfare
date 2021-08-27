extends Node2D

func _ready():
	GlobalNavigation.search_path(Vector2(0, 0), Vector2(0, 1))
