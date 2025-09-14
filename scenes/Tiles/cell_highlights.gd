extends TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

var used_cells : Array[Vector2i]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	used_cells = get_used_cells()
	
#if !used_cells.has(local_to_map(get_global_mouse_position())):
	var mouse_pos = get_global_mouse_position()
	var cell_coords = self.local_to_map(get_global_mouse_position())
	_on_tile_controller_highlight_cell(cell_coords)

	
func _input(event: InputEvent) -> void:
	
	pass


func _on_tile_controller_highlight_cell(cell_coords: Vector2i) -> void:
	if !used_cells.has(cell_coords):
		self.set_cell(cell_coords,2,Vector2i(1,1))

		await get_tree().create_timer(1).timeout
		
		self.erase_cell(cell_coords)
	
	pass # Replace with function body.
