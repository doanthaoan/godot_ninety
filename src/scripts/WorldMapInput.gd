# WorldMapInput.gd
extends Node
class_name WorldMapInput

@onready var troop_manager: TroopMovementManager = get_node("../TroopMovementManager")
@onready var map_gen: WorldMapGenerator = get_node("../WorldMapGenerator")
@onready var camera: Camera2D = get_node("../WorldMapCamera")
@onready var visualizer: WorldMapVisualizer = get_node("../WorldMapVisualizer")
@onready var building_manager: BuildingManager = get_node_or_null("../BuildingManager")
@onready var resource_manager: ResourceManager = get_node_or_null("../ResourceManager")

var ui_layer: CanvasLayer
var active_panel: Control = null
var management_panel: TroopsMovingManagementPanel
var tile_command_panel: TileCommandPanel
var troop_select_panel: TroopSelectPanel
var resource_hud

var pending_target: Vector2i = Vector2i.ZERO
var pending_is_attack: bool = false

func _ready():
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)
	
	management_panel = TroopsMovingManagementPanel.new()
	management_panel.init(troop_manager)
	ui_layer.add_child(management_panel)
	
	# Tile Command Panel
	tile_command_panel = TileCommandPanel.new()
	tile_command_panel.init(building_manager)
	tile_command_panel.attack_requested.connect(_on_attack_requested)
	tile_command_panel.move_requested.connect(_on_move_requested)
	tile_command_panel.build_requested.connect(_on_build_requested)
	tile_command_panel.remove_requested.connect(_on_remove_requested)
	tile_command_panel.closed.connect(_on_panel_closed)
	ui_layer.add_child(tile_command_panel)
	tile_command_panel.visible = false
		
	# Troop Select Panel
	troop_select_panel = TroopSelectPanel.new()
	troop_select_panel.init(troop_manager)
	troop_select_panel.action_confirmed.connect(_on_troops_selected)
	troop_select_panel.closed.connect(_on_panel_closed)
	ui_layer.add_child(troop_select_panel)
	troop_select_panel.visible = false
	
	# Resource HUD
	resource_hud = ResourceHUD.new()
	resource_hud.init(resource_manager)
	ui_layer.add_child(resource_hud)

# Use _unhandled_input so UI clicks don't trigger map logic
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# If a panel is open, this click is outside the panel (otherwise UI would handle it)
		if active_panel and active_panel.visible:
			# Close the panel and consume the click (don't process map)
			active_panel.visible = false
			active_panel = null
			return 
			
		_handle_click()

func _handle_click():
	if troop_manager == null or map_gen == null or camera == null: return
	
	var world_pos = camera.get_global_mouse_position()
	var tile_x = floor(world_pos.x / 64)
	var tile_y = floor(world_pos.y / 64)
	var target_tile = Vector2i(tile_x, tile_y)
	
	if tile_x < 0 or tile_x >= map_gen.map_width or tile_y < 0 or tile_y >= map_gen.map_height:
		return
		
	var tile_node = visualizer.get_tile_node(target_tile)
	var screen_pos = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	
	if tile_node and tile_node.is_owned:
		# Owned Tile: Show Move + Buildings
		tile_command_panel.show_for_owned(tile_node.tile_type, tile_node.has_building(), tile_node.current_building, screen_pos, vp_size)
		active_panel = tile_command_panel
		pending_target = target_tile
	else:
		# Unowned Tile: Show Attack
		tile_command_panel.show_for_unowned(screen_pos, vp_size)
		active_panel = tile_command_panel
		pending_target = target_tile
		pending_is_attack = true

func _on_attack_requested():
	active_panel = null
	# Open Troop Selection for Attack
	var screen_pos = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	troop_select_panel.show_for(pending_target, true, screen_pos, vp_size)
	active_panel = troop_select_panel

func _on_move_requested():
	active_panel = null
	# Open Troop Selection for Move
	var screen_pos = get_viewport().get_mouse_position()
	var vp_size = get_viewport().get_visible_rect().size
	troop_select_panel.show_for(pending_target, false, screen_pos, vp_size)
	active_panel = troop_select_panel

func _on_troops_selected(troop_ids: Array, target_tile: Vector2i, _is_attack: bool):
	active_panel = null
	troop_manager.move_troops_to(troop_ids, target_tile)

func _on_build_requested(building_key: String):
	active_panel = null
	if building_manager:
		building_manager.build(building_key, pending_target)

func _on_remove_requested():
	active_panel = null
	if building_manager:
		building_manager.remove_building(pending_target)

func _on_panel_closed():
	active_panel = null
