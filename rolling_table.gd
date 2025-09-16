extends Node3D

@onready var rigid_body_3d: RigidBody3D = $RigidBody3D
@onready var result_label = $CanvasLayer/ResultLabel

func _on_rigid_body_3d_roll_finished(value: Variant) -> void:
	result_label.text = str(value)

func _on_button_pressed() -> void:
	rigid_body_3d._roll()
