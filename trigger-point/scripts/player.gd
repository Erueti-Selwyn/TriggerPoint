extends Node3D

# DEBUG STUFF
@export var debug_label_3 : Label
@export var debug_label_4 : Label
# DEBUG STUFF

# ASSETS
var blood_splatter_particle = preload("res://scenes/blood_splatter_particle.tscn")
var bullet_scene = preload("res://scenes/bullet.tscn")
var bullet_gravity_scene = preload("res://scenes/bullet_gravity.tscn")
var light_on_mat = preload("res://materials/light_glow_material.tres")
var light_off_mat = preload("res://materials/light_off_material.tres")
# ASSETS

@export var camera : Node3D
@export var rotation_look_up : Vector3
@export var rotation_look_down : Vector3
@export var rotation_shop : Vector3
@export var camera_lerp_speed : int
@export var item_lerp_speed : float
@export var gun_lerp_speed : float
@export var held_item_pos : Node3D
@export var gun_node : Node
@export var shoot_player_transform : Node3D
@export var shoot_enemy_transform : Node3D

var shoot_target_transform : Node3D
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

@export var inventory_root: Node3D
# Table Animation
@export var dealing_table : Node3D


var target_rotation : Vector3
var current_hover_object : Node
var previous_hover_mesh : Node
var current_hover_mesh : Node

var held_item : Node

