extends Control

@export var winner_text : Label
var player


func _ready():
	self.visible = false


func display_winner(player_won : bool):
	# Displays winner screen
	self.visible = true
	if player_won:
		winner_text.text = "You Win!"
	else:
		winner_text.text = "You Lost!"


func _on_restart_pressed():
	# Resets level scene
	GameManager.round_ended = false
	self.visible = false
	get_tree().reload_current_scene()


func _on_quit_pressed():
	# Returns to main menu scene
	GameManager.round_ended = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
