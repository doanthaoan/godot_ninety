# BuildingStats.gd
# This is a "Pure Data" Resource. It only stores information.
# It does NOT handle logic like checking money or spending it.
# That logic belongs in a Manager script (like BaseManager).

extends Resource

class_name BuildingStats

@export var building_name: String = "Building"
@export var wood_cost: int = 100
@export var stone_cost: int = 100
@export var training_time: float = 30.0 # Seconds to train a unit
@export var description: String = "A basic construction"

# We can keep a helper to get the total cost, as that is internal data
func get_total_cost() -> int:
	return wood_cost + stone_cost
