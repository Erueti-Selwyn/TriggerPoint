extends Node

var bullet_gravity_scene = preload("res://scenes/visual/bullet_gravity.tscn")
var bullet_scene = preload("res://scenes/visual/bullet.tscn")
var blood_splatter_particle = preload("res://scenes/visual/blood_splatter_particle.tscn")

var one_health_item_scene = preload("res://scenes/item/one_health_item.tscn")
var peek_item_scene = preload("res://scenes/item/peek_item.tscn")
var shuffle_item_scene = preload("res://scenes/item/shuffle_item.tscn")
var double_damage_item_scene = preload("res://scenes/item/double_damage_item.tscn")
var remove_bullet_item_scene = preload("res://scenes/item/remove_bullet_item.tscn")

enum GameState {
	WAITING,
	DECIDING,
	SHOOTING,
	RELOADING,
	USINGITEM,
	GETTINGITEM,
	SHOPPING,
	TRANSITIONING,
	GAMEOVER,
}
const GameStateNames = {
	GameState.WAITING: "WAITING",
	GameState.DECIDING: "DECIDING",
	GameState.SHOOTING: "SHOOTING",
	GameState.RELOADING: "RELOADING",
	GameState.USINGITEM: "USINGITEM",
	GameState.GETTINGITEM: "GETTINGITEM",
	GameState.SHOPPING: "SHOPPING",
	GameState.TRANSITIONING: "TRANSITIONING",
	GameState.GAMEOVER: "GAMEOVER",
}

var game_state : GameState
var turn_owner : Node3D
# Player stats
var round_number: int = 1
var player_health: int
var player_max_health: int = 5
var player_money: int = 0
# var player_inventory: Array = [] Maybe Change to this?

# Enemy stats
var enemy_health: int
var enemy_max_health: int = 5

# Game Rules
var current_bullet_damage: int = 1
var damage: int = 1
# Bullets
var max_bullets_in_chamber: int = 6
var bullets_in_chamber: int = 6
var live_bullets: int = 3
var blank_bullets: int = 3
var loaded_bullets_array: Array = []
enum BulletType {BLANK, LIVE, SLUG, CRIPPLE}

var used_shells : int
var used_shells_array : Array

# Temporary states
var round_ended: bool = false
var shop_open: bool = false
var using_item: bool = false

var one_health_item_level: int = 1
var peek_item_level: int = 1
var shuffle_item_level: int = 1
var double_damage_item_level: int = 1
var remove_bullet_item_level: int = 1

var receive_item_count: int = 0

var player: Node3D = null
var enemy: Node3D = null
var inventory_root: Node3D = null
var gun_node: Node3D = null
var shotgun_node: Node3D = null
var shop_root: Node3D = null

var live_bullet_pos: Node3D = null
var blank_bullet_pos: Node3D = null
var held_item_pos: Node3D = null
var dealing_box: Node3D = null
var dealing_table: Node3D = null
var camera: Node3D = null

var hover_text_colour:Color = Color("ffffff")
var unhover_text_colour:Color = Color("adadad")

var item_name_array:Array = [
	"double_damage",
	"one_health",
	"peek",
	"remove_bullet",
	"shuffle",
]

@onready var item_scene_dictionary = {
	"double_damage": GameManager.double_damage_item_scene, 
	"one_health": GameManager.one_health_item_scene, 
	"peek": GameManager.peek_item_scene, 
	"remove_bullet": GameManager.remove_bullet_item_scene,
	"shuffle": GameManager.shuffle_item_scene, 
}

@onready var item_name_level_dictionary:Dictionary = {
	"double_damage": GameManager.double_damage_item_level, 
	"one_health": GameManager.one_health_item_level,
	"peek": GameManager.peek_item_level,
	"remove_bullet": GameManager.remove_bullet_item_level,
	"shuffle": GameManager.shuffle_item_level,
}


func _process(_delta) -> void:
	if enemy_health <= 0 and round_ended == false and not player == null:
		player_money += 10
		enemy_health = 0
		round_ended = true
		end_round()
	if player_health <= 0 and round_ended == false and not player == null:
		player_money += 5
		enemy_health = 0
		round_ended = true
		end_round()


