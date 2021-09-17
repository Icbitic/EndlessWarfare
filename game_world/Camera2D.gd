extends Camera2D

# This MOVE_SPEED is in cells
const MOVE_SPEED = 150
const ZOOM_SPEED = 2
const TEXTURE_SHEET_WIDTH = 8


func _ready():
	pass

func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * MOVE_SPEED * TEXTURE_SHEET_WIDTH * delta
	
	position += velocity
	
	if Input.is_action_just_released("zoom_in"):
		zoom -= ZOOM_SPEED * delta * Vector2(1, 1)
	if Input.is_action_just_released("zoom_out"):
		zoom += ZOOM_SPEED * delta * Vector2(1, 1)
