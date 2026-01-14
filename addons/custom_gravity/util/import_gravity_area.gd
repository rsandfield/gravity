@tool
extends EditorScenePostImport

func _post_import(scene):
	# Find or create the root GravityArea3D
	var area3d = GravityArea3D.new()
	area3d.name = scene.name
	
	# Recursively find all StaticBody3D nodes
	var collision_shapes = []
	_collect_collision_shapes(scene, collision_shapes)
	
	# Reparent all CollisionShape3D nodes to the GravityArea3D
	for shape_data in collision_shapes:
		var shape = shape_data["shape"]
		var parent_name = shape_data["parent_name"]
		var parent = shape.get_parent()
		shape.owner = null  # Clear owner before reparenting
		parent.remove_child(shape)
		shape.name = parent_name  # Rename to parent StaticBody3D name
		area3d.add_child(shape)
		shape.owner = area3d  # Set new owner

	# Clean up all StaticBody3D and MeshInstance3D nodes
	_remove_unwanted_nodes(scene)

	# Return the GravityArea3D as the root
	return area3d

func _collect_collision_shapes(node, shapes_array):
	# Only collect collision shapes from nodes with "UCX_" prefix (CoACD convex hulls)
	if node is StaticBody3D and node.name.begins_with("UCX_"):
		for child in node.get_children():
			if child is CollisionShape3D:
				# Store both the shape and its parent's name
				shapes_array.append({"shape": child, "parent_name": node.name})

	for child in node.get_children():
		_collect_collision_shapes(child, shapes_array)

func _remove_unwanted_nodes(node):
	var to_remove = []
	for child in node.get_children():
		# Remove all StaticBody3D nodes (they're now empty after we took their collision shapes)
		if child is StaticBody3D:
			to_remove.append(child)
		else:
			_remove_unwanted_nodes(child)

	for child in to_remove:
		node.remove_child(child)
		child.queue_free()
