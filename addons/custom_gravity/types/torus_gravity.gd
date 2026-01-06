@tool
class_name TorusGravity
extends Gravity

var _major_radius: float = 1
var _minor_radius: float = 0.25
var _peak_radius: float = 0
var _hollow_radius: float = 0

## Distance from the tube center to the center point
@export var major_radius: float = _major_radius:
	set(value):
		_major_radius = value
		# Clamp minor and peak radius if they exceed half of major
		if _minor_radius > _major_radius:
			_minor_radius = _major_radius
		if _peak_radius > _major_radius:
			_peak_radius = _major_radius
	get:
		return _major_radius
## Radius of the tube circling the center point
@export var minor_radius: float = _minor_radius:
	set(value):
		_minor_radius = value if value <= _major_radius else _major_radius
	get:
		return _minor_radius
@export var peak_radius: float = 0:
	set(value):
		_peak_radius = value if value <= _major_radius else _major_radius
	get:
		return _peak_radius
## The radius at which gravity is equal to the set value.
## When positive, the value will weaken exponentially with absolute difference from this radius.
## When non-positive, acceleration will be constant throughout the area.
@export var hollow_radius: float = _hollow_radius:
	set(value):
		_hollow_radius = value if value <= _major_radius else _major_radius
	get:
		return _hollow_radius
## Strength of acceleration applied to physics bodies within the area
@export var gravity: float = 9.81
## When true, gravity will be inverted and push away from the center.
@export var invert: bool = false


func get_gravity_at(position: Vector3) -> Vector3:
	# Flatten the point to the reference plane
	var flattened = position
	flattened.y = 0
	var horizontal_dist = flattened.length()

	# If at the center, no well-defined gravity direction
	if is_zero_approx(horizontal_dist):
		return Vector3.ZERO

	flattened = flattened.normalized() * _major_radius

	var offset = position - flattened
	var distance = offset.length()
	if is_zero_approx(distance) || distance > _minor_radius || distance < _hollow_radius - 0.01:
		return Vector3.ZERO

	var base_vector = -offset.normalized() * gravity
	if invert:
		base_vector *= -1
	if _peak_radius <= 0:
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

	flattened = flattened.normalized() * _major_radius

	var offset = position - flattened
	var distance = offset.length()

	# Must be within the torus tube (minor_radius)
	return distance <= _minor_radius && distance >= _hollow_radius
