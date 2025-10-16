extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_type = "remove_bullet"
	item_description = "Removes next bullet\n in the chamber"


func use():
	if GameManager.loaded_bullets_array.size() > 0:
		GameManager.shotgun_node.remove_bullet()
		GameManager.loaded_bullets_array.remove_at(0)
