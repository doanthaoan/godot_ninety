# Tile.gd
extends Node2D
class_name Tile

var tile_type: int = 0
var is_owned: bool = false
var grid_pos: Vector2i = Vector2i.ZERO

var bg_sprite: Sprite2D
var resource_sprite: Sprite2D

const TERRAIN_PATH = "res://assets/Terrain/Tileset/terrain_1.png"
const RESOURCE_PATH = "res://assets/Terrain/Tileset/resource_lv1.png"

var terrain_tex: Texture2D
var resource_tex: Texture2D

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
	
	_update_visual()

func init(type: int, pos: Vector2i):
	tile_type = type
	grid_pos = pos
	_update_visual()

func set_owned():
	is_owned = true
	_update_visual()

func _update_visual():
	if resource_sprite == null: return
	var region_x = 0
	match tile_type:
		0: region_x = 0
		1: region_x = 64
		2: region_x = 192
		3: region_x = 128
	if resource_tex:
		resource_sprite.region_rect = Rect2(region_x, 0, 64, 64)
	resource_sprite.modulate = Color(1.2, 1.2, 1.2) if is_owned else Color(1.0, 1.0, 1.0)
