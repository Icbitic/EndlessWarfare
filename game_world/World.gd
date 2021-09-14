extends Node2D

var player_id = 0
var player 

func _ready():
	player = get_node("Players/" + str(player_id))
