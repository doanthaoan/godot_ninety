# ResourceManager.gd
# Manages global economy and passive resource generation.

extends Node
class_name ResourceManager

signal resources_changed

var wood: int = 1000
var stone: int = 1000
var food: int = 1000

# Dictionary mapping tile positions to their generation rates (per tick)
var tile_rates: Dictionary = {}

# Base Production (Scaled for 6-second tick)
# 4/sec * 6 = 24 per tick
var base_wood_gen: int = 24
var base_stone_gen: int = 24
var base_food_gen: int = 24

# Current income per tick (for HUD)
var current_wood_income: int = 0
var current_stone_income: int = 0
var current_food_income: int = 0

func _ready():
	add_to_group("resource_manager")
	print("ResourceManager: Initialized. Base Gen: ", base_wood_gen, " Wood/6s")
	
	var timer = Timer.new()
	timer.wait_time = 6.0 # 6 seconds per tick
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
	
	current_wood_income = total_wood
	current_stone_income = total_stone
	current_food_income = total_food
	
	print("ResourceManager: Tick! Income: +", total_wood, " Wood, +", total_stone, " Stone, +", total_food, " Food")
	print("ResourceManager: Balance: Wood=", wood, " Stone=", stone, " Food=", food)
	resources_changed.emit()

func add_owned_tile_rate(tile_pos: Vector2i, rate: Dictionary):
	# Scale tile rates for 6-second tick (original was per second)
	var scaled_rate = {
		"wood": rate.get("wood", 0) * 6,
		"stone": rate.get("stone", 0) * 6,
		"food": rate.get("food", 0) * 6
	}
	tile_rates[tile_pos] = scaled_rate
	print("ResourceManager: Added tile ", tile_pos, " generation: ", scaled_rate)

func update_tile_rate(tile_pos: Vector2i, new_rate: Dictionary):
	var scaled_rate = {
		"wood": new_rate.get("wood", 0) * 6,
		"stone": new_rate.get("stone", 0) * 6,
		"food": new_rate.get("food", 0) * 6
	}
	tile_rates[tile_pos] = scaled_rate
	print("ResourceManager: Updated tile ", tile_pos, " generation: ", scaled_rate)

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
