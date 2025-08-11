extends Item

func _init():
	type = "item"
	item_type = "double_damage"
	item_description = "Doubles damage\nof next shot"

func _ready():
	get_y_offset()
func use():
	GameManager.current_bullet_damage = GameManager.current_bullet_damage * 2
