# TrainingUI.gd
# The UI overlay that appears when clicking a Barracks to train units.

extends CanvasLayer
class_name TrainingUI

# UI Elements
@onready var panel: Panel = $Panel
@onready var lbl_building_name: Label = $Panel/MarginContainer/VBoxContainer/LblBuildingName
@onready var btn_train: Button = $Panel/MarginContainer/VBoxContainer/BtnTrain
@onready var progress_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/ProgressBar
@onready var btn_close: Button = $Panel/MarginContainer/VBoxContainer/BtnClose
@onready var lbl_status: Label = $Panel/MarginContainer/VBoxContainer/LblStatus

var current_barracks: Node = null
var is_training: bool = false
var training_time: float = 5.0
var timer: float = 0.0
var unit_cost: int = 50
var resource_manager: ResourceManager

func _ready():
	hide()
	
	if btn_train == null or btn_close == null:
		push_error("TrainingUI: UI nodes not found! Check scene hierarchy.")
		return

	btn_train.pressed.connect(_on_train_pressed)
	btn_close.pressed.connect(_on_close_pressed)
	
	# Find ResourceManager instance safely
	resource_manager = get_node_or_null("/root/BaseScene/ResourceManager")
	if resource_manager == null:
		push_error("TrainingUI: ResourceManager not found!")
	
	print("TrainingUI: Ready and hidden.")

func open_for_barracks(barracks_node: Node):
	print("TrainingUI: open_for_barracks() called for ", barracks_node.stats.building_name)
	current_barracks = barracks_node
	lbl_building_name.text = "Train at " + barracks_node.stats.building_name
	btn_train.disabled = false
	progress_bar.value = 0
	lbl_status.text = "Ready to train (Cost: " + str(unit_cost) + " Food)"
	lbl_status.modulate = Color.WHITE
	show()
	print("TrainingUI: Panel is now VISIBLE.")

func _on_train_pressed():
	if current_barracks and not is_training:
		if resource_manager and resource_manager.spend_resource("food", unit_cost):
			start_training()
		else:
			lbl_status.text = "Not enough Food!"
			lbl_status.modulate = Color.RED

func start_training():
	is_training = true
	timer = training_time
	btn_train.disabled = true
	lbl_status.text = "Training..."
	lbl_status.modulate = Color.WHITE
	print("TrainingUI: Training started...")

func _process(delta):
	if is_training:
		timer -= delta
		progress_bar.value = (1.0 - (timer / training_time)) * 100.0
		lbl_status.text = "Training... " + str(snapped(timer, 0.1)) + "s left"
		
		if timer <= 0:
			finish_training()

func finish_training():
	is_training = false
	
	var unit = UnitStats.new()
	unit.unit_name = "Blade-Shield"
	
	var pool = get_node_or_null("/root/BaseScene/UnitPool")
	if pool:
		pool.add_unit(unit)
	else:
		push_error("TrainingUI: UnitPool not found!")
	
	btn_train.disabled = false
	progress_bar.value = 0
	lbl_status.text = "Training Complete!"
	
	await get_tree().create_timer(1.5).timeout
	hide()
	print("TrainingUI: Training complete! Panel hidden.")

func _on_close_pressed():
	hide()
	is_training = false
	btn_train.disabled = false
	progress_bar.value = 0
