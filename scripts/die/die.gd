extends RigidBody3D

var start_pos
var roll_strength = 30

signal roll_finished(value)

func ready():
	start_pos=global_position
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		_roll()

func _roll():
	var sleeping = false
	var freezing = false
	transform.origin = start_pos
	var linear_velocity = Vector3.ZERO
	var angular_velocity = Vector3.ZERO
	
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis

	var throw_vector = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)). normalized()
	angular_velocity = throw_vector * roll_strength / 2
	apply_central_impulse(Vector3(0, 0, 0))
