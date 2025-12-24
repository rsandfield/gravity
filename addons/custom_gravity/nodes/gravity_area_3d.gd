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
	var relative_transform = body_global_transform * global_transform.inverse()
	return gravity_resource.get_gravity_at(relative_transform.origin)
