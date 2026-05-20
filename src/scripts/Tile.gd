# Tile.gd
# Represents a single tile on the World Map with level-based resource sprites.

extends Node2D
class_name Tile

var tile_type: int = 0
var tile_level: int = 1
var is_owned: bool = false
var grid_pos: Vector2i = Vector2i.ZERO
var current_building: String = ""

var bg_sprite: Sprite2D
var resource_sprite: Sprite2D
var building_overlay: Sprite2D

const TERRAIN_PATH = "res://assets/Terrain/Tileset/terrain_1.png"
const RESOURCE_PATH = "res://assets/Terrain/Tileset/resource_lv1_5.png"

var terrain_tex: Texture2D
var resource_tex: Texture2D

# Resource sprite indices based on type and level
const RESOURCE_INDICES = {
	1: [0, 0, 0, 0],
	2: [0, 1, 3, 2],
	3: [0, 4, 6, 5],
	4: [0, 7, 9, 8],
	5: [0, 10, 12, 11]
}

func _ready():
	terrain_tex = load(TERRAIN_PATH)
	resource_tex = load(RESOURCE_PATH)
	
	bg_sprite = Sprite2D.new()
	if terrain_tex:
		bg_sprite.texture = terrain_tex
	else:
		var fallback = ColorRect.new()
		fallback.size = Vector2(64, 64)
		fallback.color = Color(0.2, 0.6, 0.2)
		add_child(fallback)
	bg_sprite.position = Vector2(32, 32)
	add_child(bg_sprite)
	
	resource_sprite = Sprite2D.new()
	if resource_tex:
		resource_sprite.texture = resource_tex
		resource_sprite.region_enabled = true
	resource_sprite.position = Vector2(32, 32)
	add_child(resource_sprite)
	
	# Building overlay
	building_overlay = Sprite2D.new()
	building_overlay.visible = false
	building_overlay.position = Vector2(32, 32)
	add_child(building_overlay)
	
	_update_visual()

func init(type: int, level: int, pos: Vector2i):
	tile_type = type
	tile_level = level
	grid_pos = pos
	_update_visual()

func set_owned():
	is_owned = true
	_update_visual()

func has_building() -> bool:
	return current_building != ""

func place_building(building_key: String):
	current_building = building_key
	building_overlay.visible = true
	# TODO: Load actual sprite
	print("Tile.gd: Building placed on ", grid_pos, " - Type: ", building_key)

func remove_building():
	current_building = ""
	building_overlay.visible = false
	print("Tile.gd: Building removed from ", grid_pos)

func _update_visual():
	if resource_sprite == null: return
	
	var level_data = RESOURCE_INDICES.get(tile_level, RESOURCE_INDICES[1])
	var sprite_index = level_data[tile_type]
	var region_x = sprite_index * 64
	
	if resource_tex:
		resource_sprite.region_rect = Rect2(region_x, 0, 64, 64)
	
	resource_sprite.modulate = Color(1.2, 1.2, 1.2) if is_owned else Color(1.0, 1.0, 1.0)
