extends CharacterBody3D

const MINIMUM_PUSHABLE_MASS_RATIO := 0.25
const PUSH_FORCE_MULTIPLIER := 5.0

@export var mass = 80
@export var walk_speed = 3
@export var ground_acceleration := 4.0
@export var ground_friction := 2.5

@export var jump_velocity = 11

@export var mouse_sensitivity: float = 0.1

@onready var _head: Node3D = $Head

var _jumping := false
var _gravity := Vector3.ZERO
var _wish_dir := Vector3.ZERO
var _paused := false

var _projectile_scene = preload("res://demo/projectile.tscn")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float):
	if _paused:
		return

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	move(input_dir)

	_apply_gravity(delta)
	_handle_ground_physics(delta)
	if _jumping:
		velocity += up_direction * jump_velocity
		_jumping = false
	_push_away_rigid_bodies()
	move_and_slide()


func _input(event: InputEvent):
	_handle_pause(event)
	if _paused:
		return

	if event.is_action("ui_accept") && is_on_floor():
		_jumping = true

	_handle_mouse_input(event)


func _handle_pause(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if _paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_paused = !_paused


func _handle_mouse_input(event: InputEvent):
	if event is InputEventMouseMotion:
		_head.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		_head.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		_head.rotation.y = fposmod(_head.rotation.y, TAU)
		_head.rotation.x = clamp(_head.rotation.x, -PI / 2 + 0.1, PI / 4)

	if event is InputEventMouseButton:
		_shoot()


func _shoot():
	var projectile = _projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_transform = global_transform
	projectile.global_position += _head.global_basis.z * -3
	projectile.linear_velocity = _head.global_basis.z.normalized() * -50


func move(dir: Vector2):
	var right_dir = _head.global_basis.x
	var forward_dir = _head.global_basis.z

	var raw_dir = (forward_dir * dir.y + right_dir * dir.x).normalized()
	_wish_dir = (raw_dir - up_direction * raw_dir.dot(up_direction)).normalized()


func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var collided = c.get_collider()
		if collided is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the
			# push direction
			var velocity_diff_in_push_dir = (
				velocity.dot(push_dir) - collided.linear_velocity.dot(push_dir)
			)
			# No diff needed if moving away
			velocity_diff_in_push_dir = max(0.0, velocity_diff_in_push_dir)
			var mass_ratio = min(1.0, mass / collided.mass)
			if mass_ratio < MINIMUM_PUSHABLE_MASS_RATIO:
				continue
			push_dir.y = 0
			var push_force = mass_ratio * PUSH_FORCE_MULTIPLIER
			collided.apply_impulse(
				push_dir * velocity_diff_in_push_dir * push_force,
				c.get_position() - collided.global_position
			)


func get_ground_speed() -> float:
	return walk_speed


func _handle_ground_physics(_delta: float):
	if !is_on_floor():
		return

	velocity = _wish_dir * walk_speed


func _apply_gravity(delta: float):
	_gravity = GravityManager.get_gravity(self)
	if _gravity == Vector3.ZERO:
		return

	up_direction = -_gravity.normalized()
	# Ensure _wish_dir is orthogonal to up_dir
	_wish_dir = (_wish_dir - up_direction * _wish_dir.dot(up_direction)).normalized()

	var curr_quat = global_basis.get_rotation_quaternion()
	var rotation_diff = Quaternion(global_basis.y, up_direction)
	var target_quat = (rotation_diff * curr_quat).normalized()

	global_basis = Basis(curr_quat.slerp(target_quat, delta * 10)).orthonormalized()

	if !is_on_floor():
		velocity += _gravity * delta