# For Mouse Hovering
const DIST = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_state = GameManager.GameState.WAITING
	GameManager.current_bullet_damage = 1
	GameManager.damage = GameManager.current_bullet_damage
	GameManager.player_health = GameManager.player_max_health
	GameManager.enemy_health = GameManager.enemy_max_health
	reload()
	target_rotation = rotation_look_up

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	GameManager.live_bullets = GameManager.loaded_bullets_array.count(true)
	GameManager.blank_bullets = GameManager.loaded_bullets_array.count(false)
	current_damage_label.text = ("Damage: " + str(GameManager.current_bullet_damage))
	if GameManager.player_health <= 0 and not GameManager.game_state == GameManager.GameState.SHOPPING:
		GameManager.player_health = 0
		GameManager.player_money += 5
		end_round()
	if GameManager.enemy_health <= 0 and not GameManager.game_state == GameManager.GameState.GAMEOVER:
		GameManager.enemy_health = 0
		GameManager.player_money += 10
		end_round()
	player_score_label.text = str(GameManager.player_health)
	enemy_score_label.text = str(GameManager.enemy_health)
	debug_label_3.text = str(held_item)
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
	if Input.is_action_just_pressed("add_item") and GameManager.game_state == GameManager.GameState.PLAYERTURN:
		inventory_root.add_random_item()
	if Input.is_action_just_pressed("escape"):
		gun_node.in_hand = false
		inventory_root.drop_item()
		inventory_root.update_item_position()
	if Input.is_action_just_pressed("reload"):
		reload()
	# Changes material of light bar to show whos turn it is
	if GameManager.game_state == GameManager.GameState.PLAYERTURN:
		player_turn_light.mesh.surface_set_material(0, light_on_mat)
		enemy_turn_light.mesh.surface_set_material(0, light_off_mat)
	if GameManager.game_state == GameManager.GameState.ENEMYTURN:
		enemy_turn_light.mesh.surface_set_material(0, light_on_mat)
		player_turn_light.mesh.surface_set_material(0, light_off_mat)

	# Changes the colour of the text on the table when hovering
	if GameManager.game_state == GameManager.GameState.PLAYERTURN and current_hover_object:
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
	if is_instance_valid(held_item) and held_item.type == "gun" and GameManager.loaded_bullets_array.size() > 0:
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
	if GameManager.game_state == GameManager.GameState.SHOOTING:
		camera.rotation = camera.rotation.lerp(rotation_look_up, clamp(delta * camera_lerp_speed, 0.0, 1.0))
	elif GameManager.game_state == GameManager.GameState.SHOPPING:
		var tween = create_tween()
		tween.tween_property(camera, "rotation", rotation_shop, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
	else:
		camera.rotation = camera.rotation.lerp(target_rotation, clamp(delta * camera_lerp_speed, 0.0, 1.0))
	# Creates a var of the item in hand
	if gun_node.in_hand:
		held_item = gun_node
	else:
		held_item = null
		for item in inventory_root.inventory:
			if is_instance_valid(item) and item.in_hand:
				held_item = item
				break
	# Putting gun at shooting position when shooting
	if GameManager.game_state == GameManager.GameState.SHOOTING:
		gun_node.move_to(shoot_target_transform.global_position, shoot_target_transform.rotation, gun_lerp_speed)
	elif gun_node.in_hand:
		gun_node.move_to(held_item_pos.global_position, Vector3(0, 0, 0), gun_lerp_speed)
		toggle_child_collision(gun_node, true)
	else:
		gun_node.move_to(gun_node.original_pos, gun_node.original_rot, gun_lerp_speed)
		toggle_child_collision(gun_node, false)

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
	if raycast_result.is_empty() == false and GameManager.game_state == GameManager.GameState.PLAYERTURN:
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
			break


func click():
	if current_hover_object and GameManager.game_state == GameManager.GameState.PLAYERTURN:
		if current_hover_object.is_in_group("gun"):
			gun_node.in_hand = true
			inventory_root.drop_item()
			inventory_root.update_item_position()
		elif current_hover_object.is_in_group("item"):
			gun_node.in_hand = false
			inventory_root.click_item(current_hover_object)
		if gun_node.in_hand and GameManager.loaded_bullets_array.size() > 0: 
			if current_hover_object.is_in_group("enemy_button"):
				player_shoot("enemy", shoot_enemy_transform)
			elif current_hover_object.is_in_group("player_button"):
				player_shoot("player", shoot_player_transform)
		elif current_hover_object.is_in_group("player_button") or current_hover_object.is_in_group("enemy_button"):
			inventory_root.use_item()


func player_shoot(target_name : String, player_shoot_target : Node3D):
	gun_node.in_hand = false
	inventory_root.drop_item()
	inventory_root.update_item_position()
	# Checks if turn continues
	var is_live_bullet = await shoot_gun(target_name, player_shoot_target)
	if target_name == "player":
		if is_live_bullet == true:
			start_enemy_turn()
		else:
			GameManager.game_state = GameManager.GameState.PLAYERTURN
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
	GameManager.game_state = GameManager.GameState.SHOOTING
	shoot_target_transform = target_node
	# Checks if bullet was live or blank
	await get_tree().create_timer(1.5, false).timeout
	var is_live_bullets
	if GameManager.loaded_bullets_array[0] == true:
		gun_node.play_sound_shot()
		var blood = blood_splatter_particle.instantiate()
		add_child(blood)
		blood.global_position = Vector3(target_node.global_position.x, target_node.global_position.y + 0.4, target_node.global_position.z)
		blood.emitting = true
		is_live_bullets = true
		if target_name == "player":
			GameManager.player_health -= GameManager.damage
		elif target_name == "enemy":
			GameManager.enemy_health -= GameManager.damage
		GameManager.damage += 1
		GameManager.current_bullet_damage = GameManager.damage
	else:
		gun_node.play_sound_click()
		is_live_bullets = false
	GameManager.loaded_bullets_array.remove_at(0)
	# Waits for animation to finish
	# Add animation later
	await get_tree().create_timer(1, false).timeout
	gun_node.play_sound_cock()
	var bullet = bullet_gravity_scene.instantiate()
	add_child(bullet)
	var mesh = bullet.get_node("MeshInstance3D")
	var base_mat = mesh.get_active_material(0)
	var mat = base_mat.duplicate()
	if is_live_bullets:
		mat.albedo_color = Color(1, 0, 0)
	else:
		mat.albedo_color = Color(0, 0, 1)
	mesh.set_surface_override_material(0, mat)
	bullet.global_position = Vector3(live_bullet_pos.global_position.x, live_bullet_pos.global_position.y + 0.1, live_bullet_pos.global_position.z - (float(GameManager.used_shells)/6))
	bullet.rotation = Vector3(0, 0, deg_to_rad(90))
	GameManager.used_shells_array.append(bullet)
	GameManager.used_shells += 1
	return(is_live_bullets)


func reload():
	if GameManager.game_state == GameManager.GameState.PLAYERTURN or GameManager.game_state == GameManager.GameState.WAITING:
		GameManager.game_state = GameManager.GameState.RELOADING
		GameManager.max_bullets_in_chamber = randi_range(4,6)
		GameManager.loaded_bullets_array = []
		for item in GameManager.used_shells_array:
			item.queue_free()
		GameManager.used_shells_array.clear()
		GameManager.used_shells = 0
		for i in range(GameManager.max_bullets_in_chamber):
			var rand = randi_range(1, 2)
			if rand == 1:
				GameManager.loaded_bullets_array.append(true)
			else:
				GameManager.loaded_bullets_array.append(false)
		show_loaded_bullets()


func show_loaded_bullets():
	var current_live_bullet_count : int = 0
	var current_blank_bullet_count : int = 0
	var bullet_obj_array : Array
	# Shows loaded bullets in order
	for item in range(GameManager.loaded_bullets_array.size()):
		if GameManager.loaded_bullets_array[item] == true:
			current_live_bullet_count += 1
			var bullet = bullet_gravity_scene.instantiate()
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
			var bullet = bullet_gravity_scene.instantiate()
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


func start_enemy_turn():
	if GameManager.game_state != GameManager.GameState.GAMEOVER and GameManager.game_state != GameManager.GameState.SHOPPING and GameManager.player_health > 0 and GameManager.enemy_health > 0:
		if GameManager.loaded_bullets_array.size() > 0:
			GameManager.game_state = GameManager.GameState.ENEMYTURN
			await get_tree().create_timer(1, false).timeout
			var rand = randi_range(1, 2)
			if rand == 1:
				# Enemy shoots self
				enemy_shoot("enemy", shoot_enemy_transform)
			elif rand == 2:
				# Enemy shoots you
				enemy_shoot("player", shoot_player_transform)
		else:
			GameManager.game_state = GameManager.GameState.WAITING
			reload()


func start_player_turn():
	GameManager.game_state = GameManager.GameState.PLAYERTURN
	dealing_table.item_open_player()
	await get_tree().create_timer(2.5).timeout
	inventory_root.add_random_item()
	dealing_table.item_close_player()


func win():
	win_lose_screen.display_winner(self ,true)


func lose():
	win_lose_screen.display_winner(self, false)


func reset_health():
	GameManager.player_health = GameManager.player_max_health
	GameManager.enemy_health = GameManager.player_max_health
	GameManager.damage = 1
	GameManager.current_bullet_damage = GameManager.damage


func end_round():
	await get_tree().create_timer(2).timeout
	GameManager.game_state = GameManager.GameState.SHOPPING
