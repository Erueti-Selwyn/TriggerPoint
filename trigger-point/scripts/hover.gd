extends Node3D
@export var meshes : Node3D
@export var parent : Node
var meshes_rest_position : Vector3
@export var lerp_speed : float = 5
@export var hover_amount : float = 0.15
var is_hovering : bool
var target_position : Vector3
func hover():
	is_hovering = true
func unhover():
	is_hovering = false
func _physics_process(delta):
	meshes_rest_position = parent.global_position
	if is_hovering:
		target_position = Vector3(meshes.global_position.x, (meshes_rest_position.y + hover_amount), meshes.global_position.z)
	else:
		target_position = meshes_rest_position
	if target_position:
		if parent.has_method("gun_hover"):
			parent.gun_hover(target_position)
		else:
			meshes.global_position = meshes.global_position.lerp(target_position, clamp(delta * lerp_speed, 0.0, 1.0))
