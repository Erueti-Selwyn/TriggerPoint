extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_type = "one_health"
	shop_description = "Heals for three lives\n instead of just one"
	item_description = "Heal for\none life"
	upgraded_description = "Heals for\nthree lives"

func _ready():
	base_model = preload("res://models/items/base_item/base_one_health_model.tscn")
	upgraded_model = preload("res://models/items/upgraded_item/upgraded_one_health_model.tscn")
	super()
	get_y_offset()
func use():
	GameManager.player_health += 1
