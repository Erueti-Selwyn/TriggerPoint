extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_description = "Removes next bullet\n in the chamber"


func use():
	if GameManager.loaded_bullets_array.size() > 0:
		# Removes bullet and adds it on the table
		GameManager.shotgun_node.remove_bullet()
		GameManager.loaded_bullets_array.remove_at(0)
	else:
		return false
