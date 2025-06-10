extends Node3D

@export var camera : Node3D
@export var rotation_down : Vector3
@export var rotation_up : Vector3
@export var camera_lerp_speed : int
var target_rotation : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_rotation = rotation_up


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		target_rotation = rotation_up
	elif Input.is_action_just_pressed("move_down"):
		target_rotation = rotation_down

func _physics_process(delta: float) -> void:
	camera.rotation = camera.rotation.lerp(target_rotation, clamp(delta * camera_lerp_speed, 0.0, 1.0))
