extends Node3D

@export var tilt_strength: float = 10.0   # max degrees of tilt
@export var smoothness: float = 5.0      # how quickly it follows

var base_rot: Vector3
var target_rot: Vector3 = Vector3.ZERO


func _ready() -> void:
	base_rot = rotation_degrees  # remember initial orientation


func _process(delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var offset = (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)
	target_rot.y = -offset.x * tilt_strength
	target_rot.z = offset.y * tilt_strength
	rotation_degrees.y = lerp(rotation_degrees.y, base_rot.y + target_rot.y, delta * smoothness)
	rotation_degrees.z = lerp(rotation_degrees.z, base_rot.z + target_rot.z, delta * smoothness)
