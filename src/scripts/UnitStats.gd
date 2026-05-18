# UnitStats.gd
# This is a Resource class - it stores data, not game logic
# Resources are perfect for templates like unit stats, item definitions, etc.

extends Resource

# class_name makes this script globally accessible
# Now any script can create a UnitStats by typing: UnitStats.new()
class_name UnitStats

# @export makes these variables visible in the Godot Inspector
# You can edit these values visually without touching code!
@export var unit_name: String = "Blade-Shield"
@export var hp: int = 100
@export var attack_min: int = 10
@export var attack_max: int = 15
@export var defense: int = 5
@export var action_speed: int = 5 # Determines turn order in combat
@export var moving_speed: float = 1.0 # Tiles per second on world map
@export var move_range: int = 3 # How many tiles per turn in combat
@export var attack_range: int = 1 # 1 = melee, 2+ = ranged
@export var food_cost: int = 50 # Cost to train this unit

# Helper function to calculate random damage within min-max range
# 'randi_range' is a Godot built-in function
func get_random_attack() -> int:
	return randi_range(attack_min, attack_max)
