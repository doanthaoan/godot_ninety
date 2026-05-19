# WorldMapGenerator.gd
# Handles the procedural creation of the 100x100 grid map.

extends Node
class_name WorldMapGenerator

signal map_generated(width, height)

enum TileType { WASTE, WOOD, STONE, FOOD }

var map_width = 100
var map_height = 100
var grid_data = {} # Dictionary mapping Vector2i to TileType

func generate_map():
	# Clear existing data
	grid_data.clear()
	
	for x in range(map_width):
		for y in range(map_height):
			var tile_type = determine_tile_type()
			grid_data[Vector2i(x, y)] = tile_type
	
	map_generated.emit(map_width, map_height)
	print("WorldMapGenerator: Map Generated: ", map_width, "x", map_height)

func determine_tile_type() -> int:
	var roll = randf()
	if roll < 0.60: # 60% chance for Waste
		return TileType.WASTE
	elif roll < 0.73: # 13% Wood
		return TileType.WOOD
	elif roll < 0.86: # 13% Stone
		return TileType.STONE
	else: # 14% Food
		return TileType.FOOD

func get_tile_at(coords: Vector2i) -> int:
	return grid_data.get(coords, TileType.WASTE)
