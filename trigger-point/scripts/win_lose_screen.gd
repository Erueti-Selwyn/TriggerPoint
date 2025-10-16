extends Control
@export var winner_text : Label
var player


func _ready():
	self.visible = false


func display_winner(player_won : bool):
	self.visible = true
	if player_won:
		winner_text.text = "Win!"
	else:
		winner_text.text = "Lost!"


func _on_restart_pressed():
	self.visible = false
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
