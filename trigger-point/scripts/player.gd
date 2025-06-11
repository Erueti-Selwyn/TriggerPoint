extends Node3D

# DEBUG STUFF
@export var debug_label_1 : Label
@export var debug_label_2 : Label
@export var debug_label_3 : Label
# DEBUG STUFF

# ASSETS
var potion_scene = preload("res://scenes/item.tscn")
# ASSETS

@export var camera : Node3D
@export var rotation_down : Vector3
@export var rotation_up : Vector3
@export var camera_lerp_speed : int
@export var held_item_pos : Node3D
@export var gun_node : Node
@export var item_pos_1 : Node3D
@export var item_pos_2 : Node3D
@export var item_pos_3 : Node3D
var target_rotation : Vector3
var current_hover_object : Node
var previous_hover_mesh : Node
var current_hover_mesh : Node

var held_item_name : String
var held_item : Node
var inventory : Array = []
var item_count : int
	
const DIST = 1000
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_rotation = rotation_up
	inventory.append({"name": "gun", "id": gun_node,"in_hand": false})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	check_mouse_position(get_viewport().get_mouse_position())
	

	debug_label_2.text = str(item_count)
		
	if Input.is_action_just_pressed("move_up"):
		target_rotation = rotation_up
	elif Input.is_action_just_pressed("move_down"):
		target_rotation = rotation_down
	if Input.is_action_just_pressed("add_item"):
		if inventory.size() <= 3:
			var new_item = potion_scene.instantiate()
			var level_node = get_tree().get_current_scene()
			level_node.add_child(new_item)
			item_count = inventory.size()
			inventory.append({"id": new_item, "type": "purple", "in_hand": false, "inventory_slot": item_count})
	debug_label_1.text = str(inventory)
	
	if Input.is_action_just_pressed("escape"):
		drop_item()
	
func _physics_process(delta: float) -> void:
	camera.rotation = camera.rotation.lerp(target_rotation, clamp(delta * camera_lerp_speed, 0.0, 1.0))
	for item in inventory:
		if item["in_hand"] == true:
			var current_held_item = item["id"]
			current_held_item.global_position = current_held_item.global_position.lerp(held_item_pos.global_position, 0.1)
	for item in inventory:
		if item["in_hand"] == false and item.has("name") and item["name"] == "gun":
			var item_not_in_hand = item["id"]
			if item_not_in_hand is Node and item_not_in_hand.has_method("get_rest_pos"):
				var item_return_location = item_not_in_hand.get_rest_pos()
				item_not_in_hand.global_position = item_not_in_hand.global_position.lerp(item_return_location, 0.1)
		if item["in_hand"] == false and item.has("inventory_slot") and item["inventory_slot"]:
			if item.has("inventory_slot") and item["inventory_slot"] == 1:
				var item_not_in_hand = item["id"]
				item_not_in_hand.global_position = item_not_in_hand.global_position.lerp(item_pos_1.global_position, 0.1)
			if item.has("inventory_slot") and item["inventory_slot"] == 2:
				var item_not_in_hand = item["id"]
				item_not_in_hand.global_position = item_not_in_hand.global_position.lerp(item_pos_2.global_position, 0.1)
			if item.has("inventory_slot") and item["inventory_slot"] == 3:
				var item_not_in_hand = item["id"]
				item_not_in_hand.global_position = item_not_in_hand.global_position.lerp(item_pos_3.global_position, 0.1)
					

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click()

func check_mouse_position(mouse:Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	
	var raycast_result = space.intersect_ray(params)
	if raycast_result.is_empty()==false:
		current_hover_mesh = find_hover_script(raycast_result.collider)
		current_hover_object = raycast_result.collider
		if previous_hover_mesh  != current_hover_mesh:
			if previous_hover_mesh and previous_hover_mesh.has_method("unhover"):
					previous_hover_mesh.unhover()
					previous_hover_mesh = null
		previous_hover_mesh = current_hover_mesh
		if current_hover_mesh and current_hover_mesh.has_method("hover"):
			current_hover_mesh.hover()
	else:
		if previous_hover_mesh and previous_hover_mesh.has_method("unhover"):
				previous_hover_mesh.unhover()
				previous_hover_mesh = null
				current_hover_object = null

func find_hover_script(node):
	if node.has_method("hover"):
		return node
	for child in node.get_children():
		var hover_node = find_hover_script(child)
		if hover_node:
			return hover_node
	return null

func click():
	if current_hover_object and current_hover_object.has_method("clickable"):
		if current_hover_object.is_in_group("gun"):
			for item in inventory:
				if item.has("name") and item["name"] == "gun":
					drop_item()
					item["in_hand"] = true
		elif current_hover_object.is_in_group("item"):
			for item in inventory:
				if item.has("id") and current_hover_object == item["id"]:
					drop_item()
					item["in_hand"] = true

func drop_item():
	for item in inventory:
		if item["in_hand"] == true:
			item["in_hand"] = false
