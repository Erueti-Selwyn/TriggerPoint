extends Node3D

# Constants
const ITEM_LERP_SPEED: float = 5
const DIST = 1000

@export var camera_lerp_speed: int

@export var used_bullet_pos: Node3D
@export var center_bullet_pos: Node3D
@export var player_blood_position: Node3D

# In game UI features
@export var win_lose_screen: Control
@export var held_item_description_label: Label3D
@export var shoot_player_label: Label3D
@export var shoot_enemy_label: Label3D
@export var player_health_icons: Array
@export var enemy_health_icons: Array

@export var inventory_root: Node3D
@export var on_screen_text_node: Label

var camera: Camera3D
var target_rotation: Vector3
var current_hover_object: Node
var previous_hover_mesh: Node
var current_hover_mesh: Node


func _ready() -> void:
	camera = $Head/Camera3D
	# Sets the necessary global variables
	GameManager.player = self
	GameManager.on_screen_text_node = on_screen_text_node
	GameManager.center_bullet_pos = center_bullet_pos
	GameManager.used_bullet_pos = used_bullet_pos
	target_rotation = camera.rotation
	GameManager.start_game()


func _process(_delta: float) -> void:
	# Updates text labels
	update_text_labels()
	# Checks mouse position
	check_mouse_position(get_viewport().get_mouse_position())
	# Checks if right click
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		inventory_root.drop_item()
		inventory_root.update_item_position()


func _input(event):
	# Checks for click
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click()


# Checks current mouse position
func check_mouse_position(mouse:Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	# Creates raycast where mouse is pointing
	var raycast_result = space.intersect_ray(params)
	if (
		raycast_result.is_empty() == false 
		and (GameManager.game_state == GameManager.GameState.DECIDING 
		and GameManager.turn_owner == GameManager.player 
		or GameManager.game_state == GameManager.GameState.GETTINGITEM)
	):
		# Gets the mesh and object of hovered object
		current_hover_mesh = find_hover_script(raycast_result.collider)
		current_hover_object = raycast_result.collider
		if not GameManager.game_state == GameManager.GameState.GETTINGITEM:
			# hoevers and unhovers the mesh
			if previous_hover_mesh  != current_hover_mesh:
				if is_instance_valid(previous_hover_mesh) and previous_hover_mesh.has_method("unhover"):
					previous_hover_mesh.unhover()
					previous_hover_mesh = null
			previous_hover_mesh = current_hover_mesh
			if is_instance_valid(current_hover_mesh) and current_hover_mesh.has_method("hover"):
				current_hover_mesh.hover()
	else:
		# Unhovers previous mesh
		if is_instance_valid(previous_hover_mesh) and previous_hover_mesh.has_method("unhover"):
				previous_hover_mesh.unhover()
				previous_hover_mesh = null
				current_hover_object = null


# Looks through children to find hover script
func find_hover_script(node):
	if node.has_method("hover"):
		return node
	for child in node.get_children():
		var hover_node = find_hover_script(child)
		if hover_node:
			return hover_node
	return null


# Called on mouse click
func click():
	# Checks if it is the players turn
	if (
		current_hover_object 
		and GameManager.game_state == GameManager.GameState.DECIDING 
		and GameManager.turn_owner == GameManager.player
	):
		# Checks what the player clicked on
		if current_hover_object.is_in_group("gun") or current_hover_object.is_in_group("item"):
			# Player clicked on gun or item
			inventory_root.click_item(current_hover_object)
		if GameManager.shotgun_node.in_hand and GameManager.loaded_bullets_array.size() > 0:
			# Player clicked on the "shoot enemy" or "shot player" buttons while holding shotgun
			if current_hover_object.is_in_group("enemy_button"):
				GameManager.shoot(GameManager.player, GameManager.enemy)
			elif current_hover_object.is_in_group("player_button"):
				GameManager.shoot(GameManager.player, GameManager.player)
		elif current_hover_object.is_in_group("player_button") or current_hover_object.is_in_group("enemy_button"):
			# Player uses item
			inventory_root.use_item()
	if (
		current_hover_object 
		and GameManager.game_state == GameManager.GameState.GETTINGITEM
	):
		if current_hover_object.is_in_group("item"):
			# Checks if clicked object is item and clicks it
			inventory_root.click_item(current_hover_object)


func update_text_labels():
	# Changes the colour of the text on the table when hovering
	if (
		GameManager.game_state == GameManager.GameState.DECIDING and 
		GameManager.turn_owner == GameManager.player and 
		current_hover_object
	):
		if current_hover_object.is_in_group("player_button"):
			shoot_player_label.modulate = GameManager.hover_text_colour
		else:
			shoot_player_label.modulate = GameManager.unhover_text_colour
		if current_hover_object.is_in_group("enemy_button"):
			shoot_enemy_label.modulate = GameManager.hover_text_colour
		else:
			shoot_enemy_label.modulate = GameManager.unhover_text_colour
	else:
		shoot_player_label.modulate = GameManager.unhover_text_colour
		shoot_enemy_label.modulate = GameManager.unhover_text_colour
	# Changes text on table depending on what is being held
	if is_instance_valid(inventory_root.held_item) and inventory_root.held_item.type == "gun" and GameManager.loaded_bullets_array.size() > 0:
		shoot_player_label.visible = true
		shoot_enemy_label.visible = true
		shoot_player_label.text = "SHOOT\nYOURSELF"
		shoot_enemy_label.text = "SHOOT\nEnemy"
	elif is_instance_valid(inventory_root.held_item) and inventory_root.held_item.type == "item":
		shoot_player_label.visible = true
		shoot_enemy_label.visible = false
		shoot_player_label.text = "Use item"
		shoot_enemy_label.text = "null"
	else:
		shoot_player_label.visible = false
		shoot_enemy_label.visible = false
	# Shows item description
	if is_instance_valid(inventory_root.held_item) and not inventory_root.held_item.is_in_group("gun"):
		held_item_description_label.visible = true
		held_item_description_label.text = inventory_root.held_item.item_description
	else:
		held_item_description_label.visible = false


# Starts players turn
func start_turn():
	GameManager.get_items()


# Calls win function
func win():
	win_lose_screen.display_winner(true)

# Calls lose function
func lose():
	win_lose_screen.display_winner(false)


# Creates blood particles for when being shot
func blood_particles():
	var blood = GameManager.blood_splatter_particle.instantiate()
	add_child(blood)
	blood.global_position = player_blood_position.global_position
	blood.emitting = true
