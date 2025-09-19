extends TileMapLayer
class_name HighlightTile

var current_highlight_cell: Vector2i = Vector2i(-1, -1)
var previous_cell: Vector2i = Vector2i(-1, -1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	pass

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var cell_coords = local_to_map(mouse_pos)
	
	# Only update if we moved to a different cell
	if cell_coords != previous_cell:
		_highlight_cell(cell_coords)
		previous_cell = cell_coords

func _highlight_cell(cell_coords: Vector2i) -> void:
	# Remove previous highlight first
	_remove_highlight()
	
	# Highlight any cell, not just used ones
	set_cell(cell_coords, 0, Vector2i(1, 1))
	current_highlight_cell = cell_coords

func _remove_highlight() -> void:
	if current_highlight_cell != Vector2i(-1, -1):
		erase_cell(current_highlight_cell)
		current_highlight_cell = Vector2i(-1, -1)

# Optional: Handle mouse leaving the game window
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			_remove_highlight()
			previous_cell = Vector2i(-1, -1)
