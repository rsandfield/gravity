@tool
class_name CylinderGravity
extends Gravity

## Reference point to define center line of cylinder
@export var point_a: Vector3 = Vector3.UP
## Reference point to define center line of cylinder
@export var point_b: Vector3 = Vector3.DOWN
## Strength of acceleration applied to physics bodies within the area
@export var gravity: float = 9.81
## The radius at which gravity is equal to the set value.
## When positive, the value will weaken exponentially with absolute difference from this radius.
## When non-positive, acceleration will be constant throughout the area.
@export var peak_radius: float = 1
## When positive, gravity will not be applied to objects within this radius.
@export var hollow_radius: float = 0
## When true, gravity will be inverted and push away from the center.
@export var invert: bool = false


func get_gravity_at(position: Vector3) -> Vector3:
	var closest_point = Geometry3D.get_closest_point_to_segment_uncapped(position, point_a, point_b)
	var offset = closest_point - position
	var base_vector = offset.normalized() * gravity
	if invert:
		base_vector *= -1
	if offset.length() < hollow_radius:
		return Vector3.ZERO
	if peak_radius <= 0:
		# constant strength
		return base_vector

	return base_vector * (offset.length_squared() - peak_radius) / (peak_radius ** 0.5)
