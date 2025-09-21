extends Node2D

@onready var music: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var button: Button = $Control/Button

func _ready():
	music.stream = load("res://Sound/lovely-winter-63497.mp3")
	music.stream.loop = true
	music.play()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Levels/map.tscn")
	
