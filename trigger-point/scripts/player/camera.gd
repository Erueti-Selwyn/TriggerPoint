extends Node3D

@export var camera: Camera3D
@export var tilt_strength: float = 10.0
@export var smoothness: float = 5.0
@export var max_strength: float = 30.0
@export var shake_fade: float = 5.0

var shake_strength: float = 0.0
var base_rot: Vector3
var target_rot: Vector3 = Vector3.ZERO


func _ready() -> void:
	# Gets base camera rotation
	base_rot = rotation_degrees
	GameManager.camera = self


func _process(delta: float) -> void:
	# Gets mouse position and viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	# Offsets camera based on mouse position
	var offset = (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)
	target_rot.y = -offset.x * tilt_strength
	target_rot.z = offset.y * tilt_strength
	# Rotates camera based on offset
	rotation_degrees.y = lerp(rotation_degrees.y, base_rot.y + target_rot.y, delta * smoothness)
	rotation_degrees.z = lerp(rotation_degrees.z, base_rot.z + target_rot.z, delta * smoothness)
	# Brings shake back down to zero
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
	# Gets a random camera offset based on shake strength
	camera.h_offset = randf_range(-shake_strength, shake_strength)
	camera.v_offset = randf_range(-shake_strength, shake_strength)


# Sets strength to max strength
func shake_screen():
	shake_strength = max_strength
