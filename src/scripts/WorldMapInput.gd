# WorldMapInput.gd
extends Node
class_name WorldMapInput

@onready var troop_manager: TroopMovementManager = get_node("../TroopMovementManager")
@onready var map_gen: WorldMapGenerator = get_node("../WorldMapGenerator")
@onready var camera: Camera2D = get_node("../WorldMapCamera")
@onready var visualizer: WorldMapVisualizer = get_node("../WorldMapVisualizer")

var ui_layer: CanvasLayer
var active_panel: TroopCommandPanel = null
var management_panel: TroopsMovingManagementPanel

func _ready():
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)
	
	# Initialize Troop Movement Management Panel
	management_panel = TroopsMovingManagementPanel.new()
	management_panel.init(troop_manager)
	ui_layer.add_child(management_panel)

func _input(event):
	if active_panel: return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click()

func _handle_click():
	if troop_manager == null or map_gen == null or camera == null: return
	
	var world_pos = camera.get_global_mouse_position()
	var tile_x = floor(world_pos.x / 64)
	var tile_y = floor(world_pos.y / 64)
	var target_tile = Vector2i(tile_x, tile_y)
	
	if tile_x < 0 or tile_x >= map_gen.map_width or tile_y < 0 or tile_y >= map_gen.map_height:
		return
		
	var nearest_troop = _find_nearest_troop(target_tile)
	if nearest_troop.is_empty():
		return
		
	var tile_node = visualizer.get_tile_node(target_tile)
	var is_owned = tile_node != null and tile_node.is_owned
	var is_attack = not is_owned
	
	var distance = troop_manager.get_distance_in_tiles(nearest_troop.current_tile, target_tile)
	var time_estimate = troop_manager.calculate_movement_time(distance, nearest_troop.speed)
	
	var screen_pos = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	_show_command_panel(nearest_troop, target_tile, is_attack, distance, time_estimate, screen_pos, vp_size)

func _find_nearest_troop(target: Vector2i) -> Dictionary:
	var best_troop = {}
	var best_dist = INF
	
	for t in troop_manager.troops:
		if t.is_moving:
			continue
		var dist = troop_manager.get_distance_in_tiles(t.current_tile, target)
		if dist < best_dist:
			best_dist = dist
			best_troop = t
			
	return best_troop

func _show_command_panel(troop_data: Dictionary, target_tile: Vector2i, is_attack: bool, distance: int, time_estimate: float, screen_pos: Vector2, vp_size: Vector2):
	var panel = TroopCommandPanel.new()
	panel.setup(troop_data.id, target_tile, is_attack, distance, time_estimate, screen_pos, vp_size)
	panel.action_pressed.connect(_on_action_selected)
	ui_layer.add_child(panel)
	active_panel = panel

func _on_action_selected(troop_id: int, target_tile: Vector2i, _is_attack: bool):
	active_panel = null
	troop_manager.move_troop_to(troop_id, target_tile)
