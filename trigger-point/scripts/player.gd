extends Node3D

# DEBUG STUFF

# DEBUG STUFF

var camera: Camera3D = null
@export var rotation_shop : Vector3
@export var camera_lerp_speed : int
@export var item_lerp_speed : float
@export var gun_lerp_speed : float

@export var live_bullet_pos : Node3D
@export var blank_bullet_pos : Node3D
@export var player_blood_position: Node3D

# In game UI features
@export var win_lose_screen : Control
@export var held_item_description_label : Label3D
@export var shoot_player_label : Label3D
@export var shoot_enemy_label : Label3D
@export var player_scoreboard_label : Label3D
@export var enemy_socreboard_label : Label3D
@export var player_health_icons : Array
@export var enemy_health_icons : Array

@export var inventory_root: Node3D
@export var shop_root: Node3D

var target_rotation : Vector3
var current_hover_object : Node
var previous_hover_mesh : Node
var current_hover_mesh : Node

# For Mouse Hovering
const DIST = 1000

var debug_label_1: Label = null
var debug_label_2: Label = null
var debug_label_3: Label = null
var debug_label_4: Label = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug_label_1 = $CanvasLayer/GUI/HBoxContainer/VBoxContainer/Debug1
	debug_label_2 = $CanvasLayer/GUI/HBoxContainer/VBoxContainer/Debug2
	debug_label_3 = $CanvasLayer/GUI/HBoxContainer/VBoxContainer/Debug3
	debug_label_4 = $CanvasLayer/GUI/HBoxContainer/VBoxContainer/Debug4
	camera = $Head/Camera3D
	GameManager.player = self
	GameManager.live_bullet_pos = live_bullet_pos
	GameManager.blank_bullet_pos = blank_bullet_pos
	target_rotation = camera.rotation
	GameManager.start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	GameManager.live_bullets = GameManager.loaded_bullets_array.count(GameManager.BulletType.LIVE)
	GameManager.blank_bullets = GameManager.loaded_bullets_array.count(GameManager.BulletType.BLANK)
	update_text_labels()
	check_mouse_position(get_viewport().get_mouse_position())

	if (
		Input.is_action_just_pressed("add_item") and 
		GameManager.game_state == GameManager.GameState.DECIDING and 
		GameManager.turn_owner == GameManager.player
	):
		inventory_root.add_random_item()
	if Input.is_action_just_pressed("escape"):
		if GameManager.game_state == GameManager.GameState.SHOPPING:
			shop_root.drop_shop_items()
		else:
			inventory_root.drop_item()
		inventory_root.update_item_position()
	if Input.is_action_just_pressed("reload"):
		GameManager.reload()


func _physics_process(delta: float) -> void:
	# Changes the rotation of camera to target rotation
	if GameManager.game_state == GameManager.GameState.SHOPPING:
		var tween = create_tween()
		tween.tween_property(camera, "rotation", rotation_shop, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
	elif not GameManager.game_state == GameManager.GameState.TRANSITIONING:
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
		(GameManager.game_state == GameManager.GameState.DECIDING and 
		GameManager.turn_owner == GameManager.player or
		GameManager.game_state == GameManager.GameState.SHOPPING or
		GameManager.game_state == GameManager.GameState.GETTINGITEM)
	):
		current_hover_mesh = find_hover_script(raycast_result.collider)
		current_hover_object = raycast_result.collider
		if not GameManager.game_state == GameManager.GameState.GETTINGITEM:
			if previous_hover_mesh  != current_hover_mesh:
				if is_instance_valid(previous_hover_mesh) and previous_hover_mesh.has_method("unhover"):
					previous_hover_mesh.unhover()
					previous_hover_mesh = null
			previous_hover_mesh = current_hover_mesh
			if is_instance_valid(current_hover_mesh) and current_hover_mesh.has_method("hover"):
				current_hover_mesh.hover()
	else:
		if is_instance_valid(previous_hover_mesh) and previous_hover_mesh.has_method("unhover"):
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
		GameManager.turn_owner == GameManager.player
	):
		if current_hover_object.is_in_group("gun") or current_hover_object.is_in_group("item"):
			inventory_root.click_item(current_hover_object)
		if GameManager.shotgun_node.in_hand and GameManager.loaded_bullets_array.size() > 0: 
			if current_hover_object.is_in_group("enemy_button"):
				GameManager.shoot(GameManager.player, GameManager.enemy)
			elif current_hover_object.is_in_group("player_button"):
				GameManager.shoot(GameManager.player, GameManager.player)
		elif current_hover_object.is_in_group("player_button") or current_hover_object.is_in_group("enemy_button"):
			inventory_root.use_item()
	elif current_hover_object and GameManager.game_state == GameManager.GameState.SHOPPING:
			if current_hover_object.is_in_group("shop_item"):
				shop_root.click_item(current_hover_object)
			elif current_hover_object.is_in_group("buy_shop_button"):
				shop_root.buy_item()
			elif current_hover_object.is_in_group("leave_shop_button"):
				shop_root.end_shop()
			elif current_hover_object.is_in_group("reroll_shop_button"):
				shop_root.reroll_shop()

	if (
		current_hover_object and 
		GameManager.game_state == GameManager.GameState.GETTINGITEM
	):
		if current_hover_object.is_in_group("item"):
			inventory_root.click_item(current_hover_object)


