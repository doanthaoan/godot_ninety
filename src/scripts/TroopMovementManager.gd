# TroopMovementManager.gd
extends Node
class_name TroopMovementManager

signal troop_arrived(troop_id, tile_position)
signal tile_captured(tile_position, resource_type)

var troops: Array = []
var troop_id_counter: int = 0

@onready var map_gen: WorldMapGenerator = get_node("../WorldMapGenerator")
@onready var visualizer: WorldMapVisualizer = get_node("../WorldMapVisualizer")
@onready var camera: Camera2D = get_node("../WorldMapCamera")

const WARRIOR_TEX_PATH = "res://assets/Units/blade-shield/south-west.png"
var WARRIOR_TEX: Texture2D
const TILE_SIZE = 64.0
const BASE_SPEED = 200.0 # pixels per second

func _ready():
	WARRIOR_TEX = load(WARRIOR_TEX_PATH)
	call_deferred("spawn_initial_troop")

func spawn_initial_troop():
	var start_tile = Vector2i(10, 10)
	spawn_troop(start_tile)
	if camera:
		camera.global_position = Vector2(start_tile.x * TILE_SIZE + 32, start_tile.y * TILE_SIZE + 32)
	print("TroopMovementManager: Initial troop spawned at ", start_tile)

func spawn_troop(start_tile: Vector2i) -> int:
	var id = troop_id_counter
	troop_id_counter += 1
	
	var visual = Sprite2D.new()
	if WARRIOR_TEX:
		visual.texture = WARRIOR_TEX
		visual.position = Vector2(32, 32)
	else:
		var fallback = ColorRect.new()
		fallback.size = Vector2(40, 40)
		fallback.color = Color(1.0, 0.0, 0.0)
		fallback.position = Vector2(-20, -20)
		visual.add_child(fallback)
		
	var world_pos = Vector2(start_tile.x * TILE_SIZE + 32, start_tile.y * TILE_SIZE + 32)
	visual.global_position = world_pos
	visualizer.add_child(visual)
	
	troops.append({
		"id": id,
		"visual": visual,
		"current_tile": start_tile,
		"target_tile": start_tile,
		"is_moving": false,
		"speed": BASE_SPEED
	})
	return id

func get_troop_by_id(id: int) -> Dictionary:
	for t in troops:
		if t.id == id:
			return t
	return {}

func get_distance_in_tiles(from: Vector2i, to: Vector2i) -> int:
	return abs(to.x - from.x) + abs(to.y - from.y)

func calculate_movement_time(distance_tiles: int, speed: float) -> float:
	var distance_pixels = distance_tiles * TILE_SIZE
	return distance_pixels / speed

func move_troop_to(troop_id: int, target_tile: Vector2i):
	for t in troops:
		if t.id == troop_id:
			t.start_tile = t.current_tile
			t.target_tile = target_tile
			t.is_moving = true
			print("TroopMovementManager: Troop ", troop_id, " moving to ", target_tile)
			return

func _process(delta):
	for t in troops:
		if t.is_moving:
			var target_pos = Vector2(t.target_tile.x * TILE_SIZE + 32, t.target_tile.y * TILE_SIZE + 32)
			var dir = (target_pos - t.visual.global_position).normalized()
			t.visual.global_position += dir * t.speed * delta
			
			if t.visual.global_position.distance_to(target_pos) < 5.0:
				t.visual.global_position = target_pos
				t.is_moving = false
				t.current_tile = t.target_tile
				_capture_tile(t.target_tile)
				troop_arrived.emit(t.id, t.target_tile)

func _capture_tile(tile_pos: Vector2i):
	if map_gen and visualizer:
		var tile_data = map_gen.get_tile_at(tile_pos)
		var tile_type = tile_data.type
		var tile_node = visualizer.get_tile_node(tile_pos)
		if tile_node:
			tile_node.set_owned()
		if visualizer.territory_border:
			visualizer.territory_border.add_owned_tile(tile_pos)
		tile_captured.emit(tile_pos, tile_type)
