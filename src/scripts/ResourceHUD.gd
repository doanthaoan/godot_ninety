# ResourceHUD.gd
# Generic UI Component for displaying resource balance and income.
# Reusable in WorldMap, BaseScene, or any other scene.

extends Panel
class_name ResourceHUD

@onready var resource_manager: ResourceManager

# Icon regions in resource_lv1_5.png (64px width each)
const ICON_WOOD = 64
const ICON_STONE = 192
const ICON_FOOD = 128

var wood_label: Label
var wood_income_label: Label
var stone_label: Label
var stone_income_label: Label
var food_label: Label
var food_income_label: Label

func init(manager: ResourceManager):
	resource_manager = manager
	
	# Setup Layout using Anchors for reusability
	anchor_left = 0.5
	anchor_right = 0.5
	anchor_top = 0.0
	anchor_bottom = 0.0
	offset_left = -300 # Half of width (600)
	offset_right = 300
	offset_top = 10
	offset_bottom = 60
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.85)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.size = Vector2(600, 50)
	add_child(hbox)
	
	# Wood
	_create_resource_item(hbox, ICON_WOOD, "wood")
	_add_separator(hbox)
	
	# Stone
	_create_resource_item(hbox, ICON_STONE, "stone")
	_add_separator(hbox)
	
	# Food
	_create_resource_item(hbox, ICON_FOOD, "food")
	
	# Connect signal
	if resource_manager:
		resource_manager.resources_changed.connect(_update_display)
		_update_display()

func _add_separator(parent: Node):
	var sep = VSeparator.new()
	sep.custom_minimum_size = Vector2(2, 30)
	sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(sep)

func _create_resource_item(parent: Node, icon_region_x: int, type: String):
	var item_hbox = HBoxContainer.new()
	item_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(item_hbox)
	
	# Icon
	var icon = TextureRect.new()
	# FIX: Force icon size to 24x24
	icon.custom_minimum_size = Vector2(24, 24)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP
	
	var tex = load("res://assets/Terrain/Tileset/resource_lv1_5.png")
	if tex:
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(icon_region_x, 0, 64, 64)
		icon.texture = atlas
	item_hbox.add_child(icon)
	
	# Labels
	var lbl_amount = Label.new()
	lbl_amount.custom_minimum_size = Vector2(60, 24)
	lbl_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_amount.add_theme_font_size_override("font_size", 16)
	item_hbox.add_child(lbl_amount)
	
	var lbl_income = Label.new()
	lbl_income.custom_minimum_size = Vector2(50, 24)
	lbl_income.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	lbl_income.add_theme_font_size_override("font_size", 14)
	item_hbox.add_child(lbl_income)
	
	# Store references
	match type:
		"wood":
			wood_label = lbl_amount
			wood_income_label = lbl_income
		"stone":
			stone_label = lbl_amount
			stone_income_label = lbl_income
		"food":
			food_label = lbl_amount
			food_income_label = lbl_income

func _update_display():
	if resource_manager == null: return
	
	wood_label.text = str(resource_manager.wood)
	wood_income_label.text = "(+" + str(resource_manager.current_wood_income) + ")"
	
	stone_label.text = str(resource_manager.stone)
	stone_income_label.text = "(+" + str(resource_manager.current_stone_income) + ")"
	
	food_label.text = str(resource_manager.food)
	food_income_label.text = "(+" + str(resource_manager.current_food_income) + ")"
