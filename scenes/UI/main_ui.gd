extends Control

@onready var tile_amount: Label = $Panel/HBoxContainer/TileAmount
@onready var texture_rect: TextureRect = $Panel/HBoxContainer/TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_tile_amount()
	Events.on_tile_placement.connect(_update_tile_amount)
	Events.on_tile_hover.connect(_on_hover)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hover(texture : Texture) -> void:
	texture_rect.texture = texture
	
func _update_tile_amount() -> void:
	tile_amount.text = str(GameManager.avaliable_tiles)
	
