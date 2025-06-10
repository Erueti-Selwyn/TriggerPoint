extends Node3D

@export var camera : Node3D
@export var rotation_down : Vector3
@export var rotation_up : Vector3
@export var camera_lerp_speed : int
var target_rotation : Vector3
var current_hover_object
var new_hover_object
	
var mouse = Vector2()
const DIST = 1000
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_rotation = rotation_up

func check_mouse_position(mouse:Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	
	var raycast_result = space.intersect_ray(params)
	
	if raycast_result.is_empty()==false:
		new_hover_object = raycast_result.collider.get_parent()
		current_hover_object = new_hover_object
		if new_hover_object and new_hover_object.has_method("hover"):
			new_hover_object.hover()
	else:
		if current_hover_object and current_hover_object.has_method("unhover"):
				current_hover_object.unhover()
				current_hover_object = null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_mouse_position(get_viewport().get_mouse_position())
		
	if Input.is_action_just_pressed("move_up"):
		target_rotation = rotation_up
	elif Input.is_action_just_pressed("move_down"):
		target_rotation = rotation_down
	
	
func _physics_process(delta: float) -> void:
	camera.rotation = camera.rotation.lerp(target_rotation, clamp(delta * camera_lerp_speed, 0.0, 1.0))
