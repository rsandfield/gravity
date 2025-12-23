@tool
extends EditorPlugin


const GravityGizmo = preload("res://addons/custom_gravity/custom_gravity_gizmo.gd")
var gizmo_plugin = GravityGizmo.new()

func _enable_plugin():
	# Add autoloads here.
	pass


func _disable_plugin():
	# Remove autoloads here.
	pass


func _enter_tree():
	add_custom_type(
		"GravityArea3D",
		"GravityArea3D",
		preload("res://addons/custom_gravity/gravity/nodes/gravity_area_3d.gd"),
		preload("res://addons/custom_gravity/gravity/nodes/gravity.svg")
	)

	add_autoload_singleton(
		"GravityManager",
		"res://addons/custom_gravity/gravity/gravity_manager.gd"
	)

	add_node_3d_gizmo_plugin(gizmo_plugin)


func _exit_tree():
	remove_custom_type("GravityArea3D")
	remove_autoload_singleton("GravityManager")
	remove_node_3d_gizmo_plugin(gizmo_plugin)