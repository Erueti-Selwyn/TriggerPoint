extends StaticBody3D
@export var lerp_speed : float = 5
@export var hover_amount : float = 0.15
@export var meshes : Node
var mesh_rest_position : Vector3
var mesh_target_position : Vector3
var global_rest_pos : Vector3
var rest_rot : Vector3
var hover : bool
func _ready() -> void:
	global_rest_pos = global_position
	rest_rot = rotation
func get_rest_pos():
	return(global_rest_pos)
func get_rest_rot():
	return(rest_rot)
func can_hover():
	hover = true
func cant_hover():
	hover = false
func get_hover_status():
	return(hover)
