@tool
class_name PointGravity
extends Gravity

## The offset from node position for the gravity point source
@export var center: Vector3 = Vector3.ZERO:
	set(value):
		center = value
		changed.emit()

## Strength of acceleration applied to physics bodies within the area
@export var gravity: float = 9.81:
	set(value):
		gravity = value
		changed.emit()

## The radius at which gravity is equal to the set value.
## When positive, the value will weaken exponentially with absolute difference from this radius.
## When non-positive, acceleration will be constant throughout the area.
@export var peak_radius: float = 1:
	set(value):
		peak_radius = value
		changed.emit()

## When positive, gravity will not be applied to objects within this radius.
@export var hollow_radius: float = 0:
	set(value):
		hollow_radius = value
		changed.emit()

## When true, gravity will be inverted and push away from the center.
@export var invert: bool = false:
	set(value):
		invert = value
		changed.emit()


func get_gravity_at(position: Vector3) -> Vector3:
	var offset = center - position
	var base_vector = offset.normalized() * gravity
	if invert:
		base_vector *= -1
	if offset.length() < hollow_radius:
		return Vector3.ZERO
	if peak_radius <= 0:
		# constant strength
		return base_vector

	if offset.length() > peak_radius:
		return base_vector * peak_radius ** 2 / offset.length_squared()
	return base_vector * offset.length_squared() / peak_radius ** 2
