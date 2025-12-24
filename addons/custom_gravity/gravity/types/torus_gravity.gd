@tool
class_name TorusGravity
extends Gravity

var _major_radius: float = 1
var _minor_radius: float = 0.25
var _peak_radius: float = 0.25

## Distance from the tube center to the center point
@export var major_radius: float:
	set(value):
		_major_radius = value
		if _minor_radius > _major_radius * 0.5:
			_minor_radius = _major_radius * 0.5
	get:
		return _major_radius
## Radius of the tube circling the center point
@export var minor_radius: float:
	set(value):
		_minor_radius = value
		if _minor_radius > _major_radius * 0.5:
			_major_radius = _minor_radius * 2
	get:
		return _minor_radius
@export var peak_radius: float:
	set(value):
		if value > _major_radius * 0.5:
			value = _major_radius * 0.5
		_peak_radius = value
## Strength of acceleration applied to physics bodies within the area
@export var gravity: float = 9.81
## When true, gravity will be inverted and push away from the center.
@export var invert: bool = false


func get_gravity_at(position: Vector3) -> Vector3:
	# Flatten the point to the reference plane
	var flattened = position
	flattened.y = 0
	flattened = flattened.normalized() * _major_radius

	var offset = position - flattened
	if offset.length() > _minor_radius:
		return Vector3.ZERO

	var base_vector = -offset.normalized() * gravity
	if invert:
		base_vector *= -1

	if _peak_radius <= 0:
		# constant strength
		return base_vector

	if offset.length() > peak_radius:
		return (
			base_vector *
			peak_radius ** 2 /
			offset.length_squared()
		)
	return (
		base_vector *
		offset.length_squared() /
		peak_radius ** 2
	)
	
