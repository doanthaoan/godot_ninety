# WorldMapInput.gd
extends Node
class_name WorldMapInput

@onready var troop_manager: TroopMovementManager = get_node("../TroopMovementManager")
@onready var map_gen: WorldMapGenerator = get_node("../WorldMapGenerator")
@onready var camera: Camera2D = get_node("../WorldMapCamera")

var ui_layer: CanvasLayer
var active_palette: CommandPalette = null

func _ready():
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)

func _input(event):
	if active_palette: return
	
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
		
	var nearby_troops = troop_manager.get_troops_in_range(target_tile, 5)
	
	# Calculate screen coordinates here so they are always in scope
	var screen_pos = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	
	if nearby_troops.size() > 0:
		_show_command_palette(nearby_troops[0], target_tile, screen_pos, vp_size)

func _show_command_palette(troop_data: Dictionary, target_tile: Vector2i, screen_pos: Vector2, vp_size: Vector2):
	var palette = CommandPalette.new()
	palette.setup(troop_data.id, target_tile, screen_pos, vp_size)
	palette.attack_pressed.connect(_on_attack_selected)
	ui_layer.add_child(palette)
	active_palette = palette

func _on_attack_selected(troop_id: int, target_tile: Vector2i):
	active_palette = null
	troop_manager.move_troop_to(troop_id, target_tile)
