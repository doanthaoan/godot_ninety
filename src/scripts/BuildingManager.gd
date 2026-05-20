# BuildingManager.gd
# Handles building placement, costs, and production bonuses on the World Map.

extends Node
class_name BuildingManager

signal building_placed(tile_pos: Vector2i, building_name: String)
signal building_removed(tile_pos: Vector2i)
signal build_failed(reason: String)

@onready var resource_manager: ResourceManager
@onready var map_gen: WorldMapGenerator
@onready var visualizer: WorldMapVisualizer

# Building Definitions
var building_types = {}

func _ready():
	resource_manager = get_node_or_null("../ResourceManager")
	map_gen = get_node_or_null("../WorldMapGenerator")
	visualizer = get_node_or_null("../WorldMapVisualizer")
	
	_init_building_types()

func _init_building_types():
	var sawmill = BuildingStats.new()
	sawmill.name = "Sawmill"
	sawmill.cost_wood = 50
	sawmill.cost_stone = 20
	sawmill.production_bonus = {"wood": 5, "stone": 0, "food": 0}
	sawmill.allowed_types = [WorldMapGenerator.TileType.WOOD] # Restriction
	building_types["sawmill"] = sawmill
	
	var farm = BuildingStats.new()
	farm.name = "Farm"
	farm.cost_wood = 30
	farm.cost_food = 20
	farm.production_bonus = {"wood": 0, "stone": 0, "food": 5}
	farm.allowed_types = [WorldMapGenerator.TileType.FOOD]
	building_types["farm"] = farm
	
	var quarry = BuildingStats.new()
	quarry.name = "Quarry"
	quarry.cost_wood = 40
	quarry.cost_stone = 30
	quarry.production_bonus = {"wood": 0, "stone": 5, "food": 0}
	quarry.allowed_types = [WorldMapGenerator.TileType.STONE]
	building_types["quarry"] = quarry
	
	var tower = BuildingStats.new()
	tower.name = "Watchtower"
	tower.cost_wood = 60
	tower.cost_stone = 60
	tower.production_bonus = {"wood": 0, "stone": 0, "food": 0}
	tower.allowed_types = [] # Empty means any
	building_types["tower"] = tower

func can_build(building_key: String, tile_pos: Vector2i) -> bool:
	if not building_types.has(building_key):
		build_failed.emit("Invalid building type")
		return false
		
	var stats = building_types[building_key]
	var tile_data = map_gen.get_tile_at(tile_pos)
	var tile_node = visualizer.get_tile_node(tile_pos)
	
	if not tile_node or not tile_node.is_owned:
		build_failed.emit("Tile not owned")
		return false
		
	if tile_node.has_building():
		build_failed.emit("Tile already has a building")
		return false
		
	# Check Tile Type Restriction
	if stats.allowed_types.size() > 0 and not stats.allowed_types.has(tile_data.type):
		build_failed.emit("Cannot build " + stats.name + " on this tile type")
		return false
		
	if resource_manager.wood < stats.cost_wood:
		build_failed.emit("Not enough Wood")
		return false
	if resource_manager.stone < stats.cost_stone:
		build_failed.emit("Not enough Stone")
		return false
	if resource_manager.food < stats.cost_food:
		build_failed.emit("Not enough Food")
		return false
		
	return true

func build(building_key: String, tile_pos: Vector2i) -> bool:
	if not can_build(building_key, tile_pos):
		return false
		
	var stats = building_types[building_key]
	
	resource_manager.spend_resource("wood", stats.cost_wood)
	resource_manager.spend_resource("stone", stats.cost_stone)
	resource_manager.spend_resource("food", stats.cost_food)
	
	var tile_node = visualizer.get_tile_node(tile_pos)
	tile_node.place_building(building_key)
	
	var new_rate = _calculate_new_rate(tile_pos, stats)
	resource_manager.update_tile_rate(tile_pos, new_rate)
	
	building_placed.emit(tile_pos, stats.name)
	print("BuildingManager: Built ", stats.name, " at ", tile_pos)
	return true

func remove_building(tile_pos: Vector2i) -> bool:
	var tile_node = visualizer.get_tile_node(tile_pos)
	if not tile_node or not tile_node.has_building():
		return false
		
	var current_building = tile_node.current_building
	var tile_data = map_gen.get_tile_at(tile_pos)
	
	# Reset generation to base tile rate
	resource_manager.update_tile_rate(tile_pos, tile_data.generation)
	
	# Clear visual
	tile_node.remove_building()
	
	building_removed.emit(tile_pos)
	print("BuildingManager: Removed ", current_building, " from ", tile_pos)
	return true

func _calculate_new_rate(tile_pos: Vector2i, building_stats: BuildingStats) -> Dictionary:
	var tile_data = map_gen.get_tile_at(tile_pos)
	var base_rate = tile_data.generation.duplicate()
	
	base_rate["wood"] += building_stats.production_bonus.get("wood", 0)
	base_rate["stone"] += building_stats.production_bonus.get("stone", 0)
	base_rate["food"] += building_stats.production_bonus.get("food", 0)
	
	return base_rate

func get_building_cost(building_key: String) -> Dictionary:
	if building_types.has(building_key):
		var stats = building_types[building_key]
		return {"wood": stats.cost_wood, "stone": stats.cost_stone, "food": stats.cost_food}
	return {}

func get_allowed_buildings(tile_type: int) -> Array:
	var allowed = []
	for key in building_types:
		var stats = building_types[key]
		if stats.allowed_types.size() == 0 or stats.allowed_types.has(tile_type):
			allowed.append(key)
	return allowed
