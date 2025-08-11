extends Item

func _init():
	type = "item"
	item_type = "one_health"
	item_description = "Heal for\none life"

func _ready():
	get_y_offset()
func use():
	GameManager.player_health += 1
