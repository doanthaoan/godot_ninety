# Unit.gd
# Visual representation of a trained unit.

extends Node2D

var stats: UnitStats
var tile_position: Vector2i
var sprite: ColorRect

func init(unit_stats: UnitStats, pos: Vector2i, ui_offset_y: int = 0):
	stats = unit_stats
	tile_position = pos
	
	# Calculate visual position: Grid Pos + UI Offset
	var visual_x = pos.x * 64 + 32
	var visual_y = pos.y * 64 + 32 + ui_offset_y
	global_position = Vector2(visual_x, visual_y)
	
	# Create sprite here
	if sprite == null:
		sprite = ColorRect.new()
		sprite.size = Vector2(40, 40)
		sprite.position = Vector2(-20, -20)
		sprite.color = Color(1.0, 1.0, 1.0) # White
		add_child(sprite)
		
	print("Unit: Spawned ", stats.unit_name, " at Grid ", tile_position)
