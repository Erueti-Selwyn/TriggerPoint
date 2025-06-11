extends StaticBody3D
@export var in_hand_position : Vector3
@export var in_hand_rotation : Vector3
@export var on_table_position : Vector3
@export var on_table_rotation : Vector3
@export var lerp_speed : float = 5
@export var hover_amount : float = 0.15
@export var meshes : Node
var is_in_hand : bool = false
var mesh_rest_position : Vector3
var mesh_rest_rotation : Vector3
var object_rest_position : Vector3
var mesh_target_position : Vector3
var mesh_target_rotation : Vector3
var global_rest_pos : Vector3
func _ready():
	global_rest_pos = global_position
	mesh_rest_position = meshes.global_position
	mesh_rest_rotation = meshes.rotation
	reset_mesh_transform()

func reset_mesh_transform():
	mesh_target_position = mesh_rest_position
	mesh_target_rotation = mesh_rest_rotation

func get_rest_pos():
	return(global_rest_pos)

func clickable():
	if not is_in_hand:
		is_in_hand = true
		mesh_target_position = in_hand_position
		mesh_target_rotation = in_hand_rotation
		await get_tree().create_timer(2.0).timeout
		reset_mesh_transform()
		is_in_hand = false
func gun_hover(hover_position):
	if not is_in_hand:
		mesh_target_position.y = hover_position.y
func _physics_process(delta):
	meshes.global_position = meshes.global_position.lerp(mesh_target_position, clamp(delta * lerp_speed, 0.0, 1.0))
	meshes.rotation = meshes.rotation.lerp(mesh_target_rotation, clamp(delta * lerp_speed, 0.0, 1.0))
