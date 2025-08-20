extends Node3D

var shop_slot_nodes:Array = []
var items_in_shop:Array = []
var new_shop_items_array:Array = []
var shop_held_item_pos:Node3D = null
var reroll_button_label:Label3D = null
var buy_button_label:Label3D = null
var leave_button_label:Label3D = null
var item_shop_description_label:Label3D = null
var item_lerp_speed:float = 0.05
var offset:Vector3 = Vector3(0,0.1,0)
var item_name_upgrade_dictionary:Dictionary = {
	"double_damage": GameManager.double_damage_item_level, 
	"one_health": GameManager.one_health_item_level,
	"peek": GameManager.peek_item_level,
	"remove_bullet": GameManager.remove_bullet_item_level,
	"shuffle": GameManager.shuffle_item_level,
}

func _ready() -> void:
	items_in_shop.resize(shop_slot_nodes.size())
	item_shop_description_label = $TvScreen/ItemDescription
	shop_held_item_pos = $ShopHeldItemPos
	reroll_button_label = $TvScreen/TextButtons/RerollButton/REROLL
	buy_button_label = $TvScreen/TextButtons/BuyButton/BUY
	leave_button_label = $TvScreen/TextButtons/LeaveButton/LEAVE
	GameManager.shop_root = self
	shop_slot_nodes = [
		$Slot0,
		$Slot1,
		$Slot2,
	]


func start_shop():
	new_shop_items_array = GameManager.item_scene_array
	new_shop_items_array.shuffle()
	var selection = new_shop_items_array.slice(0, shop_slot_nodes.size())
	for i in shop_slot_nodes.size():
		create_shop_item(i, selection)

func create_shop_item(index:int, selection):
	var new_item = selection[index].instantiate()
	new_item.inventory_slot = index
	items_in_shop.append(new_item)
	shop_slot_nodes[index].item_in_slot = new_item
	shop_slot_nodes[index].add_child(new_item)
	new_item.global_position += offset


func update_item_positions():
	for item in items_in_shop:
		if is_instance_valid(item):
			if item.in_hand == true:
				item.move_to(shop_held_item_pos.global_position, Vector3(0,0,0), item_lerp_speed)
				GameManager.toggle_child_collision(shop_slot_nodes[item.inventory_slot], true)
				item_shop_description_label.text = item.shop_description
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
		if is_instance_valid(item):
			item.in_hand = false


func reroll_button_hover(is_hovering):
	if is_hovering:
		reroll_button_label.modulate = GameManager.hover_text_colour
	else:
		reroll_button_label.modulate = GameManager.unhover_text_colour


func buy_button_hover(is_hovering):
	if is_hovering:
		buy_button_label.modulate = GameManager.hover_text_colour
	else:
		buy_button_label.modulate = GameManager.unhover_text_colour


func leave_button_hover(is_hovering):
	if is_hovering:
		leave_button_label.modulate = GameManager.hover_text_colour
	else:
		leave_button_label.modulate = GameManager.unhover_text_colour


func buy_item():
	for item in items_in_shop:
		if is_instance_valid(item) and item.in_hand == true:
			if item_name_upgrade_dictionary[item.item_type] < 2:
				item_name_upgrade_dictionary[item.item_type] += 1
				item.queue_free()
