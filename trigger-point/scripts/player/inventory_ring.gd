extends Node3D


func _process(_delta):
	if GameManager.game_state == GameManager.GameState.GETTINGITEM:
		visible = true
	else:
		visible = false
