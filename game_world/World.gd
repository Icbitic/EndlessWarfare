extends Node2D


#APIs
func search_path(start: Vector2, end: Vector2, optimize: bool = true):
	return $Navigation.get_simple_path(start, end, optimize)
