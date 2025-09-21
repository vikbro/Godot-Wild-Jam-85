extends Control

@onready var tile_amount: Label = $Panel/HBoxContainer/TileAmount
@onready var texture_rect: TextureRect = $Panel/HBoxContainer/TextureRect
@onready var progress_bar: ProgressBar = $Panel/HBoxContainer/ProgressBar
@onready var rolls_2: Label = $Panel/HBoxContainer/Rolls2
@onready var button: Button = $Panel/HBoxContainer/Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_tile_amount()
	Events.on_tile_placement.connect(_update_tile_amount)
	Events.on_tile_hover.connect(_on_hover)
	Events.higlight_tile_ui.connect(_highlight_tile_amount)
	
	Events.roll_finished.connect(_update_tile_amount)
	Events.roll_finished.connect(_start_cooldown)
	Events.roll_finished.connect(_update_roll_amount)
	#Events.roll_finished.connect(_update_roll_amount)
	
	Events.start_placement.connect(_enable_btn)
	Events.stop_placement.connect(_disable_btn)
	
	Events.roll_finished.connect(_enable_btn)
	
	#_start_cooldown(6)
	pass # Replace with function body.

func _disable_btn() -> void:
	button.disabled = true

func _enable_btn() -> void:
	button.disabled = false

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start_cooldown(dice_value:int) -> void:
	progress_bar.max_value = dice_value
	progress_bar.value = 0
	var tween : Tween = get_tree().create_tween()
	Events.stop_placement.emit()
	GameManager.placement_enabled = false
	tween.tween_property(progress_bar,"value",dice_value,dice_value)
	tween.finished.connect(Events.start_placement.emit)
	pass

func _highlight_tile_amount() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.set_loops(4)  # Loop infinitely :cite[1]:cite[2]
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)  # Fade out
	tween.chain().tween_property(self, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)  # Fade in :cite[1]


func _on_hover(texture : Texture) -> void:
	texture_rect.texture = texture

#value is only used from dice
func _update_tile_amount(value:int= 0) -> void:
	tile_amount.text = str(GameManager.avaliable_tiles)
	
func _update_roll_amount(value:int = 0) -> void:
	rolls_2.text = str(GameManager.roll_amount)


func _on_button_pressed() -> void:
	Events.roll_dice.emit()
	_disable_btn()
	pass # Replace with function body.
