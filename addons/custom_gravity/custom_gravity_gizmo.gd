extends EditorNode3DGizmoPlugin

var cone: CylinderMesh = CylinderMesh.new()

func _init():
	create_material("main", Color(0, 1, 0, 0.25))


func _get_gizmo_name():
	return "Gravity"


func _create_gizmo(node):
	if _has_gizmo(node):
		var gizmo = GravityArea3DGizmo.new()
		gizmo.setup(node)
		return gizmo


func _has_gizmo(node):
	return node is GravityArea3D
