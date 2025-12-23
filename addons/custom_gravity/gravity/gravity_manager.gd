extends Node

var areas: Dictionary[GravityArea3D, Array] = {}
var bodies: Dictionary[PhysicsBody3D, Array] = {}

func _physics_process(delta):
	for body in bodies:
		if body is RigidBody3D:
			for area in bodies[body]:
				body.linear_velocity += area.get_gravity_at(body.transform) * delta

func register_gravity_area(area: GravityArea3D):
	areas[area] = []

func deregister_gravity_area(area: GravityArea3D):
	for body in areas[area]:
		body.erase(area)
	areas.erase(area)

func body_entered_area(body: PhysicsBody3D, area: GravityArea3D):
	if !areas[area].has(body):
		areas[area].append(body)
		if !bodies.has(body):
			bodies[body] = []
		bodies[body].append(area)

func body_exited_area(body: PhysicsBody3D, area: GravityArea3D):
	areas[area].erase(body)
	bodies[body].erase(area)
