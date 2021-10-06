extends Node

var velocity = Vector2(0, 0)

const TEXTURE_SHEET_WIDTH = 8

func _ready():
	Console.add_command("tp", self, "tp_cmd")\
	.set_description("Go to the given position.")\
	.add_argument("pos_x", TYPE_INT)\
	.add_argument("pos_y", TYPE_INT)\
	.register()
	
func exit_loading():
	Console.remove_command("tp")
	
func tp_cmd(pos_x, pos_y):
	$"0/Camera2D".position = Vector2(pos_x * TEXTURE_SHEET_WIDTH, pos_y * TEXTURE_SHEET_WIDTH)
