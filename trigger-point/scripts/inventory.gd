extends Node3D
# Assets


# Constants
const INVENTORY_SIZE:int = 4

# Variables
@export var held_item_pos: Node3D
@export var gun_node: Node3D
var inventory:Array = [null, null, null, null]
var slots_nodes:Array = []
var item_scene_array:Array = []
var item_lerp_speed:float = 0.05
var held_item: Node3D


func _ready():
	item_scene_array = [
		GameManager.one_health_item_scene, 
		GameManager.peek_item_scene, 
		GameManager.shuffle_item_scene, 
		GameManager.double_damage_item_scene, 
		GameManager.remove_bullet_item_scene,
	]
	slots_nodes = [
		$Slot0,
		$Slot1,
		$Slot2,
		$Slot3,
	]
	GameManager.held_item_pos = held_item_pos
	GameManager.inventory_root = self


func _process(_delta):
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
			toggle_child_collision(slots_nodes[item.inventory_slot], false)
			item.move_to(slots_nodes[item.inventory_slot].global_position + Vector3(0,0.1,0), item.original_rot, item_lerp_speed)
		if is_instance_valid(item)and item.in_hand:
			toggle_child_collision(slots_nodes[item.inventory_slot], true)
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
			inventory[replace_item_slot] = new_item
			slots_nodes[replace_item_slot].add_child(new_item)
			slots_nodes[replace_item_slot].item_in_slot = new_item
			new_item.inventory_slot = replace_item_slot
			update_item_position()


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
		drop_item()
		inventory[current_hover_object.slot_number].in_hand = true
		update_item_position()


func use_item():
	for item in inventory:
		if is_instance_valid(item) and item.in_hand:
			GameManager.game_state = GameManager.GameState.USINGITEM
			if not await item.use() == false:
				slots_nodes[item.inventory_slot].item_in_slot = null
				destroy_item(item)
			GameManager.game_state = GameManager.GameState.DECIDING
			update_item_position()


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
