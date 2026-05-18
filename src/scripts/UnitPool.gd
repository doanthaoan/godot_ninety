# UnitPool.gd
# Manages the collection of trained units ready for deployment.

extends Node
class_name UnitPool

signal unit_added(unit_stats: UnitStats)

var trained_units: Array[UnitStats] = []

func add_unit(unit: UnitStats):
	trained_units.append(unit)
	unit_added.emit(unit)
	print("UnitPool: Added ", unit.unit_name, " (Total: ", trained_units.size(), ")")

func get_unit_count() -> int:
	return trained_units.size()
