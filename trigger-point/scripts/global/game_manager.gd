extends Node

var bullet_gravity_scene = preload("res://scenes/bullet_gravity.tscn")
var bullet_scene = preload("res://scenes/bullet.tscn")
var blood_splatter_particle = preload("res://scenes/blood_splatter_particle.tscn")

enum TurnOwner {
	PLAYER,
	ENEMY,
}

const TurnOwnerNames = {
	TurnOwner.PLAYER: "PLAYER",
	TurnOwner.ENEMY: "ENEMY",
}

enum GameState {
	WAITING,
	DECIDING,
	SHOOTING,
	RELOADING,
	USINGITEM,
	SHOPPING,
	GAMEOVER,
}
const GameStateNames = {
	GameState.WAITING: "WAITING",
	GameState.DECIDING: "DECIDING",
	GameState.SHOOTING: "SHOOTING",
	GameState.RELOADING: "RELOADING",
	GameState.USINGITEM: "USINGITEM",
	GameState.SHOPPING: "SHOPPING",
	GameState.GAMEOVER: "GAMEOVER",
}
var game_state : GameState
var turn_owner : TurnOwner
# Player stats
var round_number: int = 1
var player_health: int = 10
var player_max_health: int = 10
var player_money: int = 0
# var player_inventory: Array = [] Maybe Change to this?

# Enemy stats
var enemy_health: int = 10
var enemy_max_health: int = 10

# Game Rules
var current_bullet_damage: int = 1
var damage: int = 1
# Bullets
var max_bullets_in_chamber: int = 6
var bullets_in_chamber: int = 6
var live_bullets: int = 3
var blank_bullets: int = 3
var loaded_bullets_array: Array = []
var used_shells : int
var used_shells_array : Array

# Temporary states
var round_won: bool = false
var shop_open: bool = false
var using_item: bool = false

var player:Node3D = null
var enemy:Node3D = null
var inventory_root:Node3D = null
var gun_node:Node3D = null

var live_bullet_pos:Node3D = null
var blank_bullet_pos:Node3D = null
var held_item_pos:Node3D = null

func start_round():
	game_state = GameState.DECIDING
	turn_owner = TurnOwner.PLAYER
	player.start_player_turn()


func end_player_turn():
	game_state = GameState.DECIDING
	turn_owner = TurnOwner.ENEMY
	enemy.start_enemy_turn()


func continue_enemy_turn():
	game_state = GameState.DECIDING
	turn_owner = TurnOwner.ENEMY


func end_enemy_turn():
	game_state = GameState.DECIDING
	turn_owner = TurnOwner.PLAYER
	player.start_player_turn()
	
func continue_player_turn():
	game_state = GameState.DECIDING
	turn_owner = TurnOwner.PLAYER


func start_shop():
	game_state = GameState.SHOPPING


func reload():
	if (
		game_state == GameState.DECIDING and 
		turn_owner == TurnOwner.PLAYER or 
		game_state == GameState.WAITING
	):
		max_bullets_in_chamber = randi_range(4,6)
		loaded_bullets_array = []
		for item in used_shells_array:
			item.queue_free()
		used_shells_array.clear()
		used_shells = 0
		for i in range(max_bullets_in_chamber):
			var rand = randi_range(1, 2)
			if rand == 1:
				loaded_bullets_array.append(true)
			else:
				loaded_bullets_array.append(false)
		show_loaded_bullets()
		game_state = GameState.RELOADING
		await get_tree().create_timer(2).timeout
		player.start_player_turn()


func shoot(target:String):
	inventory_root.drop_item()
	inventory_root.update_item_position()
	var is_live_bullet = loaded_bullets_array[0]
	game_state = GameState.SHOOTING
	await gun_node.shoot(target)
	if is_live_bullet:
		if turn_owner == TurnOwner.PLAYER:
			end_player_turn()
		elif turn_owner == TurnOwner.ENEMY:
			end_enemy_turn()
	elif not is_live_bullet:
		if turn_owner == TurnOwner.PLAYER:
			if target == "player":
				continue_player_turn()
			else:
				end_player_turn()
		elif turn_owner == TurnOwner.ENEMY:
			if target == "enemy":
				continue_enemy_turn()
			else:
				end_enemy_turn()
	inventory_root.drop_item()
	inventory_root.update_item_position()
	print(str(gun_node.in_hand))


func show_loaded_bullets():
	var current_live_bullet_count : int = 0
	var current_blank_bullet_count : int = 0
	var bullet_obj_array : Array
	# Shows loaded bullets in order
	for item in range(GameManager.loaded_bullets_array.size()):
		var bullet = bullet_gravity_scene.instantiate()
		add_child(bullet)
		var mesh = bullet.get_node("MeshInstance3D")
		var base_mat = mesh.get_active_material(0)
		var mat = base_mat.duplicate()
		bullet.rotation = Vector3(0, 0, deg_to_rad(90))
		bullet_obj_array.append(bullet)
		if GameManager.loaded_bullets_array[item] == true:
			current_live_bullet_count += 1
			mat.albedo_color = Color(1, 0, 0)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(live_bullet_pos.global_position.x, live_bullet_pos.global_position.y + 0.1, live_bullet_pos.global_position.z - (float(current_live_bullet_count)/6))
		else:
			current_blank_bullet_count += 1
			mat.albedo_color = Color(0, 0, 1)
			mesh.set_surface_override_material(0, mat)
			bullet.global_position = Vector3(blank_bullet_pos.global_position.x, blank_bullet_pos.global_position.y + 0.1, blank_bullet_pos.global_position.z + (float(current_blank_bullet_count)/6))
	await get_tree().create_timer(2).timeout
	for item in bullet_obj_array:
		item.queue_free()
	bullet_obj_array.resize(0)
