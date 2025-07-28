extends Node3D

# DEBUG STUFF
@export var debug_label_1 : Label
@export var debug_label_2 : Label
@export var debug_label_3 : Label
@export var debug_label_4 : Label
# DEBUG STUFF

# ASSETS
var one_health_item_scene = preload("res://scenes/item/one_health_item.tscn")
var peek_item_scene = preload("res://scenes/item/peek_item.tscn")
var shuffle_item_scene = preload("res://scenes/item/shuffle_item.tscn")
var double_damage_item_scene = preload("res://scenes/item/double_damage_item.tscn")
var remove_bullet_item_scene = preload("res://scenes/item/remove_bullet_item.tscn")
var blood_splatter_particle = preload("res://scenes/blood_splatter_particle.tscn")
var bullet_scene = preload("res://scenes/bullet.tscn")
# ASSETS

@export var camera : Node3D
@export var rotation_look_up : Vector3
@export var rotation_look_down : Vector3
@export var camera_lerp_speed : int
@export var item_lerp_speed : float
@export var gun_lerp_speed : float
@export var held_item_pos : Node3D
@export var gun_node : Node
@export var shoot_player_transform : Node3D
@export var shoot_enemy_transform : Node3D

var shoot_target_transform : Node3D
@export var item_pos_1 : Node3D
@export var item_pos_2 : Node3D
@export var item_pos_3 : Node3D
@export var item_pos_4 : Node3D
@export var live_bullet_pos : Node3D
@export var blank_bullet_pos : Node3D

# In game UI features
@export var win_lose_screen : Control
@export var current_damage_label : Label3D
@export var held_item_description_label : Label3D
@export var player_score_label : Label3D
@export var enemy_score_label : Label3D
@export var player_turn_light : MeshInstance3D
@export var enemy_turn_light : MeshInstance3D
@export var shoot_player_label : Label3D
@export var shoot_enemy_label : Label3D

@onready var light_on_mat = preload("res://materials/light_glow_material.tres")
@onready var light_off_mat = preload("res://materials/light_off_material.tres")

@onready var item_pos_array : Array [Node3D]

var item_scene_array : Array

var current_bullet_damage : int
var damage : int

var player_health : int
var enemy_health : int

var max_ammo_in_chamber : int
var loaded_bullets_array : Array
var blank_shots : int
var live_shots : int
var used_shells : int
var used_shells_array : Array

var target_rotation : Vector3
var current_hover_object : Node
var previous_hover_mesh : Node
var current_hover_mesh : Node

var held_item : Node
var inventory : Array = []
var item_count : int

var turn_number : int
# For Mouse Hovering
const DIST = 1000

