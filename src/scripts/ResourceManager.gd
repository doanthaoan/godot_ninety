# ResourceManager.gd
# Manages global economy and passive resource generation.

extends Node
class_name ResourceManager

signal resources_changed

var wood: int = 1000
var stone: int = 1000
var food: int = 1000

# Dictionary mapping tile positions to their generation rates
var tile_rates: Dictionary = {}

# Base Production (Simulating 4 Base tiles generating 1/sec each)
var base_wood_gen: int = 4
var base_stone_gen: int = 4
var base_food_gen: int = 4

func _ready():
	add_to_group("resource_manager")
	print("ResourceManager: Initialized. Base Gen: ", base_wood_gen, " Wood/sec")
	
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(_on_production_tick)
	add_child(timer)
	timer.start()

func _on_production_tick():
	var total_wood = base_wood_gen
	var total_stone = base_stone_gen
	var total_food = base_food_gen
	
	for rate in tile_rates.values():
		total_wood += rate.get("wood", 0)
		total_stone += rate.get("stone", 0)
		total_food += rate.get("food", 0)
		
	wood += total_wood
	stone += total_stone
	food += total_food
	
	print("ResourceManager: Tick! Total Income: +", total_wood, " Wood, +", total_stone, " Stone, +", total_food, " Food")
	print("ResourceManager: Current Balance: Wood=", wood, " Stone=", stone, " Food=", food)
	resources_changed.emit()

func add_owned_tile_rate(tile_pos: Vector2i, rate: Dictionary):
	tile_rates[tile_pos] = rate
	print("ResourceManager: Added tile ", tile_pos, " generation: ", rate)

func update_tile_rate(tile_pos: Vector2i, new_rate: Dictionary):
	tile_rates[tile_pos] = new_rate
	print("ResourceManager: Updated tile ", tile_pos, " generation: ", new_rate)

func remove_owned_tile_rate(tile_pos: Vector2i):
	tile_rates.erase(tile_pos)

func spend_resource(type: String, amount: int) -> bool:
	match type:
		"wood":
			if wood >= amount:
				wood -= amount
				resources_changed.emit()
				return true
		"stone":
			if stone >= amount:
				stone -= amount
				resources_changed.emit()
				return true
		"food":
			if food >= amount:
				food -= amount
				resources_changed.emit()
				return true
	return false

func get_resource(type: String) -> int:
	match type:
		"wood": return wood
		"stone": return stone
		"food": return food
	return 0
