extends Node3D
@export var meshes : Node3D
var meshes_rest_position : Vector3
@export var lerp_speed : float = 5
@export var hover_amount : float = 0.15
var target_position : Vector3
func _ready():
	meshes_rest_position = meshes.global_position
	print(meshes_rest_position)
func hover():
	target_position = Vector3(meshes.global_position.x, (meshes_rest_position.y + hover_amount), meshes.global_position.z)
func unhover():
	target_position = meshes_rest_position
func _physics_process(delta):
	if target_position:
		meshes.global_position = meshes.global_position.lerp(target_position, clamp(delta * lerp_speed, 0.0, 1.0))
