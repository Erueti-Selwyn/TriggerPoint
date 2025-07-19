class_name Item
extends Node3D

var in_hand : bool = false
var original_pos : Vector3
var original_rot : Vector3
var inventory_slot := 0

func move_to(pos: Vector3, rot: Vector3, speed: float):
	global_position = global_position.lerp(position, speed)
	rotation = rotation.lerp(rotation, speed)
