extends Node2D

@onready var ambience: AudioStreamPlayer2D = $Ambience


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.on_tile_placement.connect($WindPlacement.play)
	Events.on_tile_melted.connect($TileMelt.play)
	ambience.stream = load("res://Sound/lovely-winter-63497.mp3")
	ambience.stream.loop = true
	ambience.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
