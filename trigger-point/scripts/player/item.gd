extends Node3D
class_name Item

# Variables needed by item class
var in_hand: bool = false
var is_recieving: bool = false
var is_item: bool = true
var target_pos: Vector3
var target_rot: Vector3
var target_speed: float
var inventory_slot: int
var type: String
var item_description: String
var upgrade_price: int = 5
var item_y_offset: float

@onready var original_pos: Vector3 = global_position
@onready var original_rot: Vector3 = rotation


# Function to change the target location
func move_to(pos: Vector3, rot: Vector3, speed: float):
	target_pos = pos
	target_rot = rot
	target_speed = speed


func _physics_process(_delta):
	# Moves object to target location
	global_position = global_position.lerp(target_pos, target_speed)
	rotation = rotation.lerp(target_rot, target_speed)
