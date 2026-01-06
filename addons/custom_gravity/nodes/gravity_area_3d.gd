@tool
class_name GravityArea3D
extends Area3D

@export var gravity_resource: Gravity = PointGravity.new()

var shape: CollisionShape3D


func _ready():
	var children = find_children("*", "CollisionShape3D", false)
	if len(children) == 1:
		shape = children[0] as CollisionShape3D

	if !Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


func _enter_tree():
	if !Engine.is_editor_hint():
		GravityManager.register_gravity_area(self)


func _exit_tree():
	if !Engine.is_editor_hint():
		GravityManager.deregister_gravity_area(self)


func _on_body_entered(body: Node3D):
	if body is PhysicsBody3D:
		GravityManager.body_entered_area(body, self)


func _on_body_exited(body: Node3D):
	if body is PhysicsBody3D:
		GravityManager.body_exited_area(body, self)


func get_gravity_at(body_global_transform: Transform3D) -> Vector3:
	var relative_transform = global_transform.affine_inverse() * body_global_transform
	var local_gravity = gravity_resource.get_gravity_at(relative_transform.origin)
	return global_basis * local_gravity


func is_within_influence(body_global_transform: Transform3D) -> bool:
	var relative_transform = global_transform.affine_inverse() * body_global_transform
	return gravity_resource.is_within_influence(relative_transform.origin)
