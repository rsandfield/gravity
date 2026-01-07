@tool
class_name TorusGravity
extends Gravity

## Distance from the tube center to the center point
@export var major_radius: float = 1:
	set(value):
		major_radius = value
		# Clamp minor and peak radius if they exceed half of major
		if minor_radius > major_radius:
			minor_radius = major_radius
		if peak_radius > major_radius:
			peak_radius = major_radius
		changed.emit()
	get:
		return major_radius

## Radius of the tube circling the center point
@export var minor_radius: float = .25:
	set(value):
		minor_radius = value if value <= major_radius else major_radius
		changed.emit()
	get:
		return minor_radius

@export var peak_radius: float = 0:
	set(value):
		peak_radius = value if value <= major_radius else major_radius
		changed.emit()
	get:
		return peak_radius

## The radius at which gravity is equal to the set value.
## When positive, the value will weaken exponentially with absolute difference from this radius.
## When non-positive, acceleration will be constant throughout the area.
@export var hollow_radius: float = 0:
	set(value):
		hollow_radius = value if value <= major_radius else major_radius
		changed.emit()
	get:
		return hollow_radius

## Strength of acceleration applied to physics bodies within the area
@export var gravity: float = 9.81:
	set(value):
		gravity = value
		changed.emit()

## When true, gravity will be inverted and push away from the center.
@export var invert: bool = false:
	set(value):
		invert = value
		changed.emit()


func get_gravity_at(position: Vector3) -> Vector3:
	# Flatten the point to the reference plane
	var flattened = position
	flattened.y = 0
	var horizontal_dist = flattened.length()

	# If at the center, no well-defined gravity direction
	if is_zero_approx(horizontal_dist):
		return Vector3.ZERO

	flattened = flattened.normalized() * major_radius

	var offset = position - flattened
	var distance = offset.length()
	if is_zero_approx(distance) || distance > minor_radius || distance < hollow_radius - 0.01:
		return Vector3.ZERO

	var base_vector = -offset.normalized() * gravity
	if invert:
		base_vector *= -1
	if peak_radius <= 0:
		# constant strength
		return base_vector

	if distance > peak_radius:
		return base_vector * (peak_radius ** 2) / (distance ** 2)
	return base_vector * (distance ** 2) / (peak_radius ** 2)


func is_within_influence(position: Vector3) -> bool:
	if !shrink_fit:
		return true

	# Flatten the point to the reference plane
	var flattened = position
	flattened.y = 0
	var horizontal_dist = flattened.length()

	# If at the center, not within influence
	if is_zero_approx(horizontal_dist):
		return false

	flattened = flattened.normalized() * major_radius

	var offset = position - flattened
	var distance = offset.length()

	# Must be within the torus tube (minor_radius)
	return distance <= minor_radius && distance >= hollow_radius
