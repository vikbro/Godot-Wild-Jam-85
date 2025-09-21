extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewportContainer.hide()
	Events.roll_dice.connect(_on_dice_roll_start)
	Events.roll_finished.connect(_on_dice_rolL_finish)
	#Events.exhausted_tiles.connect(_show_end_week_menu)
	pass # Replace with function body.

func _on_dice_roll_start() -> void:
	$SubViewportContainer.show()

func _on_dice_rolL_finish(result:int) -> void:
	$SubViewportContainer.hide()
	

func _show_end_week_menu() -> void:
	var scene_instance = load("res://scenes/UI/end_week_menu.tscn").instantiate()
	add_child(scene_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MENU.tscn")
