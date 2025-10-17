extends Node

# Preload resources
var shotgun_shell_scene = preload("res://scenes/visual/shotgun_shell.tscn")
var blood_splatter_particle = preload("res://scenes/visual/blood_splatter_particle.tscn")
var one_health_item_scene = preload("res://scenes/item/one_health_item.tscn")
var peek_item_scene = preload("res://scenes/item/peek_item.tscn")
var shuffle_item_scene = preload("res://scenes/item/shuffle_item.tscn")
var double_damage_item_scene = preload("res://scenes/item/double_damage_item.tscn")
var remove_bullet_item_scene = preload("res://scenes/item/remove_bullet_item.tscn")

# Enums
enum GameState {
	WAITING,
	DECIDING,
	SHOOTING,
	RELOADING,
	USINGITEM,
	GETTINGITEM,
	GAMEOVER,
}
enum BulletType {
	BLANK,
	LIVE,
	}

# Constants
const GameStateNames = {
	GameState.WAITING: "WAITING",
	GameState.DECIDING: "DECIDING",
	GameState.SHOOTING: "SHOOTING",
	GameState.RELOADING: "RELOADING",
	GameState.USINGITEM: "USINGITEM",
	GameState.GETTINGITEM: "GETTINGITEM",
	GameState.GAMEOVER: "GAMEOVER",
}

# Variables
var game_state: GameState
var turn_owner: Node3D
var round_ended: bool = false

# Player variables
var player: Node3D
var camera: Node3D
var round_number: int = 1
var player_health: int
var player_max_health: int = 5
var player_money: int = 0

# Enemy variables
var enemy: Node3D
var enemy_health: int
var enemy_max_health: int = 5

# Game Rules
var base_damage: int = 1
var damage: int = 1

# Gun
var shotgun_node: Node3D
var center_bullet_pos: Node3D
var used_bullet_pos: Node3D
var loaded_bullets_array: Array = []
var used_bullets_array: Array = []
var max_bullets_in_chamber: int = 6
var bullets_in_chamber: int = 6
var live_bullets: int = 3
var blank_bullets: int = 3
var used_shells : int

# Inventory
var inventory_root: Node3D
var held_item_pos: Node3D
var dealing_box: Node3D
var dealing_table: Node3D
var receive_item_count: int = 0
var item_name_array:Array = [
	"double_damage",
	"one_health",
	"peek",
	"remove_bullet",
	"shuffle",
]

# UI
var hover_text_colour: Color = Color("ffffff")
var unhover_text_colour: Color = Color("adadad")
var on_screen_text_node: Label
var gun_guide_text_count: int = 0
var shoot_someone_text_count: int = 0
var item_guide_text_count: int = 0

# @onready variables
@onready var item_scene_dictionary = {
	"double_damage": double_damage_item_scene, 
	"one_health": one_health_item_scene, 
	"peek": peek_item_scene, 
	"remove_bullet": remove_bullet_item_scene,
	"shuffle": shuffle_item_scene, 
}


func _process(_delta) -> void:
	# Current blank and live bullet count
	live_bullets = loaded_bullets_array.count(BulletType.LIVE)
	blank_bullets = loaded_bullets_array.count(BulletType.BLANK)
	# Game ended detection
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
	# Empty gun detection
	if round_ended == false and loaded_bullets_array.size() <= 0:
		turn_owner = player
		for item in used_bullets_array:
			item.queue_free()
		used_bullets_array = []
		reload()


# Starts the game
func start_game():
	round_ended = false
	game_state = GameState.WAITING
	base_damage = 1
	damage = base_damage
	player_health = player_max_health
	enemy_health = enemy_max_health
	turn_owner = player
	reload()


# Calls the start turn function of the turn owner
func start_turn():
	if not turn_owner:
		return
	turn_owner.start_turn()


# Continues the players turn
func continue_player_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = player


# Ends the players turn
func end_player_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = enemy
		start_turn()


# Continues enemy turn
func continue_enemy_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = enemy
		start_turn()


# Ends enemy turn
func end_enemy_turn():
	if round_ended == false:
		game_state = GameState.DECIDING
		turn_owner = player
		start_turn()


# Called when player needs to recive items
func get_items():
	if inventory_root.inventory_has_empty_slot():
		# Begins item recive process if the player has empty slots
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
		# Starts players turn if there is no empty slots
		GameManager.game_state = GameManager.GameState.DECIDING
		GameManager.turn_owner = GameManager.player
		on_screen_text_node.gun_guide_text()


