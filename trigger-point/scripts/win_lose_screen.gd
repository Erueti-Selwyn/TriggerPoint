extends Control
@export var winner_text : Label
var player
func display_winner(player_node : Node3D ,player_won : bool):
	player = player_node
	self.visible = true
	if player_won:
		winner_text.text = "Win!"
	else:
		winner_text.text = "Lost!"

func _on_button_pressed():
	player.game_state = player.GameState.WAITING
	player.reset_health()
	player.reload()
	self.visible = false
