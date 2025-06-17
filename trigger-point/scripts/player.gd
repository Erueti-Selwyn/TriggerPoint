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
@export var item_lerp_speed : float
@export var held_item_pos : Node3D
@export var gun_node : Node
@export var shoot_self_transform : Node3D
@export var shoot_enemy_transform : Node3D
var shoot_target_transform : Node3D
@export var item_pos_1 : Node3D
@export var item_pos_2 : Node3D
@export var item_pos_3 : Node3D

var ammo_left : int

var item_pos_array : Array
var target_rotation : Vector3
var current_hover_object : Node
var previous_hover_mesh : Node
var current_hover_mesh : Node

var held_item_name : String
var held_item : Node
var inventory : Array = []
var item_count : int

var is_shooting : bool
const DIST = 1000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_shooting = false
	target_rotation = rotation_up
	inventory.append({"name": "gun", "id": gun_node,"in_hand": false})
	item_pos_array.append(item_pos_1)
	item_pos_array.append(item_pos_2)
	item_pos_array.append(item_pos_3)
	print(item_pos_array)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	check_mouse_position(get_viewport().get_mouse_position())
	
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
	if is_shooting:
		gun_node.global_position = gun_node.global_position.lerp(shoot_target_transform.global_position, item_lerp_speed)
		gun_node.rotation = gun_node.rotation.lerp(shoot_target_transform.rotation, item_lerp_speed)
	else:
		for item in inventory:
			if item["in_hand"] == true:
				var current_held_item = item["id"]
				if current_held_item.has_method("cant_hover"):
					current_held_item.cant_hover()
				toggle_child_collision(current_held_item, true)
				current_held_item.global_position = current_held_item.global_position.lerp(held_item_pos.global_position, item_lerp_speed)
				current_held_item.rotation = current_held_item.rotation.lerp(Vector3(0,0,0), item_lerp_speed)
	for item in inventory:
		if is_shooting == false and item["in_hand"] == false and item.has("name") and item["name"] == "gun":
			var item_not_in_hand = item["id"]
			if item_not_in_hand.has_method("can_hover"):
				item_not_in_hand.can_hover()
				toggle_child_collision(item_not_in_hand, false)
			if item_not_in_hand is Node and item_not_in_hand.has_method("get_rest_pos") and item_not_in_hand.has_method("get_rest_rot"):
				var item_return_location = item_not_in_hand.get_rest_pos()
				var item_return_rotation = item_not_in_hand.get_rest_rot()
				item_not_in_hand.global_position = item_not_in_hand.global_position.lerp(item_return_location, item_lerp_speed)
				item_not_in_hand.rotation = item_not_in_hand.rotation.lerp(item_return_rotation, item_lerp_speed)
		if item["in_hand"] == false and item.has("inventory_slot") and item["inventory_slot"]:
			var item_not_in_hand = item["id"]
			if item_not_in_hand.has_method("can_hover"):
				item_not_in_hand.can_hover()
			toggle_child_collision(item_not_in_hand, false)
			item_not_in_hand.global_position = item_not_in_hand.global_position.lerp(item_pos_array[item["inventory_slot"]-1].global_position, item_lerp_speed)

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

func toggle_child_collision(object, condition):
	for child in object.get_children():
					if child is CollisionShape3D:
						child.disabled = condition

func click():
	if current_hover_object:
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
		for item in inventory:
			if item.has("name") and item["name"] == "gun" and item.has("in_hand") and item["in_hand"] == true: 
				if current_hover_object.is_in_group("enemy_button"):
					shoot_target_transform = shoot_enemy_transform
					is_shooting = true
				elif current_hover_object.is_in_group("self_button"):
					shoot_target_transform = shoot_self_transform
					is_shooting = true

func drop_item():
	for item in inventory:
		if item["in_hand"] == true:
			item["in_hand"] = false
