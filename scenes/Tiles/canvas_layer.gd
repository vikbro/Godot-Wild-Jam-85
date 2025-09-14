extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.exhausted_tiles.connect(_show_end_week_menu)
	pass # Replace with function body.

func _show_end_week_menu() -> void:
	var scene_instance = load("res://scenes/UI/end_week_menu.tscn").instantiate()
	add_child(scene_instance)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
