extends Node3D

@export var player_health_icons: Array[Sprite3D]
@export var enemy_health_icons: Array[Sprite3D]


func _process(delta: float) -> void:
	for i in range(len(player_health_icons)):
		player_health_icons[i].visible = i < GameManager.player_health
	for i in range(len(enemy_health_icons)):
		enemy_health_icons[i].visible = i < GameManager.enemy_health
