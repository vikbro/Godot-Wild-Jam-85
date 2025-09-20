extends Control

@onready var tile_amount: Label = $Panel/HBoxContainer/TileAmount
@onready var texture_rect: TextureRect = $Panel/HBoxContainer/TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_tile_amount()
	Events.on_tile_placement.connect(_update_tile_amount)
	Events.on_tile_hover.connect(_on_hover)
	Events.higlight_tile_ui.connect(_highlight_tile_amount)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _highlight_tile_amount() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.set_loops(4)  # Loop infinitely :cite[1]:cite[2]
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)  # Fade out
	tween.chain().tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)  # Fade in :cite[1]


func _on_hover(texture : Texture) -> void:
	texture_rect.texture = texture
	
func _update_tile_amount() -> void:
	tile_amount.text = str(GameManager.avaliable_tiles)
	
