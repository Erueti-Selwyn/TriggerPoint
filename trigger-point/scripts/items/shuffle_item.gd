extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_type = "shuffle"
	shop_description = "Shuffles bullets and reveals\nthe last bullet in the chamber"
	item_description = "Shuffles Bullets\nin the chamber"

func _ready():
	base_model = preload("res://models/items/base_item/base_shuffle_model.tscn")
	upgraded_model = preload("res://models/items/upgraded_item/upgraded_shuffle_model.tscn")
	get_y_offset()
func use():
	if GameManager.loaded_bullets_array.size() > 0:
		GameManager.loaded_bullets_array.shuffle()
	else:
		return false
