extends Node

var avaliable_tiles: int = 100




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_tile_placement.connect(decrease_avaliable_tiles)
	pass # Replace with function body.


func decrease_avaliable_tiles(amount : int = 1) -> void:
	avaliable_tiles -= 1
	
	if avaliable_tiles <= 0:
		Events.exhausted_tiles.emit()
		
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