func start_game():
	game_state = GameState.WAITING
	current_bullet_damage = 1
	damage = current_bullet_damage
	player_health = player_max_health
	enemy_health = enemy_max_health
	turn_owner = player
	reload()


func start_turn():
	turn_owner.start_turn()


func end_player_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = enemy
		start_turn()


func continue_enemy_turn():
	if round_ended == false:
		enemy.start_turn()
		game_state = GameState.DECIDING
		turn_owner = enemy


func end_enemy_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = player
		start_turn()


func continue_player_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = player


func start_shop():
	game_state = GameState.SHOPPING
	shop_root.start_shop()


func reload():
	if (
		game_state == GameState.DECIDING and 
		turn_owner == player or 
		game_state == GameState.WAITING
	):
		loaded_bullets_array = []
		loaded_bullets_array.append(BulletType.LIVE)
		loaded_bullets_array.append(BulletType.BLANK)
		max_bullets_in_chamber = randi_range(4,6)
		for item in used_shells_array:
			item.queue_free()
		used_shells_array.clear()
		used_shells = 0
		for i in range(max_bullets_in_chamber - loaded_bullets_array.size()):
			var rand = randi_range(1, 2)
			if rand == 1:
				loaded_bullets_array.append(BulletType.LIVE)
			else:
				loaded_bullets_array.append(BulletType.BLANK)
		loaded_bullets_array.shuffle()
		show_loaded_bullets()
		game_state = GameState.RELOADING
		await get_tree().create_timer(2).timeout
		start_turn()


func shoot(shooter:Node3D, target:Node3D):
	inventory_root.drop_item()
	inventory_root.update_item_position()
	var next_bullet = loaded_bullets_array[0]
	game_state = GameState.SHOOTING
	await shotgun_node.shoot(shooter, target)
	if next_bullet == BulletType.LIVE:
		if turn_owner == player:
			end_player_turn()
		elif turn_owner == enemy:
			end_enemy_turn()
	elif next_bullet == BulletType.BLANK:
		if turn_owner == player:
			if target == player:
				continue_player_turn()
			else:
				end_player_turn()
		elif turn_owner == enemy:
			if target == enemy:
				continue_enemy_turn()
			else:
				end_enemy_turn()
	inventory_root.drop_item()
	inventory_root.update_item_position()


func show_loaded_bullets():
	var current_live_bullet_count : int = 0
	var current_blank_bullet_count : int = 0
	var bullet_obj_array : Array
	# Shows loaded bullets in order
	for item in range(loaded_bullets_array.size()):
		var bullet = bullet_gravity_scene.instantiate()
		add_child(bullet)
		var mesh = bullet.get_node("MeshInstance3D")
		var base_mat = mesh.get_active_material(0)
		var mat = base_mat.duplicate()
		bullet.rotation = Vector3(0, 0, deg_to_rad(90))
		bullet_obj_array.append(bullet)
		if loaded_bullets_array[item] == BulletType.LIVE:
			current_live_bullet_count += 1
			mat.albedo_color = Color(1, 0, 0)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(live_bullet_pos.global_position.x, live_bullet_pos.global_position.y + 0.1, live_bullet_pos.global_position.z - (float(current_live_bullet_count)/6))
		elif loaded_bullets_array[item] == BulletType.BLANK:
			current_blank_bullet_count += 1
			mat.albedo_color = Color(0, 0, 1)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(blank_bullet_pos.global_position.x, blank_bullet_pos.global_position.y + 0.1, blank_bullet_pos.global_position.z + (float(current_blank_bullet_count)/6))
	await get_tree().create_timer(2).timeout
	for item in bullet_obj_array:
		item.queue_free()
	bullet_obj_array.resize(0)


func end_round():
	await get_tree().create_timer(2).timeout
	if GameManager.game_state != GameManager.GameState.SHOPPING:
		GameManager.start_shop()


func toggle_child_collision(object : Node, condition : bool):
	for child in object.get_children():
		if child is CollisionShape3D:
			child.disabled = condition


func end_getting_item():
	game_state = GameState.WAITING
	await GameManager.dealing_table.box_open_player()
	await get_tree().create_timer(0.2).timeout
	GameManager.dealing_box.visible = false
	await GameManager.dealing_table.box_close_player()
	GameManager.game_state = GameManager.GameState.DECIDING
