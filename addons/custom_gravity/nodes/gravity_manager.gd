extends Node

var areas: Dictionary[GravityArea3D, Array] = {}
var bodies: Dictionary[PhysicsBody3D, Array] = {}

func _physics_process(delta):
	for body in bodies:
		if body is RigidBody3D:
			body.linear_velocity += get_gravity(body) * delta

func get_gravity(body: PhysicsBody3D):
	if !bodies.has(body):
		return Vector3.ZERO
	
	var total_gravity = Vector3.ZERO

	for area in bodies[body]:
		total_gravity += area.get_gravity_at(body.transform)
	
	return total_gravity

func _remove_body_area(body: PhysicsBody3D, area: GravityArea3D):
	if bodies.has(body):
		bodies[body].erase(area)
		if bodies[body].is_empty():
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
			bodies[body] = []
		bodies[body].append(area)

func body_exited_area(body: PhysicsBody3D, area: GravityArea3D):
	if areas.has(area):
		areas[area].erase(body)
	_remove_body_area(body, area)
