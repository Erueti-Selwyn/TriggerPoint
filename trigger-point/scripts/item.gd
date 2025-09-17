extends Node3D
class_name Item

var base_model: PackedScene
var upgraded_model: PackedScene

var in_hand: bool = false
var is_item: bool = true
var is_shop_item: bool = false
@onready var original_pos: Vector3 = global_position
@onready var original_rot: Vector3 = rotation
var target_pos: Vector3
var target_rot: Vector3
var target_speed: float
var inventory_slot: int
var type: String
var item_type: String
var item_description: String
var upgraded_description: String
var shop_description: String
var upgrade_price: int = 5
var item_y_offset: float
var item_level: int = 1


func _ready() -> void:
	if is_shop_item:
		await load_upgraded_model()
	else:
		await load_model()


func move_to(pos: Vector3, rot: Vector3, speed: float):
	target_pos = pos
	target_rot = rot
	target_speed = speed


func _physics_process(_delta):
	global_position = global_position.lerp(target_pos, target_speed)
	rotation = rotation.lerp(target_rot, target_speed)


func load_model():
	item_level = GameManager.item_name_level_dictionary[item_type]
	if item_level == 1:
		load_base_model()
	elif item_level == 2:
		load_upgraded_model()


func load_base_model():
	var meshes_node: Node3D = $mesh
	var model: Node3D = base_model.instantiate()
	meshes_node.add_child(model)
	model.global_position = meshes_node.global_position


func load_upgraded_model():
	var meshes_node: Node3D = $mesh
	var model: Node3D = upgraded_model.instantiate()
	meshes_node.add_child(model)
	model.global_position = meshes_node.global_position
