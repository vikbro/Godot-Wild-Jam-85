extends Node2D
class_name PlaceholderInteractable

@export var animation_duration : float = 2.0

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var fall_sprite: Sprite2D = $FallSprite
@onready var winter_sprite: Sprite2D = $WinterSprite
@onready var alien_beige: Sprite2D = $AlienBeige

var tile_coords : Vector2i
var birds = bool (true)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#interact()
	audio_stream_player.stream = load("res://Sound/pigeons-flying-6351.mp3")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("left_click"):
		#Events.camera_movement_stop.emit()
	pass

func interact() -> void:
	#await Events.camera_movement_stop
	
	audio_stream_player.play()
	var tween:Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(alien_beige,"self_modulate:a",0,animation_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(alien_beige,"position",Vector2(100,-100),animation_duration)
	tween.finished.connect(Events.camera_after_anim.emit)
	#Events.start_placement.emit()

	pass
