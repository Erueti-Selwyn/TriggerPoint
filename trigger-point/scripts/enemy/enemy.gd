extends Node3D

@export var enemy_blood_position: Node3D


func _ready() -> void:
	GameManager.enemy = self


func start_turn():
	if (
		GameManager.player_health > 0 
		and GameManager.enemy_health > 0
	):
		GameManager.on_screen_text_node.start_enemy_turn_text()
		if GameManager.loaded_bullets_array.size() > 0:
			await get_tree().create_timer(1, false, true).timeout
			var rand = randi_range(1, 2)
			if rand == 1:
				# Enemy shoots self
				GameManager.shoot(GameManager.enemy, GameManager.enemy)
			elif rand == 2:
				# Enereamy shoots you
				GameManager.shoot(GameManager.enemy, GameManager.player)


func blood_particles():
	# Instatiates blood particles at enemy location
	var blood = GameManager.blood_splatter_particle.instantiate()
	add_child(blood)
	blood.global_position = enemy_blood_position.global_position
	blood.emitting = true
