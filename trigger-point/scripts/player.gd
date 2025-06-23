extends Node3D

# DEBUG STUFF
@export var debug_label_1 : Label
@export var debug_label_2 : Label
@export var debug_label_3 : Label
@export var debug_label_4 : Label
# DEBUG STUFF

# ASSETS
var potion_scene = preload("res://scenes/item.tscn")
var blood_splatter_particle = preload("res://scenes/blood_splatter_particle.tscn")
var bullet_scene = preload("res://scenes/bullet.tscn")
# ASSETS

@export var camera : Node3D
@export var rotation_down : Vector3
@export var rotation_up : Vector3
@export var camera_lerp_speed : int
@export var item_lerp_speed : float
@export var held_item_pos : Node3D
@export var gun_node : Node
@export var shoot_player_transform : Node3D
@export var shoot_enemy_transform : Node3D
var shoot_target_transform : Node3D
@export var item_pos_1 : Node3D
@export var item_pos_2 : Node3D
@export var item_pos_3 : Node3D

var max_ammo_in_chamber : int
var loaded_bullets_array : Array
var blank_shots : int
var live_shots : int

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
var turn_number : int
var is_players_turn : bool
# For Mouse Hovering
const DIST = 1000


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_player_turn()
	max_ammo_in_chamber = 6
	reload()
	is_shooting = false
	target_rotation = rotation_up
	inventory.append({"name": "gun", "id": gun_node,"in_hand": false})
	item_pos_array.append(item_pos_1)
	item_pos_array.append(item_pos_2)
	item_pos_array.append(item_pos_3)
	print(item_pos_array)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	live_shots = loaded_bullets_array.count(true)
	blank_shots = loaded_bullets_array.count(false)
	debug_label_2.text = ("loaded bullets: " + str(loaded_bullets_array))
	debug_label_3.text = ("Bullet Count - LIVE : " + str(live_shots) + " - BLANK : " + str(blank_shots) + " - is_shooting : " + str(is_shooting))
	debug_label_4.text = ("is_players_turn: " + str(is_players_turn) + " - is_shooting: " + str(is_shooting))
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
	
	if Input.is_action_just_pressed("reload"):
		reload()


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
	if raycast_result.is_empty()==false and is_shooting == false and is_players_turn == true:
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


func toggle_child_collision(object : Node, condition : bool):
	for child in object.get_children():
					if child is CollisionShape3D:
						child.disabled = condition


func click():
	if current_hover_object and is_shooting == false and is_players_turn == true:
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
				if loaded_bullets_array.size() > 0:
					if current_hover_object.is_in_group("enemy_button"):
						player_shoot("enemy", shoot_enemy_transform)
					elif current_hover_object.is_in_group("player_button"):
						player_shoot("player", shoot_player_transform)


func drop_item():
	is_shooting = false
	for item in inventory:
		if item["in_hand"] == true:
			item["in_hand"] = false


func player_shoot(target_name : String, player_shoot_target : Node3D):
	drop_item()
	# Checks if turn continues
	var is_live_bullet = await shoot_gun(player_shoot_target)
	if target_name == "player":
		if is_live_bullet == true:
			print("player shot themself")
			end_players_turn()
			start_enemy_turn()
		else:
			print("player blanked themself")
	if target_name == "enemy":
		if is_live_bullet == true:
			print("player shot enemy")
		else:
			print("player blanked enemy")
		end_players_turn()
		start_enemy_turn()


func enemy_shoot(target_name : String, enemy_shoot_target : Node3D):
	var is_live_bullet = await shoot_gun(enemy_shoot_target)
	if target_name == "enemy":
		if is_live_bullet == true:
			print("enemy shot itself")
			start_player_turn()
		else:
			print("enemy blanked itself")
			start_enemy_turn()
	if target_name == "player":
		if is_live_bullet == true:
			print("enemy shot player")
		else:
			print("enemy blanked player")
		start_player_turn()

func shoot_gun(target : Node3D):
	print("gun shoots")
	is_shooting = true
	shoot_target_transform = target
	# Checks if bullet was live or blank
	await get_tree().create_timer(1).timeout
	var is_live_bullets
	if loaded_bullets_array[0] == true:
		gun_node.play_sound_shot()
		end_players_turn()
		var blood = blood_splatter_particle.instantiate()
		add_child(blood)
		blood.global_position = Vector3(target.global_position.x, target.global_position.y + 0.4, target.global_position.z)
		blood.emitting = true
		is_live_bullets = true
	else:
		gun_node.play_sound_click()
		is_live_bullets = false
	loaded_bullets_array.remove_at(0)
	# Waits for animation to finish
	# Add animation later
	await get_tree().create_timer(1).timeout
	gun_node.play_sound_cock()
	is_shooting = false
	return(is_live_bullets)


func reload():
	if is_shooting == false:
		loaded_bullets_array = []
		for i in range(max_ammo_in_chamber):
			var rand = randi_range(1, 2)
			if rand == 1:
				loaded_bullets_array.append(true)
			else:
				loaded_bullets_array.append(false)
		show_loaded_bullets()
		start_player_turn()


func show_loaded_bullets():
	var bullet_obj_array : Array
	for item in range(loaded_bullets_array.size()):
		var item_number = float(item)
		if loaded_bullets_array[item] == true:
			var bullet = bullet_scene.instantiate()
			add_child(bullet)
			var mesh = bullet.get_node("MeshInstance3D")
			var base_mat = mesh.get_active_material(0)
			var mat = base_mat.duplicate()
			mat.albedo_color = Color(1, 0, 0)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(held_item_pos.global_position.x, held_item_pos.global_position.y, held_item_pos.global_position.z - (item_number/4))
			bullet_obj_array.append(bullet)
		else:
			var bullet = bullet_scene.instantiate()
			add_child(bullet)
			var mesh = bullet.get_node("MeshInstance3D")
			var base_mat = mesh.get_active_material(0)
			var mat = base_mat.duplicate()
			mat.albedo_color = Color(0, 0, 1)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(held_item_pos.global_position.x, held_item_pos.global_position.y, held_item_pos.global_position.z - (item_number/4))
			bullet_obj_array.append(bullet)
	await get_tree().create_timer(3).timeout
	for item in bullet_obj_array:
		item.queue_free()
	start_player_turn()


func start_player_turn():
	is_players_turn = true


func end_players_turn():
	is_players_turn = false


func start_enemy_turn():
	await get_tree().create_timer(1).timeout
	var rand = randi_range(1, 2)
	if loaded_bullets_array.size() > 0:
		if rand == 1:
			# Enemy shoots self
			enemy_shoot("enemy", shoot_enemy_transform)
		elif rand == 2:
			# Enemy shoots you
			enemy_shoot("player", shoot_player_transform)
