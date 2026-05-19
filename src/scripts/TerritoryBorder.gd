# TerritoryBorder.gd
extends Node2D
class_name TerritoryBorder

var owned_tiles: Array[Vector2i] = []
var border_color: Color = Color(0.0, 1.0, 0.0, 0.9)
var line_width: float = 5.0

func _ready():
	top_level = true # Ignore parent transforms for absolute positioning

func add_owned_tile(pos: Vector2i):
	if not owned_tiles.has(pos):
		owned_tiles.append(pos)
		print("TerritoryBorder: Added tile ", pos, " - Redrawing. Total owned: ", owned_tiles.size())
		queue_redraw()

func _draw():
	if owned_tiles.is_empty():
		return
		
	var dirs = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	
	for tile in owned_tiles:
		var x = tile.x * 64.0
		var y = tile.y * 64.0
		
		for dir in dirs:
			var neighbor = tile + dir
			if not owned_tiles.has(neighbor):
				match dir:
					Vector2i.RIGHT:
						draw_line(Vector2(x + 64, y), Vector2(x + 64, y + 64), border_color, line_width)
					Vector2i.DOWN:
						draw_line(Vector2(x, y + 64), Vector2(x + 64, y + 64), border_color, line_width)
					Vector2i.LEFT:
						draw_line(Vector2(x, y), Vector2(x, y + 64), border_color, line_width)
					Vector2i.UP:
						draw_line(Vector2(x, y), Vector2(x + 64, y), border_color, line_width)
