extends Control

var amount = 10

var icon = preload("res://hud/rolling_selection/icon.tscn")

var icons = []

func _ready():
	#Add icons to the scene tree
	for i in range(amount):
		var node = icon.instance()
		node.connect("_mouse_entered", self, "on_mouse_entered")
		node.connect("_mouse_exited", self, "on_mouse_exited")
		node.order = icons.size()
		icons.append(node)
		node.angle = 2 * PI / amount * i
		add_child(node)

func on_mouse_entered(order):
	pass

func on_mouse_exited(order):
	for i in range(icons.size()):
		icons[i].rect_scale = Vector2(1, 1)

