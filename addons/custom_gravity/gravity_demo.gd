extends Node3D

func _ready():
	ProjectSettings.set_setting("physics/3d/default_gravity_vector", Vector3.ZERO)