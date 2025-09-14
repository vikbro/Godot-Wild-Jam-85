extends Control


@onready var tile_amount: Label = $HBoxContainer/Panel/TileAmount


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_tile_amount()
	Events.on_tile_placement.connect(_update_tile_amount)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _update_tile_amount() -> void:
	tile_amount.text = str(GameManager.avaliable_tiles)
	
