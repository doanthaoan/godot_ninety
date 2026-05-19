# CommandPalette.gd
extends Panel
class_name CommandPalette

signal attack_pressed(troop_id: int, target_tile: Vector2i)

var current_troop_id: int = -1
var target_tile: Vector2i = Vector2i.ZERO
var btn: Button

func setup(troop_id: int, tile: Vector2i, screen_pos: Vector2, viewport_size: Vector2):
	current_troop_id = troop_id
	target_tile = tile
	size = Vector2(120, 60)
	
	# Position on screen using passed viewport_size (avoids !is_inside_tree error)
	position = Vector2(
		clamp(screen_pos.x, 0, viewport_size.x - size.x),
		clamp(screen_pos.y, 0, viewport_size.y - size.y)
	)
	
	btn = Button.new()
	btn.text = "Attack"
	btn.size = Vector2(100, 40)
	btn.position = Vector2(10, 10)
	btn.pressed.connect(_on_attack_pressed)
	add_child(btn)

func _on_attack_pressed():
	attack_pressed.emit(current_troop_id, target_tile)
	queue_free()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var local_pos = get_local_mouse_position()
		if not Rect2(Vector2.ZERO, size).has_point(local_pos):
			queue_free()
