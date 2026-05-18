# Building.gd
# Simple visual representation of a building.

extends Node2D

# PROPERTIES
var stats: BuildingStats
var tile_position: Vector2i
var sprite: ColorRect

func init(building_stats: BuildingStats, pos: Vector2i, ui_offset_y: int = 0):
	stats = building_stats
	tile_position = pos
	
	# Calculate visual position: Grid Pos + UI Offset
	var visual_x = pos.x * 64 + 32
	var visual_y = pos.y * 64 + 32 + ui_offset_y
	global_position = Vector2(visual_x, visual_y)
	
	# Create sprite here to ensure it exists before coloring
	if sprite == null:
		sprite = ColorRect.new()
		sprite.size = Vector2(60, 60)
		sprite.position = Vector2(-30, -30)
		add_child(sprite)
		
	_update_visuals()

func _update_visuals():
	if sprite == null: return
	if stats == null: return
		
	match stats.building_name:
		"Main Tower":
			sprite.color = Color(1.0, 0.0, 0.0) # Red
		"Barracks":
			sprite.color = Color(0.0, 0.4, 1.0) # Blue
		_:
			sprite.color = Color(0.5, 0.5, 0.5) # Gray
