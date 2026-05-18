# BaseManager.gd
# Manages the Base Grid, building placement, resource costs, and unit spawning.

extends Node2D
class_name BaseManager

# SIGNALS
signal building_placed(building_name, position)
signal placement_failed(reason)

# LAYOUT CONFIGURATION
const TILE_SIZE = 64
const GRID_WIDTH = 10
const GRID_HEIGHT = 10
const UI_HEIGHT = 200 # Pixels reserved for the top UI panel

# STATE
var selected_building_stats: BuildingStats = null
var buildings: Array = [] # Stores placed building & unit nodes

# REFERENCES
@onready var resource_manager: ResourceManager = get_node("../ResourceManager")
@onready var buildings_layer: Node2D = get_node("../BuildingsLayer")
@onready var unit_pool: UnitPool

func _ready():
	print("BaseManager: Ready!")
	if resource_manager:
		resource_manager.resources_changed.connect(_on_resources_changed)
	if buildings_layer == null:
		print("BaseManager: WARNING - BuildingsLayer not found!")
		
	unit_pool = get_node_or_null("/root/BaseScene/UnitPool")
	if unit_pool:
		unit_pool.unit_added.connect(_on_unit_added)
		print("BaseManager: Connected to UnitPool")

func select_building(stats: BuildingStats):
	selected_building_stats = stats
	print("BaseManager: Selected building: ", stats.building_name)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_building_stats != null:
			_try_place_building()
		else:
			_check_entity_click()

func _try_place_building():
	var mouse_pos = get_global_mouse_position()
	
	# Adjust for UI Height to get Grid Coordinates
	var grid_x = floor(mouse_pos.x / TILE_SIZE)
	var grid_y = floor((mouse_pos.y - UI_HEIGHT) / TILE_SIZE)
	var tile_pos = Vector2i(grid_x, grid_y)
	
	# Check if click is within the Grid Zone
	if grid_y < 0:
		placement_failed.emit("Click is in the UI area!")
		return
		
	if grid_x < 0 or grid_x >= GRID_WIDTH or grid_y < 0 or grid_y >= GRID_HEIGHT:
		placement_failed.emit("Out of bounds!")
		return
	
	if _is_tile_occupied(tile_pos):
		placement_failed.emit("Tile already occupied!")
		return
	
	if not resource_manager.spend_resource("wood", selected_building_stats.wood_cost) or \
	   not resource_manager.spend_resource("stone", selected_building_stats.stone_cost):
		placement_failed.emit("Not enough resources!")
		return
	
	_place_building(selected_building_stats, tile_pos)
	selected_building_stats = null 

func _check_entity_click():
	var mouse_pos = get_global_mouse_position()
	
	# Adjust for UI Height
	var clicked_tile_x = floor(mouse_pos.x / TILE_SIZE)
	var clicked_tile_y = floor((mouse_pos.y - UI_HEIGHT) / TILE_SIZE)
	var clicked_tile = Vector2i(clicked_tile_x, clicked_tile_y)
	
	if clicked_tile_y < 0: return # Ignore clicks in UI area
	
	for b in buildings:
		if b.tile_position == clicked_tile:
			# Distinguish between Building and Unit based on stats type
			if b.stats is BuildingStats:
				print("BaseManager: Clicked BUILDING: ", b.stats.building_name)
				_on_building_clicked(b)
			elif b.stats is UnitStats:
				print("BaseManager: Clicked UNIT: ", b.stats.unit_name)
				_on_unit_clicked(b)
			return # Stop after first click

func _is_tile_occupied(tile_pos: Vector2i) -> bool:
	for b in buildings:
		if b.tile_position == tile_pos:
			return true
	return false

func _find_empty_tile() -> Vector2i:
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if not _is_tile_occupied(Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func _place_building(stats: BuildingStats, tile_pos: Vector2i):
	var building_scene = preload("res://src/scenes/Building.tscn")
	var b = building_scene.instantiate()
	
	# Pass UI_HEIGHT so the building knows where to position itself visually
	b.init(stats, tile_pos, UI_HEIGHT)
	
	if buildings_layer:
		buildings_layer.add_child(b)
	else:
		add_child(b)
		
	buildings.append(b)
	
	building_placed.emit(stats.building_name, tile_pos)
	print("BaseManager: Placed ", stats.building_name, " at Grid ", tile_pos)

func _on_building_clicked(building_node):
	print("BaseManager: Processing click for Building: ", building_node.stats.building_name)
	if building_node.stats.building_name == "Barracks":
		var training_ui = get_node_or_null("/root/BaseScene/TrainingOverlay")
		if training_ui:
			training_ui.open_for_barracks(building_node)
		else:
			print("BaseManager: ERROR - TrainingUI not found!")

func _on_unit_clicked(unit_node):
	print("BaseManager: Processing click for Unit: ", unit_node.stats.unit_name)
	# TODO: Open Unit Details UI (Stats, Features, etc.)
	print("BaseManager: (Placeholder) Opening Unit Details Layer...")

func _on_unit_added(unit_stats: UnitStats):
	print("BaseManager: Spawning unit: ", unit_stats.unit_name)
	var spawn_pos = _find_empty_tile()
	if spawn_pos != Vector2i(-1, -1):
		var unit_scene = preload("res://src/scenes/Unit.tscn")
		var u = unit_scene.instantiate()
		# Pass UI_HEIGHT for visual positioning
		u.init(unit_stats, spawn_pos, UI_HEIGHT)
		if buildings_layer:
			buildings_layer.add_child(u)
		else:
			add_child(u)
		buildings.append(u)
		print("BaseManager: Unit spawned at Grid ", spawn_pos)
	else:
		print("BaseManager: No empty tiles to spawn unit!")

func _on_resources_changed():
	pass
