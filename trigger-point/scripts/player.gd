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
@export var gun_node : Node

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

# For Mouse Hovering
const DIST = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.player = self
	GameManager.live_bullet_pos = live_bullet_pos
	GameManager.blank_bullet_pos = blank_bullet_pos
	GameManager.game_state = GameManager.GameState.WAITING
	GameManager.current_bullet_damage = 1
	GameManager.damage = GameManager.current_bullet_damage
	GameManager.player_health = GameManager.player_max_health
	GameManager.enemy_health = GameManager.enemy_max_health
	GameManager.reload()
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
	debug_label_3.text = str(GameManager.loaded_bullets_array)
	check_mouse_position(get_viewport().get_mouse_position())
	if is_instance_valid(inventory_root.held_item) and not inventory_root.held_item == gun_node:
		held_item_description_label.visible = true
		held_item_description_label.text = inventory_root.held_item.item_description
	else:
		held_item_description_label.visible = false
	if Input.is_action_just_pressed("move_up"):
		target_rotation = rotation_look_up
	elif Input.is_action_just_pressed("move_down"):
		target_rotation = rotation_look_down
	if (
		Input.is_action_just_pressed("add_item") and 
		GameManager.game_state == GameManager.GameState.DECIDING and 
		GameManager.turn_owner == GameManager.TurnOwner.PLAYER
	):
		inventory_root.add_random_item()
	if Input.is_action_just_pressed("escape"):
		inventory_root.drop_item()
		inventory_root.update_item_position()
	if Input.is_action_just_pressed("reload"):
		GameManager.reload()
	# Changes material of light bar to show whos turn it is
	if GameManager.turn_owner == GameManager.TurnOwner.PLAYER:
		player_turn_light.mesh.surface_set_material(0, light_on_mat)
		enemy_turn_light.mesh.surface_set_material(0, light_off_mat)
	if GameManager.turn_owner == GameManager.TurnOwner.ENEMY:
		enemy_turn_light.mesh.surface_set_material(0, light_on_mat)
		player_turn_light.mesh.surface_set_material(0, light_off_mat)

	# Changes the colour of the text on the table when hovering
	if (
		GameManager.game_state == GameManager.GameState.DECIDING and 
		GameManager.turn_owner == GameManager.TurnOwner.PLAYER and 
		current_hover_object
	):
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
	if is_instance_valid(inventory_root.held_item) and inventory_root.held_item.type == "gun" and GameManager.loaded_bullets_array.size() > 0:
		shoot_player_label.visible = true
		shoot_enemy_label.visible = true
		shoot_player_label.text = "Shoot \nSelf"
		shoot_enemy_label.text = "Shoot \nEnemy"
	elif is_instance_valid(inventory_root.held_item) and inventory_root.held_item.type == "item":
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
	if (
		raycast_result.is_empty() == false and 
		GameManager.game_state == GameManager.GameState.DECIDING and 
		GameManager.turn_owner == GameManager.TurnOwner.PLAYER
	):
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
	if (
		current_hover_object and 
		GameManager.game_state == GameManager.GameState.DECIDING and 
		GameManager.turn_owner == GameManager.TurnOwner.PLAYER
	):
		if current_hover_object.is_in_group("gun") or current_hover_object.is_in_group("item"):
			inventory_root.click_item(current_hover_object)
		if gun_node.in_hand and GameManager.loaded_bullets_array.size() > 0: 
			if current_hover_object.is_in_group("enemy_button"):
				GameManager.shoot("enemy")
			elif current_hover_object.is_in_group("player_button"):
				GameManager.shoot("player")
		elif current_hover_object.is_in_group("player_button") or current_hover_object.is_in_group("enemy_button"):
			inventory_root.use_item()


func start_player_turn():
	GameManager.game_state = GameManager.GameState.WAITING
	GameManager.turn_owner = GameManager.TurnOwner.PLAYER
	dealing_table.item_open_player()
	await get_tree().create_timer(2.5).timeout
	await dealing_table.item_close_player()
	GameManager.game_state = GameManager.GameState.DECIDING
	inventory_root.add_random_item()

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
	GameManager.start_shop()
