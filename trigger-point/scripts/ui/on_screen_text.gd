extends Label
var is_text: bool = false
var speed: float = 0.75


func _process(delta):
	if is_text:
		if visible_ratio < 1.0:
			visible_ratio += delta / speed
			visible_ratio = clamp(visible_ratio, 0.0, 1.0)
	else:
		if visible_ratio > 0.0:
			visible_ratio -= delta / speed
			visible_ratio = clamp(visible_ratio, 0.0, 1.0)



func text_appear():
	is_text = true


func text_disseapear():
	is_text = false


func text_clear():
	visible_ratio = 0
	is_text = false


func get_item_text():
	if GameManager.item_guide_text_count < 1:
		text_clear()
		text = "Each turn recive 2 new items -- use them wisely."
		text_appear()
		GameManager.item_guide_text_count += 1


func loaded_bullets_text(live_count: int, blank_count: int):
	text_clear()
	text = str(live_count) + " live bullets, " + str(blank_count) + " blank bullets."
	text_appear()


func gun_guide_text():
	if GameManager.gun_guide_text_count < 1:
		text_clear()
		text = "Use an item, or click the gun to shoot."
		text_appear()
		GameManager.gun_guide_text_count += 1


func shoot_someone_text():
	if GameManager.shoot_someone_text_count < 1:
		text_clear()
		text = "Shoot Yourself with a blank, and continue your turn."
		text_appear()
		GameManager.shoot_someone_text_count += 1


func start_enemy_turn_text():
	text_clear()
	var rand = randi_range(0, 3)
	if rand == 0:
		text = "My turn."
	elif rand == 1:
		text = "Good luck."
	elif rand == 2:
		text = "Let's see how lucky you are."
	elif rand == 3:
		text = "Ready?"
	text_appear()
	await get_tree().create_timer(5, false, true).timeout
	text_disseapear()
