# BuildingStats.gd
# Data templates for world map buildings.

extends Resource
class_name BuildingStats

@export var name: String = "Building"
@export var icon_path: String = ""
@export var cost_wood: int = 0
@export var cost_stone: int = 0
@export var cost_food: int = 0
@export var production_bonus: Dictionary = {"wood": 0, "stone": 0, "food": 0}
@export var description: String = ""
@export var allowed_types: Array = [] # Empty means any tile type allowed
