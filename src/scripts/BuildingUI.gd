# BuildingUI.gd
# Context menu for building placement on owned tiles.

extends Panel
class_name BuildingUI

signal build_requested(building_key: String, tile_pos: Vector2i)
signal remove_requested(tile_pos: Vector2i)
signal closed()

@onready var building_manager: BuildingManager
var target_tile: Vector2i = Vector2i.ZERO
var target_tile_type: int = 0
var btn_container: VBoxContainer
var remove_btn: Button

func init(manager: BuildingManager):
	building_manager = manager
	size = Vector2(180, 200)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var title = Label.new()
	title.text = "Build Structure"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(180, 30)
	add_child(title)
	
	btn_container = VBoxContainer.new()
	btn_container.position = Vector2(10, 35)
	btn_container.size = Vector2(160, 155)
	add_child(btn_container)
	
	remove_btn = Button.new()
	remove_btn.text = "Remove Building"
	remove_btn.visible = false
	remove_btn.position = Vector2(10, 160)
	remove_btn.size = Vector2(160, 30)
	remove_btn.pressed.connect(_on_remove_pressed)
	add_child(remove_btn)

func show_at(tile_pos: Vector2i, tile_type: int, has_building: bool, building_name: String, screen_pos: Vector2, vp_size: Vector2):
	target_tile = tile_pos
	target_tile_type = tile_type
	
	# Clear previous buttons
	for child in btn_container.get_children():
		child.queue_free()
		
	if has_building:
		# Show Remove button
		remove_btn.text = "Remove " + building_name
		remove_btn.visible = true
		btn_container.visible = false
	else:
		# Show Build buttons based on restrictions
		remove_btn.visible = false
		btn_container.visible = true
		_create_buttons()
		
	position = Vector2(
		clamp(screen_pos.x + 15, 0, vp_size.x - size.x),
		clamp(screen_pos.y + 15, 0, vp_size.y - size.y)
	)
	visible = true

func _create_buttons():
	var allowed_keys = building_manager.get_allowed_buildings(target_tile_type)
	
	for key in allowed_keys:
		var stats = building_manager.building_types[key]
		var btn = Button.new()
		btn.text = stats.name
		btn.pressed.connect(_on_build_pressed.bind(key))
		btn_container.add_child(btn)

func _on_build_pressed(building_key: String):
	build_requested.emit(building_key, target_tile)
	closed.emit()
	visible = false

func _on_remove_pressed():
	remove_requested.emit(target_tile)
	closed.emit()
	visible = false

func _input(event):
	if visible and event is InputEventMouseButton and event.pressed:
		var local_pos = get_local_mouse_position()
		if not Rect2(Vector2.ZERO, size).has_point(local_pos):
			closed.emit()
			visible = false
