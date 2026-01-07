@tool
class_name CylinderGravity
extends Gravity

## Reference point to define center line of cylinder
@export var point_a: Vector3 = Vector3.UP:
	set(value):
		point_a = value
		changed.emit()

## Reference point to define center line of cylinder
@export var point_b: Vector3 = Vector3.DOWN:
	set(value):
		point_b = value
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


func _within_hollow_core(distance: float) -> bool:
	return hollow_radius > 0 && distance < hollow_radius - 0.01


func get_gravity_at(position: Vector3) -> Vector3:
	var closest_point = Geometry3D.get_closest_point_to_segment_uncapped(position, point_a, point_b)
	var offset = closest_point - position
	var distance = offset.length()
	if is_zero_approx(distance):
		return Vector3.ZERO

	if _within_hollow_core(distance):
		return Vector3.ZERO

	var base_vector = offset.normalized() * gravity
	if invert:
		base_vector *= -1
	if peak_radius <= 0:
		return base_vector
	if distance > peak_radius:
		return base_vector * (peak_radius ** 2) / (distance ** 2)
	return base_vector * (distance ** 2) / (peak_radius ** 2)


func is_within_influence(position: Vector3) -> bool:
	if !shrink_fit:
		return true

	var closest_point = Geometry3D.get_closest_point_to_segment_uncapped(position, point_a, point_b)
	var offset = closest_point - position
	var distance = offset.length()

	return !_within_hollow_core(distance)
