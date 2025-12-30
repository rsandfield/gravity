extends Node

class BodyTracker:
	var active_area: GravityArea3D
	var areas: Array[GravityArea3D] = []

	func get_areas() -> Array[GravityArea3D]:
		return areas.duplicate()

	func append(area: GravityArea3D):
		areas.append(area)

	func erase(area: GravityArea3D) -> bool:
		areas.erase(area)
		return areas.is_empty()
	
	func find(area: GravityArea3D) -> int:
		return areas.find(area)


var areas: Dictionary[GravityArea3D, Array] = {}
var bodies: Dictionary[PhysicsBody3D, BodyTracker] = {}

func _physics_process(delta):
	for body in bodies:
		if body is RigidBody3D:
			body.linear_velocity += get_gravity(body) * delta

func get_gravity(body: PhysicsBody3D):
	# https://github.com/godotengine/godot/blob/63227bbc8ae5300319f14f8253c8158b846f355b/modules/godot_physics_3d/godot_body_3d.cpp#L497
	if !bodies.has(body):
		return Vector3.ZERO
	
	var total_gravity = Vector3.ZERO

	# Sort areas by priority, preserving seniority within each priority.
	var tracker = bodies[body]
	var body_areas = tracker.get_areas()
	body_areas.sort_custom(func(a, b):
		# When priority is equal, return the newest entry
		if a.priority == b.priority:
			return tracker.find(a) > tracker.find(b)
		return a.priority > b.priority
	)

	for area in body_areas:
		# area.gravity_mode
		var area_gravity = area.get_gravity_at(body.global_transform)
		match area.gravity_mode:
			Gravity.Mode.COMBINE:
				total_gravity += area_gravity
			Gravity.Mode.REPLACE:
				total_gravity = area_gravity
				break
			Gravity.Mode.REPLACE_COMBINE:
				total_gravity = area_gravity
			Gravity.Mode.COMBINE_REPLACE:
				total_gravity += area_gravity
				break
	
	return total_gravity

func _remove_body_area(body: PhysicsBody3D, area: GravityArea3D):
	if bodies.has(body):
		if bodies[body].erase(area):
			bodies.erase(body)

func register_gravity_area(area: GravityArea3D):
	areas[area] = []

func deregister_gravity_area(area: GravityArea3D):
	for body in areas[area]:
		_remove_body_area(body, area)
	areas.erase(area)

func body_entered_area(body: PhysicsBody3D, area: GravityArea3D):
	if !areas[area].has(body):
		areas[area].append(body)
		if !bodies.has(body):
			bodies[body] = BodyTracker.new()
		bodies[body].append(area)

func body_exited_area(body: PhysicsBody3D, area: GravityArea3D):
	if areas.has(area):
		areas[area].erase(body)
	_remove_body_area(body, area)
