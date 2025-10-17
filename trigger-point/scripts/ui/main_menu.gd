extends Node3D

@export var options_menu: Control

var DIST: float = 1000
var current_hover_object: Node3D


func _process(_delta: float) -> void:
	check_mouse_position(get_viewport().get_mouse_position())


func check_mouse_position(mouse: Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	# Creates raycast where mouse is
	var raycast_result = space.intersect_ray(params)
	# Highlights currently hovered menu button
	if raycast_result.is_empty() == false:
		if raycast_result.collider != current_hover_object and current_hover_object:
			current_hover_object.unhover()
		if raycast_result.collider.is_in_group("button"):
			current_hover_object = raycast_result.collider
			current_hover_object.hover()
	elif current_hover_object:
		current_hover_object.unhover()
		current_hover_object = null


# Checks for click
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click()


func click():
	if current_hover_object and GameManager.pause == false:
		if current_hover_object.click() == "play":
			get_tree().change_scene_to_file("res://scenes/gameplay/level.tscn")
		elif current_hover_object.click() == "options":
			options_menu.open()
		elif current_hover_object.click() == "quit":
			get_tree().quit()
