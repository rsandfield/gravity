extends Node3D

@export var offset: Vector3 = Vector3.ZERO
@export var radius: float = 10.0
@export var speed: float = 1.0

var counter: float = 0.0


func _process(delta):
	counter += delta * speed
	position = Vector3(sin(counter), cos(counter), 0) * radius + offset