# Called to reset all bullets in the gun
func reload():
	if (
		((game_state == GameState.DECIDING and 
		turn_owner == player) or 
		(game_state == GameState.WAITING)) and
		not round_ended == true
	):
		# Removes the previous bullet shells on the table
		for item in used_bullets_array:
			item.queue_free()
		# Resets used and loaded bullets array
		used_bullets_array = []
		loaded_bullets_array = []
		# Adds a live and blank so that there are at least on of each
		loaded_bullets_array.append(BulletType.LIVE)
		loaded_bullets_array.append(BulletType.BLANK)
		# Makes random chamber size
		max_bullets_in_chamber = randi_range(4,6)
		used_shells = 0
		# Makes a bullet for each remaining slot in chamber size
		for i in range(max_bullets_in_chamber - loaded_bullets_array.size()):
			var rand = randi_range(1, 2)
			if rand == 1:
				# Adds live bullet
				loaded_bullets_array.append(BulletType.LIVE)
			else:
				# Adds blank bullet
				loaded_bullets_array.append(BulletType.BLANK)
		# Shuffles bullets
		loaded_bullets_array.shuffle()
		game_state = GameState.RELOADING
		await show_loaded_bullets()
		start_turn()


# Begins the shooting of gun
func shoot(shooter:Node3D, target:Node3D):
	# Drops all items and updates their positions
	inventory_root.drop_item()
	inventory_root.update_item_position()
	# Gets the next bullet in the chamber
	var next_bullet = loaded_bullets_array[0]
	game_state = GameState.SHOOTING
	# Awaits for the gun to finish shooting animation
	await shotgun_node.shoot(shooter, target, next_bullet)
	# Changes who's turn it becomes depending on if the bullet was live, and who shot who
	if next_bullet == BulletType.LIVE:
		# If the byllet is live end their turn
		if turn_owner == player:
			end_player_turn()
		elif turn_owner == enemy:
			end_enemy_turn()
	elif next_bullet == BulletType.BLANK:
		# If they shot themselves with a blank, their turn continues.
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
	# Drops all items and updates their positions
	inventory_root.drop_item()
	inventory_root.update_item_position()


# Shows the bullets that are loaded into the gun
func show_loaded_bullets():
	var bullet_obj_array : Array
	# Counts live and blank bullets currently loaded
	var blank_count: int = loaded_bullets_array.count(BulletType.BLANK)
	var live_count: int = loaded_bullets_array.count(BulletType.LIVE)
	# Bullet spacing for distance between bullets and starting x to get the x offset from center
	var bullet_spacing: float = 0.2
	var starting_x: float = ((loaded_bullets_array.size() - 1) * bullet_spacing) / 2
	# Current amount of bullets instantiated
	var instantiated_bullet_count: int = 0
	# Makes the loaded bullets text appear on the UI
	if blank_count and live_count and on_screen_text_node:
		on_screen_text_node.loaded_bullets_text(live_count, blank_count)
	# Checks if center_bullet_pos is not null
	if not center_bullet_pos:
		return
	# For each blank bullet, a blank bullet is instatiated on the table
	for item in range(blank_count):
		# Instatiates bullet
		var bullet = shotgun_shell_scene.instantiate()
		player.add_child(bullet)
		# Places bullet at center location offset by the starting x, and how many bullets have been instantiated
		bullet.global_position = center_bullet_pos.global_position - Vector3(0, 0, -starting_x + (bullet_spacing * instantiated_bullet_count))
		# Changes colour of bullet to blue for blank
		bullet.get_child(0).set_colour(false)
		bullet.rotation = Vector3(0, deg_to_rad(180), deg_to_rad(90))
		# Adds bullet to an array so it can be destroyed once finished
		bullet_obj_array.append(bullet)
		instantiated_bullet_count += 1
	# For each live bullet, a live bullet is instatiated on the table
	for item in range(live_count):
		# Instatiates bullet
		var bullet = shotgun_shell_scene.instantiate()
		player.add_child(bullet)
		# Places bullet at center location offset by the starting x, and how many bullets have been instantiated
		bullet.global_position = center_bullet_pos.global_position - Vector3(0, 0, -starting_x + (bullet_spacing * instantiated_bullet_count))
		# Changes colour of bullet to red for live
		bullet.get_child(0).set_colour(true)
		bullet.rotation = Vector3(0, deg_to_rad(180), deg_to_rad(90))
		# Adds bullet to an array so it can be destroyed once finished
		bullet_obj_array.append(bullet)
		instantiated_bullet_count += 1
	# Await so that player can see what bullets are loaded in the shotgun
	await get_tree().create_timer(3, false, true).timeout
	# Makes the UI text dissapear once finished
	if blank_count and live_count and on_screen_text_node:
		on_screen_text_node.text_disseapear()
	# Deletes all bullets that were just instatiated
	for item in bullet_obj_array:
		if is_instance_valid(item):
			item.queue_free()
	# Resets size of the arary to 0
	bullet_obj_array.resize(0)


# Finds a CollisionShape3D in child and disables it
func toggle_child_collision(object : Node, condition : bool):
	for child in object.get_children():
		if child is CollisionShape3D:
			child.disabled = condition


# Called once player has finished collecting items
func end_getting_item():
	game_state = GameState.WAITING
	# Plays animation to remove box from the table
	await dealing_table.box_open_player()
	dealing_box.visible = false
	await dealing_table.box_close_player()
	# Beigs player turn
	GameManager.game_state = GameManager.GameState.DECIDING
	GameManager.turn_owner = GameManager.player
	# Shows gun guide text on UI
	on_screen_text_node.gun_guide_text()