enum GameState {WAITING, PLAYERTURN, ENEMYTURN, SHOOTING, ENEMYITEM, RELOADING, USINGITEM, SHOPING, GAMEOVER}
const GameStateNames = {
	GameState.WAITING: "WAITING",
	GameState.PLAYERTURN: "PLAYERTURN",
	GameState.ENEMYTURN: "ENEMYTURN",
	GameState.SHOOTING: "SHOOTING",
	GameState.ENEMYITEM: "ENEMYITEM",
	GameState.RELOADING: "RELOADING",
	GameState.USINGITEM: "USINGITEM",
	GameState.SHOPING: "SHOPING",
	GameState.GAMEOVER: "GAMEOVER",
}
var game_state : GameState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_scene_array = [one_health_item_scene, peek_item_scene, shuffle_item_scene, double_damage_item_scene, remove_bullet_item_scene]
	game_state = GameState.WAITING
	current_bullet_damage = 1
	damage = current_bullet_damage
	player_health = 10
	enemy_health = 10
	item_pos_array = [item_pos_1, item_pos_2, item_pos_3, item_pos_4]
	reload()
	target_rotation = rotation_look_up
	gun_node.inventory_slot = 0
	inventory.append(gun_node)
	inventory.resize(5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	live_shots = loaded_bullets_array.count(true)
	blank_shots = loaded_bullets_array.count(false)
	#debug_label_1.text = str(inventory)
	#debug_label_2.text = ("loaded bullets: " + str(loaded_bullets_array))
	#debug_label_3.text = ("Bullet Count - LIVE : " + str(live_shots) + " - BLANK : " + str(blank_shots))
	#debug_label_4.text = ("Game State: " + GameStateNames[game_state])
	current_damage_label.text = ("Damage: " + str(damage))
	if player_health <= 0 and not game_state == GameState.GAMEOVER:
		player_health = 0
		game_state = GameState.GAMEOVER
		lose()
	if enemy_health <= 0 and not game_state == GameState.GAMEOVER:
		enemy_health = 0
		game_state = GameState.GAMEOVER
		win()
	player_score_label.text = str(player_health)
	enemy_score_label.text = str(enemy_health)
	check_mouse_position(get_viewport().get_mouse_position())
	if is_instance_valid(held_item) and not held_item == gun_node:
		held_item_description_label.visible = true
		held_item_description_label.text = held_item.item_description
	else:
		held_item_description_label.visible = false
	if Input.is_action_just_pressed("move_up"):
		target_rotation = rotation_look_up
	elif Input.is_action_just_pressed("move_down"):
		target_rotation = rotation_look_down
	#if Input.is_action_just_pressed("add_item"):
	#	create_item()
	if Input.is_action_just_pressed("escape"):
		drop_item()
	if Input.is_action_just_pressed("reload"):
		reload()
	# Changes material of light bar to show whos turn it is
	if game_state == GameState.PLAYERTURN:
		player_turn_light.mesh.surface_set_material(0, light_on_mat)
		enemy_turn_light.mesh.surface_set_material(0, light_off_mat)
	if game_state == GameState.ENEMYTURN:
		enemy_turn_light.mesh.surface_set_material(0, light_on_mat)
		player_turn_light.mesh.surface_set_material(0, light_off_mat)

	# Changes the colour of the text on the table when hovering
	if game_state == GameState.PLAYERTURN and current_hover_object:
		if current_hover_object.is_in_group("player_button"):
			shoot_player_label.modulate = Color("ffffff")
		else:
			shoot_player_label.modulate = Color("adadad")
		if current_hover_object.is_in_group("enemy_button"):
			shoot_enemy_label.modulate = Color("ffffff")
		else:
			shoot_enemy_label.modulate = Color("adadad")
	else:
		shoot_player_label.modulate = Color("adadad")
		shoot_enemy_label.modulate = Color("adadad")

	# Changes text on table depending on what is being held
	if is_instance_valid(held_item) and held_item.type == "gun" and loaded_bullets_array.size() > 0:
		shoot_player_label.visible = true
		shoot_enemy_label.visible = true
		shoot_player_label.text = "Shoot \nSelf"
		shoot_enemy_label.text = "Shoot \nEnemy"
	elif is_instance_valid(held_item) and held_item.type == "item":
		shoot_player_label.visible = true
		shoot_enemy_label.visible = true
		shoot_player_label.text = "Use item\non Self"
		shoot_enemy_label.text = "Use item\non Enemy"
	else:
		shoot_player_label.visible = false
		shoot_enemy_label.visible = false


func _physics_process(delta: float) -> void:
	# Changes the rotation of camera to target rotation
	camera.rotation = camera.rotation.lerp(target_rotation, clamp(delta * camera_lerp_speed, 0.0, 1.0))
	# Creates a var of the item in hand
	for item in inventory:
		if is_instance_valid(item) and item.in_hand:
			held_item = item
			break
	# Putting gun at shooting position when shooting
	if game_state == GameState.SHOOTING:
		gun_node.move_to(shoot_target_transform.global_position, shoot_target_transform.rotation, gun_lerp_speed)
	else:
		# Makes item in hand go to held item position
		if is_instance_valid(held_item) and held_item.in_hand:
			toggle_child_collision(held_item, true)
			held_item.move_to(held_item_pos.global_position, Vector3(0, 0, 0), item_lerp_speed)
	for item in inventory:
		# Returns items not in hand
		if is_instance_valid(item) and item is Node3D and not item.in_hand:
			toggle_child_collision(item, false)
			if item.type == "item":
				if item.item_y_offset != null:
					var target_pos = item_pos_array[item.inventory_slot - 1].global_position
					item.move_to(target_pos - Vector3(0, item.item_y_offset, 0), item.original_rot, item_lerp_speed)
			elif item.type == "gun" and not game_state == GameState.SHOOTING:
				item.move_to(item.original_pos, item.original_rot, item_lerp_speed)

	

func move_item_lerp(item_node: Node, pos: Vector3, rot: Vector3, speed:float):
	item_node.global_position = item_node.global_position.lerp(pos, speed)
	item_node.rotation = item_node.rotation.lerp(rot, speed)

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
	if raycast_result.is_empty() == false and game_state == GameState.PLAYERTURN:
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
	if current_hover_object and game_state == GameState.PLAYERTURN:
		if current_hover_object.is_in_group("gun") or current_hover_object.is_in_group("item"):
			for item in inventory:
				if current_hover_object == item:
					drop_item()
					item.in_hand = true
		if gun_node.in_hand and loaded_bullets_array.size() > 0: 
			if current_hover_object.is_in_group("enemy_button"):
				player_shoot("enemy", shoot_enemy_transform)
			elif current_hover_object.is_in_group("player_button"):
				player_shoot("player", shoot_player_transform)
		elif current_hover_object.is_in_group("player_button") or current_hover_object.is_in_group("enemy_button"):
			for item in inventory:
				if is_instance_valid(item) and item.in_hand and item.type == "item":
					game_state = GameState.USINGITEM
					if not await item.use(self) == false:
						destroy_item(item)
					game_state = GameState.PLAYERTURN
					

func drop_item():
	for item in inventory:
		if is_instance_valid(item) and item.in_hand == true:
			item.in_hand = false


func player_shoot(target_name : String, player_shoot_target : Node3D):
	drop_item()
	# Checks if turn continues
	var is_live_bullet = await shoot_gun(target_name, player_shoot_target)
	if target_name == "player":
		if is_live_bullet == true:
			start_enemy_turn()
		else:
			game_state = GameState.PLAYERTURN
	if target_name == "enemy":
		start_enemy_turn()


func enemy_shoot(target_name : String, enemy_shoot_target : Node3D):
	var is_live_bullet = await shoot_gun(target_name, enemy_shoot_target)
	if target_name == "enemy":
		if is_live_bullet == true:
			start_player_turn()
		else:
			start_enemy_turn()
	if target_name == "player":
		start_player_turn()

func shoot_gun(target_name : String, target_node : Node3D):
	game_state = GameState.SHOOTING
	shoot_target_transform = target_node
	# Checks if bullet was live or blank
	await get_tree().create_timer(1.5, false).timeout
	var is_live_bullets
	if loaded_bullets_array[0] == true:
		gun_node.play_sound_shot()
		var blood = blood_splatter_particle.instantiate()
		add_child(blood)
		blood.global_position = Vector3(target_node.global_position.x, target_node.global_position.y + 0.4, target_node.global_position.z)
		blood.emitting = true
		is_live_bullets = true
		if target_name == "player":
			player_health -= damage
		elif target_name == "enemy":
			enemy_health -= damage
		current_bullet_damage += 1
		damage = current_bullet_damage
	else:
		gun_node.play_sound_click()
		is_live_bullets = false
	loaded_bullets_array.remove_at(0)
	# Waits for animation to finish
	# Add animation later
	await get_tree().create_timer(1, false).timeout
	gun_node.play_sound_cock()
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	var mesh = bullet.get_node("MeshInstance3D")
	var base_mat = mesh.get_active_material(0)
	var mat = base_mat.duplicate()
	if is_live_bullets:
		mat.albedo_color = Color(1, 0, 0)
	else:
		mat.albedo_color = Color(0, 0, 1)
	mesh.set_surface_override_material(0, mat)
	bullet.global_position = Vector3(live_bullet_pos.global_position.x, live_bullet_pos.global_position.y + 0.1, live_bullet_pos.global_position.z - (float(used_shells)/6))
	bullet.rotation = Vector3(0, 0, deg_to_rad(90))
	used_shells_array.append(bullet)
	used_shells += 1
	return(is_live_bullets)


func reload():
	if game_state == GameState.PLAYERTURN or game_state == GameState.WAITING:
		game_state = GameState.RELOADING
		max_ammo_in_chamber = randi_range(4,6)
		loaded_bullets_array = []
		for i in range(max_ammo_in_chamber):
			var rand = randi_range(1, 2)
			if rand == 1:
				loaded_bullets_array.append(true)
			else:
				loaded_bullets_array.append(false)
		show_loaded_bullets()


func show_loaded_bullets():
	var current_live_bullet_count : int = 0
	var current_blank_bullet_count : int = 0
	var bullet_obj_array : Array
	# Shows loaded bullets in order
	for item in range(loaded_bullets_array.size()):
		if loaded_bullets_array[item] == true:
			current_live_bullet_count += 1
			var bullet = bullet_scene.instantiate()
			add_child(bullet)
			var mesh = bullet.get_node("MeshInstance3D")
			var base_mat = mesh.get_active_material(0)
			var mat = base_mat.duplicate()
			mat.albedo_color = Color(1, 0, 0)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(live_bullet_pos.global_position.x, live_bullet_pos.global_position.y + 0.1, live_bullet_pos.global_position.z - (float(current_live_bullet_count)/6))
			bullet.rotation = Vector3(0, 0, deg_to_rad(90))
			bullet_obj_array.append(bullet)
		else:
			current_blank_bullet_count += 1
			var bullet = bullet_scene.instantiate()
			add_child(bullet)
			var mesh = bullet.get_node("MeshInstance3D")
			var base_mat = mesh.get_active_material(0)
			var mat = base_mat.duplicate()
			mat.albedo_color = Color(0, 0, 1)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(blank_bullet_pos.global_position.x, blank_bullet_pos.global_position.y + 0.1, blank_bullet_pos.global_position.z + (float(current_blank_bullet_count)/6))
			bullet.rotation = Vector3(0, 0, deg_to_rad(90))
			bullet_obj_array.append(bullet)
	
	await get_tree().create_timer(2, false).timeout
	for item in bullet_obj_array:
		item.queue_free()
	start_player_turn()


func create_item():
	var inv_has_null : bool = false
	for item in inventory:
		if item == null:
			inv_has_null = true
	if inventory.size() <= item_pos_array.size() or inv_has_null and game_state == GameState.PLAYERTURN:
		var rand = randi_range(0, item_scene_array.size() - 1)
		var new_item
		new_item = item_scene_array[rand].instantiate()
		var level_node = get_tree().get_current_scene()
		level_node.add_child(new_item)
		var replace_item_slot : int
		for i in inventory.size():
			if inventory[i] == null:
				replace_item_slot = i
				break
		if replace_item_slot:
			inventory.remove_at(replace_item_slot)
			inventory.insert(replace_item_slot, new_item)
			new_item.inventory_slot = replace_item_slot
		else:
			new_item.inventory_slot = inventory.size()
			inventory.append(new_item)


func destroy_item(item_node : Node):
	var used_item = item_node
	inventory[item_node.inventory_slot] = null
	item_node = null
	used_item.queue_free()

func start_enemy_turn():
	if game_state != GameState.GAMEOVER:
		if loaded_bullets_array.size() > 0:
			game_state = GameState.ENEMYTURN
			await get_tree().create_timer(1, false).timeout
			var rand = randi_range(1, 2)
			if rand == 1:
				# Enemy shoots self
				enemy_shoot("enemy", shoot_enemy_transform)
			elif rand == 2:
				# Enemy shoots you
				enemy_shoot("player", shoot_player_transform)
		else:
			game_state = GameState.WAITING
			reload()


func start_player_turn():
	game_state = GameState.PLAYERTURN
	create_item()


func win():
	win_lose_screen.display_winner(self ,true)

func lose():
	win_lose_screen.display_winner(self, false)

func reset_health():
	player_health = 10
	enemy_health = 10
	current_bullet_damage = 1
	damage = current_bullet_damage
