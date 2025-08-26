extends Control


func _ready():
	get_tree().paused = false


func _process(_delta):
	if Input.is_action_just_pressed("p"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true


func _on_resume_pressed():
	get_tree().paused = false
	visible = false


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
