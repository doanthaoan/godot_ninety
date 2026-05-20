# WorldMapGenerator.gd
# Handles procedural creation of the world map with tile levels and resource distribution.

extends Node
class_name WorldMapGenerator

signal map_generated(width, height)

enum TileType { WASTE, WOOD, STONE, FOOD }

var map_width = 20
var map_height = 20
var grid_data = {} # Dictionary mapping Vector2i to WorldTileData
var level_4_5_count = 0
var max_level_4_5_per_area = 3

class WorldTileData:
	var type: int
	var level: int
	var generation: Dictionary # {wood: x, stone: y, food: z}
	func _init(t: int, l: int, g: Dictionary):
		type = t
		level = l
		generation = g

func generate_map():
	grid_data.clear()
	level_4_5_count = 0
	
	for x in range(map_width):
		for y in range(map_height):
			var tile_type = determine_tile_type(Vector2i(x, y))
			var tile_level = determine_tile_level(tile_type, Vector2i(x, y))
			var gen_rate = calculate_generation(tile_type, tile_level)
			grid_data[Vector2i(x, y)] = WorldTileData.new(tile_type, tile_level, gen_rate)
	
	map_generated.emit(map_width, map_height)
	
	var level_counts = {}
	for data in grid_data.values():
		level_counts[data.level] = level_counts.get(data.level, 0) + 1
	
	print("WorldMapGenerator: Map Generated: ", map_width, "x", map_height)
	print("WorldMapGenerator: Level Distribution: ", level_counts)

func determine_tile_type(_pos: Vector2i) -> int:
	var roll = randf()
	if roll < 0.60:
		return TileType.WASTE
	elif roll < 0.73:
		return TileType.WOOD
	elif roll < 0.86:
		return TileType.STONE
	else:
		return TileType.FOOD

func determine_tile_level(tile_type: int, pos: Vector2i) -> int:
	if tile_type == TileType.WASTE:
		return 1
	
	var nearby_high_level = count_nearby_high_level(pos, 5)
	var roll = randf()
	var level: int
	
	if nearby_high_level >= max_level_4_5_per_area:
		if roll < 0.70: level = 2
		else: level = 3
	else:
		if roll < 0.50: level = 2
		elif roll < 0.80: level = 3
		elif roll < 0.95: level = 4
		else: level = 5
	
	if level >= 4: level_4_5_count += 1
	return level

func count_nearby_high_level(pos: Vector2i, radius: int) -> int:
	var count = 0
	for x in range(pos.x - radius, pos.x + radius + 1):
		for y in range(pos.y - radius, pos.y + radius + 1):
			var check_pos = Vector2i(x, y)
			if check_pos == pos: continue
			var data = grid_data.get(check_pos)
			if data and data.level >= 4: count += 1
	return count

func calculate_generation(type: int, level: int) -> Dictionary:
	# Base generation for all tiles
	var wood = 1
	var stone = 1
	var food = 1
	
	# Bonus based on Level and Type
	var bonus = 0
	match level:
		2: bonus = 3
		3: bonus = 6 # 3 (from Lv2) + 3
		4: bonus = 9 # 6 (from Lv3) + 3
		5: bonus = 14 # 9 (from Lv4) + 5
	
	match type:
		TileType.WOOD: wood += bonus
		TileType.STONE: stone += bonus
		TileType.FOOD: food += bonus
		# Waste stays at 1,1,1
		
	return {"wood": wood, "stone": stone, "food": food}

func get_tile_at(coords: Vector2i) -> WorldTileData:
	return grid_data.get(coords, WorldTileData.new(TileType.WASTE, 1, {"wood":1, "stone":1, "food":1}))
