extends Node

var placement_enabled: bool = true

var avaliable_tiles: int = 10
var roll_amount: int = 0
var current_part: int = 1

var has_clicked_tile: bool = false
var has_clicked_water: bool = false
var has_melted_tile: bool = false
var has_frozen_water: bool = false
var birds_have_flown: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_tile_placement.connect(decrease_avaliable_tiles)
	Events.on_tile_melted.connect(_on_tile_melting)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	Dialogic.timeline_started.connect(Events.timeline_started.emit)
	Dialogic.timeline_ended.connect(Events.timeline_ended.emit)
	Events.roll_finished.connect(_on_finished_roll_dice)
	
	Events.stop_placement.connect(_on_stop_input)
	Events.start_placement.connect(_on_start_input)
func _on_dialogic_signal(argument:String):
	if argument == "higlight_tile_ui":
		Events.higlight_tile_ui.emit()
		print("Something was activated!")
	pass # Replace with function body.

func _on_stop_input() -> void:
	placement_enabled = false

func _on_start_input() -> void:
	placement_enabled = true
func _on_tile_melting() -> void:
	has_melted_tile = true
	Dialogic.start("Melting")
	
func _on_finished_roll_dice(value:int )->void:
	roll_amount += 1
	avaliable_tiles += value*2
	placement_enabled = false


func decrease_avaliable_tiles(amount : int = 1) -> void:
	avaliable_tiles -= 1
	
	if has_clicked_tile == false:
		has_clicked_tile = true

	if avaliable_tiles <= 0:
		Events.stop_placement.emit()
		pass
		
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Roll_DEBUG"):
		Events.roll_dice.emit()
		
	pass
