extends Node3D

# Constants
const INVENTORY_SIZE: int = 4
const ITEM_LERP_SPEED: float = 0.05

# @export variables
@export var held_item_pos: Node3D
@export var new_item_pos: Node3D

# Variables
var inventory:Array = [null, null, null, null]
var loaded_items:Array = []
var slots_nodes:Array = []
var held_item: Node3D
var new_item:Node3D


func _ready():
	# Creates slot node array
	slots_nodes = [
		$Slot0,
		$Slot1,
		$Slot2,
		$Slot3,
	]
	GameManager.held_item_pos = held_item_pos
	GameManager.inventory_root = self


func _process(_delta):
	# Checks if shotgun or item is being held
	if GameManager.shotgun_node.in_hand == true:
		held_item = GameManager.shotgun_node
	else:
		held_item = null
		for item in inventory:
			if is_instance_valid(item) and item.in_hand == true:
				held_item = item
				break


func update_item_position():
	# Updates the items target positions and rotations
	for item in loaded_items:
		# Moves the new items that were just created
		if is_instance_valid(item) and item.is_recieving:
			item.move_to(new_item_pos.global_position, Vector3(0, 0, 0), ITEM_LERP_SPEED)
	for item in inventory:
		# Moves items not in hand to rest position
		if is_instance_valid(item) and not item.in_hand:
			GameManager.toggle_child_collision(slots_nodes[item.inventory_slot], false)
			item.move_to(slots_nodes[item.inventory_slot].global_position + Vector3(0,0.1,0), item.original_rot, ITEM_LERP_SPEED)
		# Moves item in hand to in hand position
		if is_instance_valid(item) and item.in_hand:
			GameManager.toggle_child_collision(slots_nodes[item.inventory_slot], true)
			item.move_to(held_item_pos.global_position, Vector3(0, 0, 0), ITEM_LERP_SPEED)
	# Toggles the collision of the child collisions
	if GameManager.shotgun_node.in_hand:
		GameManager.toggle_child_collision(GameManager.shotgun_node, true)
	else:
		GameManager.toggle_child_collision(GameManager.shotgun_node, false)


# Function to add a random item to inventory
func add_random_item():
	# Checks if there is an empty slot in inventory
	if inventory_has_empty_slot():
		GameManager.receive_item_count -= 1
		# Chooses random number and picks item from item dictionary
		var rand = randi_range(0, GameManager.item_scene_dictionary.size() - 1)
		# Instantiates new item
		new_item = GameManager.item_scene_dictionary[GameManager.item_name_array[rand]].instantiate()
		add_child(new_item)
		# Changes position and rotation
		new_item.global_position = GameManager.dealing_box.global_position - Vector3(0.2, 0.2, 0)
		new_item.rotation = Vector3(0, 0, 0)
		new_item.is_recieving = true
		# Adds to loaded items array
		loaded_items.append(new_item)
		update_item_position()
	else:
		# If no space in inventory stops getting item
		GameManager.end_getting_item()


# Checks for empty inventory slots
func inventory_has_empty_slot():
	for item in inventory:
		if item == null:
			return true
	return false


# Called when an item in inventory is clicked
func click_item(current_hover_object):
	# Proceeds the player is reciving item and the clicked item slot is null
	if (
		GameManager.game_state == GameManager.GameState.GETTINGITEM and 
		not current_hover_object.is_in_group("gun") and 
		inventory[current_hover_object.slot_number] == null and GameManager.round_ended == false
	):
		inventory[current_hover_object.slot_number] = new_item
		new_item.inventory_slot = current_hover_object.slot_number
		
		# Puts new local transform
		var new_local_transform: Transform3D = current_hover_object.global_transform.affine_inverse() * new_item.global_transform
		new_item.get_parent().remove_child(new_item)
		current_hover_object.add_child(new_item)
		new_item.transform = new_local_transform
		
		new_item.in_hand = false
		new_item.is_recieving = false
		new_item = null
		
		update_item_position()
		# Creates another item if the player still has more to recive
		if GameManager.receive_item_count > 0:
			add_random_item()
		else:
			GameManager.receive_item_count = 0
			GameManager.end_getting_item()
			# Makes text disseapear on screen on UI
			GameManager.on_screen_text_node.text_disseapear()
	# Proceeds if the clicked object is a gun
	elif current_hover_object.is_in_group("gun") and GameManager.round_ended == false:
		# Drops currently held item and picks up gun
		drop_item()
		GameManager.shotgun_node.in_hand = true
		# Makes shooting text appear on screen
		GameManager.on_screen_text_node.shoot_someone_text()
		update_item_position()
		# Plays the hold animation for the gun
		await GameManager.shotgun_node.hold()
	# Proceeds if player is not recieving item and is clicking item slot
	elif not GameManager.game_state == GameManager.GameState.GETTINGITEM and is_instance_valid(inventory[current_hover_object.slot_number]) and GameManager.round_ended == false:
		# Drops items and holds clicked item
		drop_item()
		inventory[current_hover_object.slot_number].in_hand = true
		update_item_position()


# Function called when an item is being used
func use_item():
	# For each inventory slot, checks what item is in hand
	for item in inventory:
		if is_instance_valid(item) and item.in_hand:
			# Changes to using item game state
			GameManager.game_state = GameManager.GameState.USINGITEM
			# If the item is usable in current scenario then proceeds
			if not await item.use() == false:
				# Clears item after being used
				slots_nodes[item.inventory_slot].item_in_slot = null
				inventory[item.inventory_slot] = null
				# Brings back collision of the inventory slot
				GameManager.toggle_child_collision(slots_nodes[item.inventory_slot], false)
				destroy_item(item)
			GameManager.game_state = GameManager.GameState.DECIDING
			update_item_position()


# Loops through inventory to drop all items
func drop_item():
	if GameManager.shotgun_node.in_hand == true:
		GameManager.shotgun_node.drop_gun()
	for item in inventory:
		if is_instance_valid(item) and item.in_hand == true:
			item.in_hand = false


# Destroys an item in inventory
func destroy_item(item_node : Node):
	var used_item = item_node
	inventory[item_node.inventory_slot] = null
	item_node = null
	used_item.queue_free()
