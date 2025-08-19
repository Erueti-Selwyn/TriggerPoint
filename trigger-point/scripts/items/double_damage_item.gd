extends Item
@export var mesh_node: Node3D

func _init():
	type = "item"
	item_type = "double_damage"
	shop_description = "Damage will be tripled\ninstead of doubled"
	item_description = "Doubles damage\nof next shot"

func _ready():
	base_model = preload("res://models/items/base_item/base_double_damage_model.tscn")
	upgraded_model = preload("res://models/items/upgraded_item/upgraded_double_damage_model.tscn")
	get_y_offset()
func use():
	GameManager.current_bullet_damage = GameManager.current_bullet_damage * 2
