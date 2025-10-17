extends Node

var shotgun_shell_scene = preload("res://scenes/visual/shotgun_shell.tscn")
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

var game_state: GameState
var turn_owner: Node3D
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
var base_damage: int = 1
var damage: int = 1
# Bullets
var max_bullets_in_chamber: int = 6
var bullets_in_chamber: int = 6
var live_bullets: int = 3
var blank_bullets: int = 3
var loaded_bullets_array: Array = []
var used_bullets_array: Array = []
enum BulletType {BLANK, LIVE}

var used_shells : int
var used_shells_array : Array

# Temporary states
var round_ended: bool = false
var shop_open: bool = false
var using_item: bool = false

var receive_item_count: int = 0

var player: Node3D
var enemy: Node3D

var inventory_root: Node3D
var shotgun_node: Node3D
var shop_root: Node3D
var on_screen_text_node: Label

var center_bullet_pos: Node3D
var used_bullet_pos: Node3D
var held_item_pos: Node3D
var dealing_box: Node3D
var dealing_table: Node3D
var camera: Node3D

var hover_text_colour: Color = Color("ffffff")
var unhover_text_colour: Color = Color("adadad")
var gun_guide_text_count: int = 0
var shoot_someone_text_count: int = 0
var item_guide_text_count: int = 0

var item_name_array:Array = [
	"double_damage",
	"one_health",
	"peek",
	"remove_bullet",
	"shuffle",
]

@onready var item_scene_dictionary = {
	"double_damage": double_damage_item_scene, 
	"one_health": one_health_item_scene, 
	"peek": peek_item_scene, 
	"remove_bullet": remove_bullet_item_scene,
	"shuffle": shuffle_item_scene, 
}


func _process(_delta) -> void:
	if enemy_health <= 0 and round_ended == false and not player == null:
		player_money += 10
		enemy_health = 0
		round_ended = true
		player.win()
	if player_health <= 0 and round_ended == false and not player == null:
		player_money += 5
		enemy_health = 0
		round_ended = true
		player.lose()
	if round_ended == false and loaded_bullets_array.size() <= 0:
		turn_owner = player
		for item in used_bullets_array:
			item.queue_free()
		used_bullets_array = []
		reload()

func start_game():
	game_state = GameState.WAITING
	base_damage = 1
	damage = base_damage
	player_health = player_max_health
	enemy_health = enemy_max_health
	turn_owner = player
	reload()


func start_turn():
	if not turn_owner:
		return
	print(str(turn_owner))
	turn_owner.start_turn()


func end_player_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = enemy
		start_turn()


func continue_enemy_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = enemy
		start_turn()


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


func get_items():
	if inventory_root.inventory_has_empty_slot():
		dealing_box.visible = false
		game_state = GameState.WAITING
		await dealing_table.box_open_player()
		dealing_box.visible = true
		await dealing_table.box_close_player()
		on_screen_text_node.get_item_text()
		game_state = GameState.GETTINGITEM
		receive_item_count = 2
		inventory_root.add_random_item()
	else:
		GameManager.game_state = GameManager.GameState.DECIDING
		GameManager.turn_owner = GameManager.player
		on_screen_text_node.gun_guide_text()


func reload():
	if (
		game_state == GameState.DECIDING and 
		turn_owner == player or 
		game_state == GameState.WAITING
	):
		for item in used_bullets_array:
			item.queue_free()
		used_bullets_array = []
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
		game_state = GameState.RELOADING
		await show_loaded_bullets()
		start_turn()


func shoot(shooter:Node3D, target:Node3D):
	inventory_root.drop_item()
	inventory_root.update_item_position()
	var next_bullet = loaded_bullets_array[0]
	game_state = GameState.SHOOTING
	await shotgun_node.shoot(shooter, target, next_bullet)
	print("finished shooting")
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
	var bullet_obj_array : Array
	var blank_count: int = loaded_bullets_array.count(BulletType.BLANK)
	var live_count: int = loaded_bullets_array.count(BulletType.LIVE)
	if blank_count and live_count and on_screen_text_node:
		on_screen_text_node.loaded_bullets_text(live_count, blank_count)
	var bullet_spacing: float = 0.2
	var starting_x: float = ((loaded_bullets_array.size() - 1) * bullet_spacing) / 2
	var instantiated_bullet_count: int = 0
	if not center_bullet_pos:
		return
	for item in range(blank_count):
		var bullet = shotgun_shell_scene.instantiate()
		add_child(bullet)
		bullet.global_position = Vector3(center_bullet_pos.global_position.x, center_bullet_pos.global_position.y, center_bullet_pos.global_position.z - starting_x + (bullet_spacing * instantiated_bullet_count))
		bullet.get_child(0).set_colour(false)
		bullet.rotation = Vector3(0, deg_to_rad(180), deg_to_rad(90))
		bullet_obj_array.append(bullet)
		instantiated_bullet_count += 1
	
	for item in range(live_count):
		var bullet = shotgun_shell_scene.instantiate()
		add_child(bullet)
		bullet.global_position = Vector3(center_bullet_pos.global_position.x, center_bullet_pos.global_position.y, center_bullet_pos.global_position.z - starting_x + (bullet_spacing * instantiated_bullet_count))
		bullet.get_child(0).set_colour(true)
		bullet.rotation = Vector3(0, deg_to_rad(180), deg_to_rad(90))
		bullet_obj_array.append(bullet)
		instantiated_bullet_count += 1
	var start = Time.get_ticks_msec()
	await get_tree().create_timer(3, false, true).timeout
	print("Elapsed:", (Time.get_ticks_msec() - start) / 1000.0)
	print("finished showing")
	if blank_count and live_count and on_screen_text_node:
		on_screen_text_node.text_disseapear()
	for item in bullet_obj_array:
		item.queue_free()
	bullet_obj_array.resize(0)


func toggle_child_collision(object : Node, condition : bool):
	for child in object.get_children():
		if child is CollisionShape3D:
			child.disabled = condition


func end_getting_item():
	game_state = GameState.WAITING
	await dealing_table.box_open_player()
	dealing_box.visible = false
	await dealing_table.box_close_player()
	GameManager.game_state = GameManager.GameState.DECIDING
	GameManager.turn_owner = GameManager.player
	on_screen_text_node.gun_guide_text()
	
