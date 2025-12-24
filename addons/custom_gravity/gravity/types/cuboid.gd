@tool
class_name CuboidGravity
extends Gravity

var _bounds: AABB = AABB(Vector3.ONE * -5, Vector3.ONE * 10)
var _depth: float = 4

## Size of the cuboid surface
@export var size: Vector3:
	set(value):
		_bounds.size = value
		_bounds.position = value * -0.5
		_validate_depth()
	get:
		return _bounds.size
## Depth of the gravity field away from the cuboid survace
@export var depth: float:
	set(value):
		_depth = value
		_validate_depth()
	get:
		return _depth
## Strength of acceleration applied to physics bodies within the area
@export var gravity: float = 9.81
## When true, gravity will be inverted and push away from the center.
@export var invert: bool = false


## When using invert mode, gravity depth cannot exceed the smallest dimension
func _validate_depth():
	if !invert:
		return
	var half_least_side = _bounds.get_shortest_axis_size() * 0.5
	if _depth < half_least_side:
		_depth = half_least_side


func _get_segment(position: Vector3) -> Vector3:
	# If inverted, the point should be inside. Otherwise, it should be outside.
	if invert != _bounds.has_point(position):
		return Vector3.ZERO
	
	var deepened = _bounds.grow(-depth if invert else depth)
	if !deepened.has_point(position):
		return Vector3.ZERO

	var center = _bounds.get_center()
	var grav_vec = Vector3.ZERO

	if position.x < _bounds.position.x:
		grav_vec.x = 1
	elif position.x > _bounds.size.x + _bounds.position.x:
		grav_vec.x = -1

	if position.y < _bounds.position.y:
		grav_vec.y = 1
	elif position.y > _bounds.size.y + _bounds.position.y:
		grav_vec.y = -1

	if position.z < _bounds.position.z:
		grav_vec.z = 1
	elif position.z > _bounds.size.z + _bounds.position.z:
		grav_vec.z = -1
	
	return grav_vec


func _get_edge_gravity(grav_vec: Vector3, position: Vector3) -> Vector3:
	# For edges, two axies will be 1. Making a new vector which only has a non-zero value on this
	# same axis will be tangential by definition
	var point_a = _bounds.end * grav_vec
	var point_b = point_a
	var min_axis = grav_vec.abs().min_axis_index()
	point_a[min_axis] = _bounds.end[min_axis]
	point_b[min_axis] = -_bounds.end[min_axis]
	
	var closest_point = Geometry3D.get_closest_point_to_segment_uncapped(position, point_a, point_b)
	var offset = closest_point - position
	return offset.normalized()


func _get_corner_gravity(grav_vec: Vector3, position) -> Vector3:
	var corner = _bounds.end * grav_vec
	var offset = corner - position
	return offset.normalized() * gravity


func _get_segment_gravity(grav_vec: Vector3, position: Vector3) -> Vector3:
	if grav_vec == Vector3.ZERO:
		return grav_vec

	if grav_vec.length_squared() == 1:
		return grav_vec

	if grav_vec.length_squared() == 2:
		return _get_edge_gravity(grav_vec, position)

	if grav_vec.length_squared() == 3:
		return _get_corner_gravity(grav_vec, position)
	
	return Vector3.ZERO



func get_gravity_at(position: Vector3) -> Vector3:
	var grav_vec = _get_segment(position)
	return _get_segment_gravity(grav_vec, position) * 9.81
	
