extends Node3D

var shop_slot_nodes:Array = []
var item_scene_array:Array = []
func _ready() -> void:
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

func click_item(clicked):
	var clicked_item = shop_slot_nodes[clicked.slot_number]


func start_shop():
	for item in shop_slot_nodes:
		create_shop_item(item)
		

func create_shop_item(slot):
	if slot.item_in_slot == null:
		var rand = randi_range(0, item_scene_array.size() - 1)
		print("created: " + str(item_scene_array[rand]))
		var new_item = item_scene_array[rand].instantiate()
		new_item.inventory_slot = slot.slot_number
		slot.item_in_slot = new_item
		slot.add_child(new_item)
		new_item.global_position += Vector3(0,0.1,0)
	else:
		print("full slot: " + str(slot.item_in_slot))
