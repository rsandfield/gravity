@tool
@abstract
class_name Gravity
extends Resource

@export var shrink_fit: bool = false:
	set(value):
		shrink_fit = value
		changed.emit()

@abstract
func get_gravity_at(position: Vector3) -> Vector3

func is_within_influence(position: Vector3) -> bool:
	# By default just use the ColliderShape3D
	return true