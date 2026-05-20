# TroopSelectPanel.gd
# Panel to select multiple troops for an action.

extends Panel
class_name TroopSelectPanel

signal action_confirmed(troop_ids: Array, target_tile: Vector2i, is_attack: bool)
signal closed()

@onready var troop_manager: TroopMovementManager
var target_tile: Vector2i = Vector2i.ZERO
var is_attack_action: bool = false
var selected_ids: Array = []
var troop_buttons: Dictionary = {}
var troop_list_container: VBoxContainer

func init(manager: TroopMovementManager):
	troop_manager = manager
	if troop_manager == null:
		push_error("TroopSelectPanel: troop_manager is null in init()!")
		
	size = Vector2(250, 300)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Add solid background to catch clicks
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95) # Dark gray, almost opaque
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	add_theme_stylebox_override("panel", style)
	
	var title = Label.new()
	title.text = "Select Troops"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(250, 30)
	add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(0, 30)
	scroll.size = Vector2(250, 230)
	add_child(scroll)
	
	# Store reference to container
	troop_list_container = VBoxContainer.new()
	troop_list_container.name = "TroopList"
	scroll.add_child(troop_list_container)
	
	var confirm_btn = Button.new()
	confirm_btn.text = "Confirm Action"
	confirm_btn.position = Vector2(50, 265)
	confirm_btn.size = Vector2(150, 30)
	confirm_btn.pressed.connect(_on_confirm)
	add_child(confirm_btn)

func show_for(target: Vector2i, attack: bool, screen_pos: Vector2, vp_size: Vector2):
	target_tile = target
	is_attack_action = attack
	selected_ids.clear()
	troop_buttons.clear()
	
	if troop_manager == null:
		print("TroopSelectPanel: ERROR - troop_manager reference is lost!")
		return
		
	print("TroopSelectPanel: Populating troops. Total in manager: ", troop_manager.troops.size())
	
	if troop_list_container:
		# Clear previous buttons
		for child in troop_list_container.get_children():
			child.queue_free()
			
		var count = 0
		for t in troop_manager.troops:
			if t.is_moving: continue
			
			count += 1
			var dist = troop_manager.get_distance_in_tiles(t.current_tile, target_tile)
			var eta = troop_manager.calculate_movement_time(dist, t.speed)
			
			var btn = Button.new()
			btn.text = "Troop %d [%d tiles, %.1fs]" % [t.id, dist, eta]
			btn.toggle_mode = true
			btn.pressed.connect(_on_troop_toggle.bind(t.id, btn))
			troop_list_container.add_child(btn)
			troop_buttons[t.id] = btn
			
		print("TroopSelectPanel: Added ", count, " available troops to list.")
	else:
		print("TroopSelectPanel: ERROR - TroopList container reference is null!")
		
	position = Vector2(
		clamp(screen_pos.x + 15, 0, vp_size.x - size.x),
		clamp(screen_pos.y + 15, 0, vp_size.y - size.y)
	)
	visible = true

func _on_troop_toggle(id: int, btn: Button):
	if btn.button_pressed:
		if not selected_ids.has(id):
			selected_ids.append(id)
	else:
		selected_ids.erase(id)

func _on_confirm():
	if selected_ids.size() > 0:
		action_confirmed.emit(selected_ids, target_tile, is_attack_action)
	closed.emit()
	visible = false

func _input(event):
	if visible and event is InputEventMouseButton and event.pressed:
		var local_pos = get_local_mouse_position()
		if not Rect2(Vector2.ZERO, size).has_point(local_pos):
			closed.emit()
			visible = false
