extends TextureButton

signal _mouse_entered
signal _mouse_exited

export var order = 0
export var angle = 0
var dist = 150


func _on_TextureButton_mouse_entered():
	$AnimationPlayer.play("increase")
	emit_signal("_mouse_entered", order)

func _process(delta):
	rect_position = Vector2(cos(angle) * dist, sin(angle) * dist)


func _on_TextureButton_mouse_exited():
	$AnimationPlayer.play("Decrease")
	emit_signal("_mouse_exited", order)

func _physics_process(delta):
	angle += delta * 0.02 * PI
