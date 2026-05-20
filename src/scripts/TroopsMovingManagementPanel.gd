# TroopsMovingManagementPanel.gd
# Displays a real-time table of moving troops with headers and ETA countdown.

extends Panel
class_name TroopsMovingManagementPanel

@onready var troop_manager: TroopMovementManager
var rows: Dictionary = {}
var data_grid: GridContainer

func init(manager: TroopMovementManager):
	troop_manager = manager
	size = Vector2(280, 250) # Wider for table layout
	position = Vector2(10, 10)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var title = Label.new()
	title.text = "Troop Movement"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(280, 30)
	add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(0, 30)
	scroll.size = Vector2(280, 220)
	add_child(scroll)
	
	# Use GridContainer for table alignment (4 columns: ID, From, To, ETA)
	data_grid = GridContainer.new()
	data_grid.columns = 4
	scroll.add_child(data_grid)
	
	_create_header()

func _create_header():
	var headers = ["ID", "From", "To", "ETA"]
	for h in headers:
		var lbl = Label.new()
		lbl.text = h
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		data_grid.add_child(lbl)

func _process(_delta):
	if not troop_manager: return
	
	var active_ids = []
	for t in troop_manager.troops:
		if t.is_moving:
			active_ids.append(t.id)
			if not rows.has(t.id):
				_create_row(t.id, t.get("start_tile", t.current_tile), t.target_tile)
			_update_row(t.id, t)
			
	for id in rows.keys():
		if not active_ids.has(id):
			_remove_row(id)

func _create_row(id: int, start: Vector2i, target: Vector2i):
	var row_data = {
		"id": Label.new(),
		"from": Label.new(),
		"to": Label.new(),
		"time": Label.new()
	}
	
	row_data["id"].text = str(id)
	row_data["from"].text = "(%d,%d)" % [start.x, start.y]
	row_data["to"].text = "(%d,%d)" % [target.x, target.y]
	row_data["time"].text = "--"
	row_data["time"].name = "TimeLabel"
	
	for lbl in row_data.values():
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		data_grid.add_child(lbl)
		
	rows[id] = row_data

func _update_row(id: int, troop_data: Dictionary):
	if not rows.has(id): return
	var row = rows[id]
	var lbl_time = row["time"]
	if lbl_time and troop_manager:
		var target_pos = Vector2(troop_data.target_tile.x * 64 + 32, troop_data.target_tile.y * 64 + 32)
		var dist_px = troop_data.visual.global_position.distance_to(target_pos)
		var remaining = dist_px / troop_data.speed
		lbl_time.text = "%.1f" % remaining

func _remove_row(id: int):
	if not rows.has(id): return
	var row = rows[id]
	for lbl in row.values():
		lbl.queue_free()
	rows.erase(id)