func update_text_labels():
	debug_label_1.text = str(GameManager.GameStateNames[GameManager.game_state])
	debug_label_3.text = str(GameManager.loaded_bullets_array)
	debug_label_2.text = str(GameManager.turn_owner)
	# Changes health symbols
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
	if (
		GameManager.game_state == GameManager.GameState.SHOPPING and 
		is_instance_valid(current_hover_object)
	):
		if current_hover_object.is_in_group("reroll_shop_button"):
			shop_root.reroll_button_hover(true)
		else:
			shop_root.reroll_button_hover(false)
		if current_hover_object.is_in_group("buy_shop_button"):
			shop_root.buy_button_hover(true)
		else:
			shop_root.buy_button_hover(false)
		if current_hover_object.is_in_group("leave_shop_button"):
			shop_root.leave_button_hover(true)
		else:
			shop_root.leave_button_hover(false)
	# Changes text on table depending on what is being held
	if is_instance_valid(inventory_root.held_item) and inventory_root.held_item.type == "gun" and GameManager.loaded_bullets_array.size() > 0:
		shoot_player_label.visible = true
		shoot_enemy_label.visible = true
		shoot_player_label.text = "YOU"
		shoot_enemy_label.text = "Enemy"
	elif is_instance_valid(inventory_root.held_item) and inventory_root.held_item.type == "item":
		shoot_player_label.visible = true
		shoot_enemy_label.visible = false
		shoot_player_label.text = "Use item\non Self"
		shoot_enemy_label.text = "null"
	else:
		shoot_player_label.visible = false
		shoot_enemy_label.visible = false
	if is_instance_valid(inventory_root.held_item) and not inventory_root.held_item.is_in_group("gun"):
		held_item_description_label.visible = true
		if inventory_root.held_item.item_level == 1:
			held_item_description_label.text = inventory_root.held_item.item_description
		elif inventory_root.held_item.item_level == 2:
			held_item_description_label.text = inventory_root.held_item.upgraded_description
	else:
		held_item_description_label.visible = false


func start_turn():
	print("started turn")
	GameManager.game_state = GameManager.GameState.DECIDING
	GameManager.turn_owner = GameManager.player


func end_shop():
	GameManager.game_state = GameManager.GameState.TRANSITIONING
	var tween = create_tween()
	tween.tween_property(camera, "rotation", target_rotation, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	GameManager.game_state = GameManager.GameState.WAITING
	


func win():
	win_lose_screen.display_winner(self ,true)


func lose():
	win_lose_screen.display_winner(self, false)


func reset_health():
	GameManager.player_health = GameManager.player_max_health
	GameManager.enemy_health = GameManager.player_max_health
	GameManager.damage = 1
	GameManager.current_bullet_damage = GameManager.damage


func blood_particles():
	var blood = GameManager.blood_splatter_particle.instantiate()
	add_child(blood)
	blood.global_position = player_blood_position.global_position
	blood.emitting = true
