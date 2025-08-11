extends Item

func _init():
	type = "item"
	item_type = "shuffle"
	item_description = "Shuffles Bullets\nin the chamber"

func _ready():
	get_y_offset()
func use():
	if GameManager.loaded_bullets_array.size() > 0:
		GameManager.loaded_bullets_array.shuffle()
	else:
		return false
