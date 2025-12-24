@tool
class_name LinearGravity
extends Gravity

## Direction and strength of gravitational accelaration within the area
@export var acceleration: Vector3 = Vector3.DOWN * 9.81


func get_gravity_at(_position: Vector3) -> Vector3:
	return acceleration
