class_name GravityArea3DGizmo
extends EditorNode3DGizmo

var cone: CylinderMesh = CylinderMesh.new()
var _node: GravityArea3D

func _init_cone():
	cone.top_radius = 0
	cone.bottom_radius = 0.1
	cone.height = 0.4
	cone.radial_segments = 16


func _init():
	_init_cone()


func setup(node: GravityArea3D):
	if !node.child_entered_tree.is_connected(_on_child_added):
		node.child_entered_tree.connect(_on_child_added)
		print("connecting")
		node.property_list_changed.connect(_on_structure_changed)
	_node = node


func _on_child_added(_node):
	_on_structure_changed()


func _on_structure_changed():
	print("Changed")
	for child in _node.get_children():
		if child is CollisionShape3D:
			if !child.property_list_changed.is_connected(_on_structure_changed):
				child.property_list_changed.connect(_on_structure_changed)
				child.property_list_changed.connect(_node.update_gizmos)
			if child.shape:
				if !child.shape.changed.is_connected(_node.update_gizmos):
					child.shape.changed.connect(_node.update_gizmos)
	_node.update_gizmos()


func _is_point_in_shape(point: Vector3) -> bool:
	var query: PhysicsPointQueryParameters3D = PhysicsPointQueryParameters3D.new()
	query.position = point
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var direct_space_state = _node.get_world_3d().direct_space_state
	var results = direct_space_state.intersect_point(query)
	for overlap in results:
		if overlap.collider == _node:
			return true
	return false


func _draw_arrow(node: GravityArea3D, x: float, y: float, z: float):
	var pos = Vector3(x, y, z)
	var grav = node.gravity_resource.get_gravity_at(pos)

	if is_zero_approx(grav.length()):
		return

	var query = PhysicsPointQueryParameters3D.new()
	query.position = pos
	var results = node.get_world_3d().direct_space_state.intersect_point(query)
	
	if _is_point_in_shape(pos):
		var up_vec = Vector3.UP
		if is_equal_approx(abs(grav.normalized().dot(up_vec)), 1):
			up_vec = Vector3.RIGHT
		var basis = Basis.looking_at(grav, up_vec)
		var material = get_plugin().get_material("main", self)
		add_mesh(
			cone,
			material,
			Transform3D(basis, pos).rotated_local(Vector3.RIGHT, -PI * 0.5)
		)
		add_lines(
			[
				pos,
				pos - grav.normalized()
			],
			material
		)


func _redraw():
	clear()

	var shape = _node.shape.shape
	if !shape:
		return
	var debug_mesh = shape.get_debug_mesh()
	var bounds: AABB = debug_mesh.get_aabb()

	var x_step = bounds.size.x / floor(bounds.size.x / 3)
	var y_step = bounds.size.y / floor(bounds.size.y / 3)
	var z_step = bounds.size.z / floor(bounds.size.z / 3)

	var x = bounds.position.x + x_step * 0.5
	var y = bounds.position.y + y_step * 0.5
	var z = bounds.position.z + z_step * 0.5
	
	var lines = PackedVector3Array()
	while x <= bounds.end.x:
		while y <= bounds.end.y:
			while z <= bounds.end.z:
				_draw_arrow(_node, x, y, z)
				z += z_step
			z = bounds.position.z + z_step * 0.5
			y += y_step
			
		y = bounds.position.y + y_step * 0.5
		x += x_step
