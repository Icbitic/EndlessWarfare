extends Camera2D

# This MOVE_SPEED is in cells
const MOVE_SPEED = 150
const ZOOM_SPEED = 2
const TEXTURE_SHEET_WIDTH = 8

var _target_zoom = zoom

var is_focus_moving = false

var input = {
	"ui_right": false,
	"ui_left": false,
	"ui_down": false,
	"ui_up": false,
	"zoom_in": false,
	"zoom_out": false
}

func _ready():
	# The limit is in pixels and positive.
	var limit = 0.5 * Settings.map_size * TEXTURE_SHEET_WIDTH
	limit_left = -limit
	limit_top = -limit
	limit_right = limit
	limit_bottom = limit
	
	
func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	
	if input.ui_right:
		velocity.x += 1
	if input.ui_left:
		velocity.x -= 1
	if input.ui_down:
		velocity.y += 1
	if input.ui_up:
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * MOVE_SPEED * TEXTURE_SHEET_WIDTH * delta
	
	var block_length = 0.5 * OS.get_real_window_size() * zoom.x
	#print(block_length)
	position.x = clamp(position.x + velocity.x, limit_left + block_length.x, limit_right - block_length.x)
	position.y = clamp(position.y + velocity.y, limit_top + block_length.y, limit_bottom - block_length.y)
	
	
	if input.zoom_in:
		_target_zoom = clamp(zoom.x - ZOOM_SPEED * 0.2, 0.25, 0.5)
		_target_zoom = _target_zoom * Vector2(1, 1)
	if input.zoom_out:
		_target_zoom = clamp(zoom.x + ZOOM_SPEED * 0.2, 0.25, 0.5)
		_target_zoom = _target_zoom * Vector2(1, 1)
		
	$Tween.interpolate_property(self, "zoom",
			zoom, _target_zoom, 0.1,
			Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()

# warning-ignore:unused_argument
func _unhandled_input(event):
	if Input.is_action_pressed("ui_right"):
		input.ui_right = true
	if Input.is_action_pressed("ui_left"):
		input.ui_left = true
	if Input.is_action_pressed("ui_down"):
		input.ui_down = true
	if Input.is_action_pressed("ui_up"):
		input.ui_up = true
		
	if Input.is_action_just_released("ui_right"):
		input.ui_right = false
	if Input.is_action_just_released("ui_left"):
		input.ui_left = false
	if Input.is_action_just_released("ui_down"):
		input.ui_down = false
	if Input.is_action_just_released("ui_up"):
		input.ui_up = false
	
	
	
	if Input.is_action_just_released("zoom_in"):
		input.zoom_in = true
	if Input.is_action_just_released("zoom_out"):
		input.zoom_out = true
		
	if not Input.is_action_just_released("zoom_in"):
		input.zoom_in = false
	if not Input.is_action_just_released("zoom_out"):
		input.zoom_out = false
	

func get_persist_data():
	var save_dict = {
		"position": position,
		"zoom": zoom,
		"_target_zoom": _target_zoom
	}
	return save_dict
