extends Camera2D

var cam_zoom = Vector2(2, 2)
var og_cam_zoom = Vector2(1.5, 1.5)
var start_pos = Vector2(140, 0)

func _ready() -> void:
	zoom = og_cam_zoom
	position = start_pos
	Events.camera_movement_start.connect(moving_birds)
	Events.camera_after_anim.connect(restoring_camera_pos)
	Events.exhausted_tiles.connect(next_part)

func moving_birds(bird_pos: Vector2):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position", bird_pos, 1)
	tween.parallel().tween_property(self, "zoom", cam_zoom, 1)
	tween.finished.connect(Events.camera_movement_stop.emit)

func restoring_camera_pos():
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "position", start_pos, 1)
	tween.parallel().tween_property(self, "zoom", og_cam_zoom, 1)
	tween.finished.connect(Events.camera_after_anim_finish.emit)

func next_part(part: int):
	start_pos = start_pos + Vector2(860, 0)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", start_pos, 1)
	
