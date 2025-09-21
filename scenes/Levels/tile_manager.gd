extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.exhausted_tiles.connect(stop_input)
	Events.timeline_started.connect(stop_input)
	Events.timeline_ended.connect(start_input)
	
	Events.stop_placement.connect(stop_input)
	Events.start_placement.connect(start_input)

	pass # Replace with function body.

func stop_input() -> void:
	for child in get_children():
		child.set_process_input(false)
	print("Input processing disabled")

func start_input()->void:
	if GameManager.placement_enabled: 
		for child in get_children():
			child.set_process_input(true)
		print("Input processing enabled")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
