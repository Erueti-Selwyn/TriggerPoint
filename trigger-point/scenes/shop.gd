extends Node3D

var shop_slot_nodes:Array = []
var items_in_shop:Array = []
var item_scene_array:Array = []
var new_shop_items_array:Array = []
var shop_held_item:Node3D = null
var reroll_button_text:Label3D = null
var buy_button_text:Label3D = null
var leave_button_text:Label3D = null
var item_lerp_speed:float = 0.05
var offset:Vector3 = Vector3(0,0.1,0)

func _ready() -> void:
	items_in_shop.resize(shop_slot_nodes.size())
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
	new_shop_items_array = item_scene_array
	new_shop_items_array.shuffle()
	var selection = new_shop_items_array.slice(0, shop_slot_nodes.size())
	items_in_shop = new_shop_items_array.slice(0, shop_slot_nodes.size())
	for i in shop_slot_nodes.size():
		create_shop_item(i, selection)

func create_shop_item(index:int, selection):
	var new_item = selection[index].instantiate()
	new_item.inventory_slot = index
	new_item.is_shop_item = true
	items_in_shop.append(new_item)
	shop_slot_nodes[index].item_in_slot = new_item
	shop_slot_nodes[index].add_child(new_item)
	new_item.global_position += offset


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
