extends Node

const SWITCH_COOLDOWN_FRAMES: int = 3
const AREA_REMOVAL_DELAY_FRAMES: int = 10  # Grace period for boundary flickering

class BodyTracker:
	var active_area: GravityArea3D
	var areas: Array[GravityArea3D] = []
	var _to_erase: Dictionary[GravityArea3D, int] = {}
	var last_switch_frame: int = 0

	func update():
		var expired = []
		for area in _to_erase:
			_to_erase[area] -= 1
			if _to_erase[area] <= 0:
				expired.append(area)
		for area in expired:
			areas.erase(area)
			_to_erase.erase(area)

	func get_areas() -> Array[GravityArea3D]:
		return areas.duplicate()
	
	func is_last_dominant_area(area: GravityArea3D) -> bool:
		return area == active_area

	func append(area: GravityArea3D):
		var was_pending_erase = _to_erase.has(area)
		_to_erase.erase(area)

		if !areas.has(area):
			areas.append(area)
		elif !was_pending_erase:
			# Only move to end if it wasn't a rapid re-entry
			# This prevents flickering from constant re-prioritization
			areas.erase(area)
			areas.append(area)

	func erase(area: GravityArea3D) -> bool:
		# Only reset timer if not already pending erase, otherwise let it count down
		if !_to_erase.has(area):
			_to_erase[area] = AREA_REMOVAL_DELAY_FRAMES

		return areas.size() == _to_erase.size()
	
	func find(area: GravityArea3D) -> int:
		return areas.find(area)
	
	func pending_removal(area: GravityArea3D) -> bool:
		return _to_erase.has(area)

	func can_switch(current_frame: int) -> bool:
		return current_frame - last_switch_frame >= SWITCH_COOLDOWN_FRAMES


var areas: Dictionary[GravityArea3D, Array] = {}
var bodies: Dictionary[PhysicsBody3D, BodyTracker] = {}

func _physics_process(delta):
	for body in bodies:
		if body is RigidBody3D:
			body.linear_velocity += get_gravity(body) * delta
		bodies[body].update()

func get_gravity(body: PhysicsBody3D):
	# https://github.com/godotengine/godot/blob/63227bbc8ae5300319f14f8253c8158b846f355b/modules/godot_physics_3d/godot_body_3d.cpp#L497
	if !bodies.has(body):
		return Vector3.ZERO
	
	var total_gravity = Vector3.ZERO

	# Sort areas by priority, preserving seniority within each priority.
	var tracker = bodies[body]
	var body_areas = tracker.get_areas()
	body_areas.sort_custom(func(a, b):
		# When priority is equal, prefer the currently active area first,
		# then fall back to most recently entered
		if a.priority == b.priority:
			if tracker.is_last_dominant_area(a):
				return true
			if tracker.is_last_dominant_area(b):
				return false
			return tracker.find(a) > tracker.find(b)
		return a.priority > b.priority
	)

	var previous_area = tracker.active_area
	var current_frame = Engine.get_physics_frames()

	tracker.active_area = null
	for area in body_areas:
		var within_influence = area.is_within_influence(body.global_transform)

		# Skip if not within influence, unless it's pending removal (grace period)
		if !within_influence && !tracker.pending_removal(area):
			continue

		var area_gravity = area.get_gravity_at(body.global_transform)
		match area.gravity_space_override:
			Area3D.SPACE_OVERRIDE_COMBINE:
				total_gravity += area_gravity
			Area3D.SPACE_OVERRIDE_REPLACE:
				total_gravity = area_gravity
				# Only switch active area if cooldown has passed or it's the same area
				if tracker.can_switch(current_frame) || area == previous_area:
					tracker.active_area = area
				else:
					# Keep previous area during cooldown
					tracker.active_area = previous_area
				break
			Area3D.SPACE_OVERRIDE_REPLACE_COMBINE:
				total_gravity = area_gravity
			Area3D.SPACE_OVERRIDE_COMBINE_REPLACE:
				total_gravity += area_gravity
				break

	if tracker.active_area != previous_area:
		tracker.last_switch_frame = current_frame
		var area_name = tracker.active_area.name if tracker.active_area else "none"
		print("%s primary gravity is now %s" % [body.name, area_name])

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
	if body is StaticBody3D:
		return
	if !areas[area].has(body):
		areas[area].append(body)
	if !bodies.has(body):
		bodies[body] = BodyTracker.new()
	bodies[body].append(area)
	print("%s has entered %s" % [body.name, area.name])

func body_exited_area(body: PhysicsBody3D, area: GravityArea3D):
	if areas.has(area):
		areas[area].erase(body)

	_remove_body_area(body, area)
	print("%s has exited %s" % [body.name, area.name])
