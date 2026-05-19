# WorldMapCamera.gd
# Allows panning and zooming across the large world map.

extends Camera2D
class_name WorldMapCamera

var pan_speed = 800.0
var zoom_speed = 0.1
var min_zoom = 0.5
var max_zoom = 2.0

func _ready():
	# Initialize camera position to center of the map (0,0 is top-left, so we center on 50,50)
	global_position = Vector2(50 * 64, 50 * 64)
	zoom = Vector2(1.0, 1.0)
	make_current()
	print("WorldMapCamera: Initialized at center of map.")

func _process(delta):
	var input_dir = Vector2.ZERO
	
	# WASD / Arrow Keys for panning
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
		
	if input_dir != Vector2.ZERO:
		global_position += input_dir.normalized() * pan_speed * delta
	
	# Zoom with +/- or Mouse Wheel
	if Input.is_key_pressed(KEY_EQUAL) or Input.is_key_pressed(KEY_KP_ADD):
		zoom += Vector2(zoom_speed, zoom_speed)
	if Input.is_key_pressed(KEY_MINUS) or Input.is_key_pressed(KEY_KP_SUBTRACT):
		zoom -= Vector2(zoom_speed, zoom_speed)
		
	# Clamp zoom
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
