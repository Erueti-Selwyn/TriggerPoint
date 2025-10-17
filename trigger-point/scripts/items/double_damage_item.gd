extends Item

@export var mesh_node: Node3D


func _init():
	type = "item"
	item_description = "Doubles damage\nof next shot"


func use():
	GameManager.damage = GameManager.damage * 2
