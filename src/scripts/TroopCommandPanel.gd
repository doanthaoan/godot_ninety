# TroopCommandPanel.gd
# Compact UI panel for troop actions with proper layout.

extends Panel
class_name TroopCommandPanel

signal action_pressed(troop_id: int, target_tile: Vector2i, is_attack: bool)

var current_troop_id: int = -1
var target_tile: Vector2i = Vector2i.ZERO
var btn: Button
var lbl_info: Label

func setup(troop_id: int, tile: Vector2i, is_attack: bool, distance: int, time_estimate: float, screen_pos: Vector2, vp_size: Vector2):
	current_troop_id = troop_id
	target_tile = tile
	size = Vector2(160, 140) # Increased height to fit button
	
	position = Vector2(
		clamp(screen_pos.x + 15, 0, vp_size.x - size.x),
		clamp(screen_pos.y + 15, 0, vp_size.y - size.y)
	)
	
	var container = VBoxContainer.new()
	container.position = Vector2(10, 10)
	container.size = Vector2(140, 120) # Increased container height
	add_child(container)
	
	lbl_info = Label.new()
	var action_text = "Attack" if is_attack else "Move"
	lbl_info.text = "Target: (%d, %d)\nDist: %d tiles\nTime: %.1f sec" % [tile.x, tile.y, distance, time_estimate]
	container.add_child(lbl_info)
	
	btn = Button.new()
	btn.text = action_text
	btn.pressed.connect(_on_action_pressed)
	container.add_child(btn)

func _on_action_pressed():
	var is_attack = btn.text == "Attack"
	action_pressed.emit(current_troop_id, target_tile, is_attack)
	queue_free()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var local_pos = get_local_mouse_position()
		if not Rect2(Vector2.ZERO, size).has_point(local_pos):
			queue_free()
