# TileCommandPanel.gd
# Unified panel for tile actions: Attack, Move, Build, Remove.

extends Panel
class_name TileCommandPanel

signal attack_requested()
signal move_requested()
signal build_requested(building_key: String)
signal remove_requested()
signal closed()

@onready var building_manager: BuildingManager
var btn_container: VBoxContainer

func init(manager: BuildingManager):
	building_manager = manager
	size = Vector2(180, 200)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Add solid background to catch clicks
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	add_theme_stylebox_override("panel", style)
	
	btn_container = VBoxContainer.new()
	btn_container.position = Vector2(10, 10)
	btn_container.size = Vector2(160, 180)
	add_child(btn_container)

func show_for_unowned(screen_pos: Vector2, vp_size: Vector2):
	_clear_buttons()
	
	var btn = Button.new()
	btn.text = "Attack"
	btn.pressed.connect(_on_attack_pressed)
	btn_container.add_child(btn)
	
	_show(screen_pos, vp_size)

func show_for_owned(tile_type: int, has_building: bool, building_name: String, screen_pos: Vector2, vp_size: Vector2):
	_clear_buttons()
	
	# 1. Move Button
	var move_btn = Button.new()
	move_btn.text = "Move"
	move_btn.pressed.connect(_on_move_pressed)
	btn_container.add_child(move_btn)
	
	# 2. Separator
	var sep = HSeparator.new()
	btn_container.add_child(sep)
	
	# 3. Building Options
	if has_building:
		var remove_btn = Button.new()
		remove_btn.text = "Remove " + building_name
		remove_btn.pressed.connect(_on_remove_pressed)
		btn_container.add_child(remove_btn)
	else:
		var allowed_keys = building_manager.get_allowed_buildings(tile_type)
		for key in allowed_keys:
			var stats = building_manager.building_types[key]
			var btn = Button.new()
			btn.text = stats.name
			btn.pressed.connect(_on_build_pressed.bind(key))
			btn_container.add_child(btn)
			
	_show(screen_pos, vp_size)

func _clear_buttons():
	for child in btn_container.get_children():
		child.queue_free()

func _show(screen_pos: Vector2, vp_size: Vector2):
	# Resize panel to fit content
	var content_height = btn_container.get_combined_minimum_size().y + 20
	size.y = clamp(content_height, 100, 400)
	btn_container.size.y = size.y - 20
	
	position = Vector2(
		clamp(screen_pos.x + 15, 0, vp_size.x - size.x),
		clamp(screen_pos.y + 15, 0, vp_size.y - size.y)
	)
	visible = true

func _on_attack_pressed():
	attack_requested.emit()
	closed.emit()
	visible = false

func _on_move_pressed():
	move_requested.emit()
	closed.emit()
	visible = false

func _on_build_pressed(key: String):
	build_requested.emit(key)
	closed.emit()
	visible = false

func _on_remove_pressed():
	remove_requested.emit()
	closed.emit()
	visible = false

func _input(event):
	if visible and event is InputEventMouseButton and event.pressed:
		var local_pos = get_local_mouse_position()
		if not Rect2(Vector2.ZERO, size).has_point(local_pos):
			closed.emit()
			visible = false
