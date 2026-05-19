# WorldMapVisualizer.gd
# Manages the grid of Tile nodes and territory borders.

extends Node2D
class_name WorldMapVisualizer

@onready var map_gen = get_node("../WorldMapGenerator")

var tile_nodes: Dictionary = {}
var territory_border: TerritoryBorder

func _ready():
	print("WorldMapVisualizer: _ready() called.")
	
	territory_border = TerritoryBorder.new()
	territory_border.name = "TerritoryBorder"
	add_child(territory_border)
	
	if map_gen:
		print("WorldMapVisualizer: Found WorldMapGenerator. Connecting signal...")
		map_gen.map_generated.connect(_on_map_generated)
		print("WorldMapVisualizer: Generating map...")
		map_gen.generate_map()
	else:
		print("WorldMapVisualizer: ERROR - WorldMapGenerator not found!")

func _on_map_generated(width, height):
	print("WorldMapVisualizer: Received map_generated signal! Building grid...")
	_build_grid(width, height)

func _build_grid(width, height):
	print("WorldMapVisualizer: Building ", width * height, " tiles...")
	
	var tile_scene_path = "res://src/scenes/Tile.tscn"
	var tile_scene = load(tile_scene_path)
	
	if tile_scene == null:
		push_error("WorldMapVisualizer: Failed to load Tile scene at " + tile_scene_path)
		return
	
	var tile_count = 0
	
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var tile_data = map_gen.get_tile_at(pos)
			
			var tile_instance = tile_scene.instantiate()
			if tile_instance == null:
				push_error("WorldMapVisualizer: Failed to instantiate Tile at " + str(pos))
				continue
				
			tile_instance.init(tile_data.type, tile_data.level, pos)
			tile_instance.position = Vector2(x * 64, y * 64)
			
			add_child(tile_instance)
			tile_nodes[pos] = tile_instance
			tile_count += 1
			
	print("WorldMapVisualizer: Grid built successfully. Created ", tile_count, " tiles.")
	
	move_child(territory_border, -1)
	territory_border.queue_redraw()

func get_tile_node(pos: Vector2i) -> Tile:
	return tile_nodes.get(pos)
