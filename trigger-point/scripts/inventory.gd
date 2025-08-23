extends Node3D
# Assets


# Constants
const INVENTORY_SIZE:int = 4

# Variables
@export var held_item_pos: Node3D
@export var gun_node: Node3D
var inventory:Array = [null, null, null, null]
var loaded_items:Array = []
var slots_nodes:Array = []
var item_lerp_speed:float = 0.05
var held_item: Node3D
var new_item:Node3D


func _ready():
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
	for item in loaded_items:
		if is_instance_valid(item) and item.in_hand:
			item.move_to(held_item_pos.global_position, Vector3(0, 0, 0), item_lerp_speed)
	for item in inventory:
		# Returns items not in hand
		if is_instance_valid(item) and not item.in_hand:
			GameManager.toggle_child_collision(slots_nodes[item.inventory_slot], false)
			item.move_to(slots_nodes[item.inventory_slot].global_position + Vector3(0,0.1,0), item.original_rot, item_lerp_speed)
		if is_instance_valid(item)and item.in_hand:
			GameManager.toggle_child_collision(slots_nodes[item.inventory_slot], true)
			item.move_to(held_item_pos.global_position, Vector3(0, 0, 0), item_lerp_speed)
	if gun_node.in_hand:
		GameManager.toggle_child_collision(gun_node, true)
	else:
		GameManager.toggle_child_collision(gun_node, false)


func add_random_item():
	if inventory_has_empty_slot():
		GameManager.receive_item_count -= 1
		var rand = randi_range(0, GameManager.item_scene_dictionary.size() - 1)
		new_item = GameManager.item_scene_dictionary[GameManager.item_name_array[rand]].instantiate()
		add_child(new_item)
		new_item.global_position = GameManager.dealing_box.global_position
		new_item.rotation = Vector3(0, 0, 0)
		new_item.in_hand = true
		loaded_items.append(new_item)
		update_item_position()


func inventory_has_empty_slot():
	for item in inventory:
		if item == null:
			return true
	return false


func click_item(current_hover_object):
	if (
		GameManager.game_state == GameManager.GameState.GETTINGITEM and 
		not current_hover_object == gun_node and 
		inventory[current_hover_object.slot_number] == null
	):
		inventory.insert(current_hover_object.slot_number, new_item)
		new_item.inventory_slot = current_hover_object.slot_number

		var new_local_transform: Transform3D = current_hover_object.global_transform.affine_inverse() * new_item.global_transform
		new_item.get_parent().remove_child(new_item)
		current_hover_object.add_child(new_item)
		new_item.transform = new_local_transform
		
		new_item.in_hand = false
		new_item = null
		update_item_position()
		if GameManager.receive_item_count > 0:
			add_random_item()
		else:
			GameManager.end_getting_item()
	elif current_hover_object == gun_node:
		drop_item()
		gun_node.in_hand = true
		gun_node.move_to(held_item_pos.global_position, Vector3(0, 0, 0), item_lerp_speed)
		update_item_position()
	elif not GameManager.game_state == GameManager.GameState.GETTINGITEM:
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
