extends CharacterBody3D

@export var walk_speed = 3
@export var ground_acceleration := 4.0
@export var ground_friction := 2.5

@export var jump_velocity = 7

@export var mouse_sensitivity: float = 0.1

@onready var _head: Node3D = $Head

var _gravity := Vector3.ZERO
var _wish_dir := Vector3.ZERO
var _paused := false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float):
	if _paused:
		return

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	move(input_dir)

	_apply_gravity(delta)
	_handle_ground_physics(delta)
	move_and_slide()


func _input(event: InputEvent):
	_handle_pause(event)
	if _paused:
		return

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
		_head.rotation.x = clamp(_head.rotation.x, -PI / 2, PI / 2)


func move(dir: Vector2):
	var right_dir = transform.basis.x
	var forward_dir = transform.basis.z

	_wish_dir = (forward_dir * dir.y + right_dir * dir.x).normalized()
	_wish_dir = _wish_dir.rotated(up_direction, _head.rotation.y)


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

	var forward_dir = basis.z
	if abs(forward_dir.dot(up_direction)) > 0.98:
		forward_dir = basis.x
	forward_dir = (forward_dir - up_direction * forward_dir.dot(up_direction)).normalized()

	var right_dir = up_direction.cross(forward_dir).normalized()
	var orientation = Basis(right_dir, up_direction, forward_dir)
	basis = basis.slerp(orientation, delta * 10).orthonormalized()

	if !is_on_floor():
		velocity += _gravity * delta
