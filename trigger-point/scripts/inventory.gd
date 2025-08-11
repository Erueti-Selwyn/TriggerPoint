extends Node3D
# Assets
var one_health_item_scene = preload("res://scenes/item/one_health_item.tscn")
var peek_item_scene = preload("res://scenes/item/peek_item.tscn")
var shuffle_item_scene = preload("res://scenes/item/shuffle_item.tscn")
var double_damage_item_scene = preload("res://scenes/item/double_damage_item.tscn")
var remove_bullet_item_scene = preload("res://scenes/item/remove_bullet_item.tscn")

# Constants
const INVENTORY_SIZE:int = 4

# Variables
@export var held_item_pos: Node3D
@export var gun_node: Node3D
@export var debug_1: Label
@export var debug_2: Label
var inventory:Array = [null, null, null, null]
var slots_nodes:Array = []
var item_scene_array:Array = []
var item_lerp_speed:float = 0.05
var held_item: Node3D


func _ready():
	item_scene_array = [
		one_health_item_scene, 
		peek_item_scene, 
		shuffle_item_scene, 
		double_damage_item_scene, 
		remove_bullet_item_scene,
	]
	slots_nodes = [
		$Slot1,
		$Slot2,
		$Slot3,
		$Slot4,
	]
	GameManager.held_item_pos = held_item_pos
	GameManager.inventory_root = self


func _process(_delta):
	debug_1.text = str(GameManager.GameStateNames[GameManager.game_state])
	debug_2.text = str(GameManager.TurnOwnerNames[GameManager.turn_owner])
	if gun_node.in_hand == true:
		held_item = gun_node
	else:
		held_item = null
		for item in inventory:
			if is_instance_valid(item) and item.in_hand == true:
				held_item = item
				break


func update_item_position():
	for item in inventory:
		# Returns items not in hand
		if is_instance_valid(item) and not item.in_hand:
			toggle_child_collision(item, false)
			item.move_to(slots_nodes[item.inventory_slot].global_position, item.original_rot, item_lerp_speed)
		if is_instance_valid(item)and item.in_hand:
			toggle_child_collision(item, true)
			item.move_to(held_item_pos.global_position, Vector3(0, 0, 0), item_lerp_speed)
		if gun_node.in_hand:
			toggle_child_collision(gun_node, true)
		else:
			toggle_child_collision(gun_node, false)


func toggle_child_collision(object : Node, condition : bool):
	for child in object.get_children():
		if child is CollisionShape3D:
			child.disabled = condition


func add_random_item():
	if inventory_has_empty_slot():
		var rand = randi_range(0, item_scene_array.size() - 1)
		var new_item = item_scene_array[rand].instantiate()
		
		var replace_item_slot:int = -1
		for i in range(inventory.size()):
			if inventory[i] == null:
				replace_item_slot = i
				break
		if replace_item_slot != -1:
			new_item.inventory_slot = replace_item_slot
			print(replace_item_slot)
			inventory[replace_item_slot] = new_item
			slots_nodes[replace_item_slot].add_child(new_item)
			new_item.inventory_slot = replace_item_slot


func inventory_has_empty_slot():
	for item in inventory:
		if item == null:
			return true
	return false


func click_item(current_hover_object):
	if current_hover_object == gun_node:
		drop_item()
		gun_node.in_hand = true
		gun_node.move_to(held_item_pos.global_position, Vector3(0, 0, 0), item_lerp_speed)
		update_item_position()
	else:
		for item in inventory:
			if current_hover_object == item:
				drop_item()
				item.in_hand = true
				update_item_position()


func use_item():
	for item in inventory:
		if is_instance_valid(item) and item.in_hand:
			GameManager.game_state = GameManager.GameState.USINGITEM
			if not await item.use() == false:
				destroy_item(item)
			GameManager.game_state = GameManager.GameState.DECIDING


func drop_item():
	gun_node.in_hand = false
	gun_node.reset_pos()
	for item in inventory:
		if is_instance_valid(item) and item.in_hand == true:
			item.in_hand = false

func destroy_item(item_node : Node):
	var used_item = item_node
	inventory[item_node.inventory_slot] = null
	item_node = null
	used_item.queue_free()
