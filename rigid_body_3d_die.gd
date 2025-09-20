extends RigidBody3D

@onready var raycasts = $RayCasts.get_children()

var start_pos
var roll_strength = 50

var is_rolling = false

signal roll_finished(value)

func _ready():
	start_pos = global_position
	sleeping = true
	freeze = true
	
#func _input(event):
	#if event.is_action_pressed("ui_accept"):
		#_roll()

func _roll():
	sleeping = false
	freeze = false
	transform.origin = start_pos
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis
	
	var throw_vector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)). normalized()
	angular_velocity = throw_vector * Vector3.ONE * roll_strength / 2
	apply_central_impulse(throw_vector * roll_strength)

	is_rolling = true

func _on_sleeping_state_changed() -> void:
	if sleeping:
		var land_side = false
		for raycast in raycasts:
			if raycast.is_colliding():
				Events.roll_finished.emit(raycast.opposite_side)
				roll_finished.emit(raycast.opposite_side)
				is_rolling = false
				land_side = true
				freeze = true
				sleeping = true
		if !land_side:
			_roll()
