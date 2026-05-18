# ResourceManager.gd
# This is a "Singleton" - a script that manages global game data
# In Godot, we attach this to a Node and access it from anywhere

extends Node
class_name ResourceManager

# SIGNALS: These are like "events" that other scripts can listen to
# When resources change, we emit this signal so the UI can update
signal resources_changed

# VARIABLES: These store your current resource amounts
# 'var' declares a variable, ': int' means it must be a whole number
var wood: int = 1000
var stone: int = 1000
var food: int = 1000

# FUNCTIONS: These are actions the ResourceManager can perform

# Add resources to your stockpile
# 'type' is a String (text), 'amount' is an integer
func add_resource(type: String, amount: int) -> void:
	# 'match' is like a switch statement - it checks the value of 'type'
	match type.to_lower(): # to_lower() converts "Wood" to "wood" for consistency
		"wood": wood += amount
		"stone": stone += amount
		"food": food += amount
	
	# Emit the signal to notify other scripts that resources changed
	resources_changed.emit()

# Spend resources (returns true if successful, false if not enough)
# '-> bool' means this function returns a true/false value
func spend_resource(type: String, amount: int) -> bool:
	match type.to_lower():
		"wood":
			if wood >= amount: # Check if we have enough
				wood -= amount
				resources_changed.emit()
				return true # Success!
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
	
	return false # Not enough resources

# Get all resources as a Dictionary (key-value pairs)
# '-> Dictionary' means this function returns a Dictionary
func get_balance() -> Dictionary:
	return {"wood": wood, "stone": stone, "food": food}
