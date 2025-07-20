extends Node3D
class_name Item

var in_hand : bool = false
var is_item : bool = true
@onready var original_pos : Vector3 = global_position
@onready var original_rot : Vector3 = rotation
var target_pos : Vector3
var target_rot : Vector3
var target_speed : float
var inventory_slot : int
var type : String
var item_type : String
var item_description : String
var item_y_offset : float

func move_to(pos: Vector3, rot: Vector3, speed: float):
	target_pos = pos
	target_rot = rot
	target_speed = speed
func _process(_delta):
	global_position = global_position.lerp(target_pos, target_speed)
	rotation = rotation.lerp(target_rot, target_speed)
func get_y_offset():
	var meshes_node = $mesh
	var mesh_instances = meshes_node.get_children()
	var lowest_point = INF
	for mesh in mesh_instances:
		if mesh is MeshInstance3D and mesh.mesh:
			var aabb = mesh.mesh.get_aabb()
			var mesh_bottom = mesh.to_global(aabb.position).y
			lowest_point = min(lowest_point, mesh_bottom)
	item_y_offset = lowest_point
