# BaseUI.gd
# Manages the HUD: Resource labels and Build buttons.

extends CanvasLayer

# REFERENCES
var resource_manager: ResourceManager
var base_manager: BaseManager

# UI NODES
var lbl_wood: Label
var lbl_stone: Label
var lbl_food: Label
var lbl_message: Label
var btn_tower: Button
var btn_barracks: Button

# BUILDING STATS
var main_tower_stats: BuildingStats
var barracks_stats: BuildingStats

func _ready():
	print("BaseUI: Ready!")
	
	# 1. Find ResourceManager
	resource_manager = get_node_or_null("/root/BaseScene/ResourceManager")
	
	# 2. Find BaseManager
	base_manager = get_node_or_null("/root/BaseScene/BaseManager")
	
	# 3. Find UI Elements by Name (Recursive search)
	lbl_wood = find_child("LblWood", true, false)
	lbl_stone = find_child("LblStone", true, false)
	lbl_food = find_child("LblFood", true, false)
	lbl_message = find_child("LblMessage", true, false)
	btn_tower = find_child("BtnTower", true, false)
	btn_barracks = find_child("BtnBarracks", true, false)
	
	# 4. Connect Signals
	if resource_manager:
		resource_manager.resources_changed.connect(_update_resource_labels)
	
	if btn_tower:
		btn_tower.pressed.connect(_on_tower_pressed)
	if btn_barracks:
		btn_barracks.pressed.connect(_on_barracks_pressed)
	
	if base_manager:
		base_manager.placement_failed.connect(_show_message)
	
	# 5. Initialize Data
	main_tower_stats = BuildingStats.new()
	main_tower_stats.building_name = "Main Tower"
	main_tower_stats.wood_cost = 200
	main_tower_stats.stone_cost = 200
	
	barracks_stats = BuildingStats.new()
	barracks_stats.building_name = "Barracks"
	barracks_stats.wood_cost = 100
	barracks_stats.stone_cost = 50
	
	_update_resource_labels()
	_show_message("Welcome! Select a building to start.")

# BUTTON ACTIONS
func _on_tower_pressed():
	print("BaseUI: Tower button pressed!")
	if base_manager:
		base_manager.select_building(main_tower_stats)
		_show_message("Selected: Main Tower (200 Wood, 200 Stone)")

func _on_barracks_pressed():
	print("BaseUI: Barracks button pressed!")
	if base_manager:
		base_manager.select_building(barracks_stats)
		_show_message("Selected: Barracks (100 Wood, 50 Stone)")

# UI UPDATES
func _update_resource_labels():
	if lbl_wood: lbl_wood.text = "Wood: " + str(resource_manager.wood)
	if lbl_stone: lbl_stone.text = "Stone: " + str(resource_manager.stone)
	if lbl_food: lbl_food.text = "Food: " + str(resource_manager.food)

func _show_message(text: String):
	if lbl_message:
		lbl_message.text = text
		# Auto-clear after 3 seconds
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): 
			if lbl_message: 
				lbl_message.text = ""
		)
