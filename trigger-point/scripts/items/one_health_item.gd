extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_type = "one_health"
	item_description = "Heal for\none life"


func use():
	if GameManager.player_health < 5:
		GameManager.player_health += 1
	else:
		return false
