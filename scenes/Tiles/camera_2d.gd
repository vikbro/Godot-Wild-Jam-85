extends Camera2D

var cam_zoom = Vector2(1.3, 1.3)
var og_cam_zoom = zoom

func _ready() -> void:
	position = global_position
	Events.camera_movement_start.connect(moving_birds)
	Events.camera_after_anim.connect(restoring_camera_pos)

func moving_birds(bird_pos: Vector2):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position", bird_pos, 1)
	tween.parallel().tween_property(self, "zoom", cam_zoom, 1)
	tween.finished.connect(Events.camera_movement_stop.emit)

func restoring_camera_pos():
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position", global_position, 1)
	tween.parallel().tween_property(self, "zoom", og_cam_zoom, 1)
	tween.finished.connect(Events.camera_after_anim_finish.emit)
