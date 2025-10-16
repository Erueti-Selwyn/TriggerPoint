extends Control


func _ready():
	get_tree().paused = false
	visible = false


func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused


func _on_resume_pressed():
	get_tree().paused = false
	visible = false


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
