extends Node3D

var shop_slot_nodes:Array = []
var items_in_shop:Array = []
var item_scene_array:Array = []
var shop_held_item:Node3D = null
var reroll_button_text:Label3D = null
var buy_button_text:Label3D = null
var leave_button_text:Label3D = null
var item_lerp_speed:float = 0.05
var offset:Vector3 = Vector3(0,0.1,0)

func _ready() -> void:
	items_in_shop.resize(3)
	shop_held_item = $ShopHeldItem
	reroll_button_text = $TvScreen/TextButtons/RerollButton/REROLL
	buy_button_text = $TvScreen/TextButtons/BuyButton/BUY
	leave_button_text = $TvScreen/TextButtons/LeaveButton/LEAVE
	GameManager.shop_root = self
	shop_slot_nodes = [
		$Slot0,
		$Slot1,
		$Slot2,
	]
	item_scene_array = [
		GameManager.one_health_item_scene, 
		GameManager.peek_item_scene, 
		GameManager.shuffle_item_scene, 
		GameManager.double_damage_item_scene, 
		GameManager.remove_bullet_item_scene,
	]


func start_shop():
	for item in shop_slot_nodes:
		create_shop_item(item)
		

func create_shop_item(slot):
	if slot.item_in_slot == null:
		var rand = randi_range(0, item_scene_array.size() - 1)
		var new_item = item_scene_array[rand].instantiate()
		new_item.inventory_slot = slot.slot_number
		new_item.is_shop_item = true
		slot.item_in_slot = new_item
		items_in_shop[slot.slot_number] = new_item
		slot.add_child(new_item)
		# Get Rid of Magic Number
		new_item.global_position += offset
		print(str(new_item.item_y_offset))
	else:
		print("full slot: " + str(slot.item_in_slot))


func update_item_positions():
	for item in items_in_shop:
		if item.in_hand == true:
			item.move_to(shop_held_item.global_position, Vector3(0,0,0), item_lerp_speed)
			GameManager.toggle_child_collision(shop_slot_nodes[item.inventory_slot], true)
		else:
			item.move_to(shop_slot_nodes[item.inventory_slot].global_position + offset, item.original_rot, item_lerp_speed)
			GameManager.toggle_child_collision(shop_slot_nodes[item.inventory_slot], false)


func click_item(slot_clicked):
	if not slot_clicked.item_in_slot == null:
		drop_shop_items()
		slot_clicked.item_in_slot.in_hand = true
		update_item_positions()


func drop_shop_items():
	for item in items_in_shop:
		item.in_hand = false


func reroll_button_hover(is_hovering):
	if is_hovering:
		reroll_button_text.modulate = GameManager.hover_text_colour
	else:
		reroll_button_text.modulate = GameManager.unhover_text_colour


func buy_button_hover(is_hovering):
	if is_hovering:
		buy_button_text.modulate = GameManager.hover_text_colour
	else:
		buy_button_text.modulate = GameManager.unhover_text_colour


func leave_button_hover(is_hovering):
	if is_hovering:
		leave_button_text.modulate = GameManager.hover_text_colour
	else:
		leave_button_text.modulate = GameManager.unhover_text_colour
