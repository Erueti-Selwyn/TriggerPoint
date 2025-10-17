extends Node3D
@export var stupidness : float
@export var enemy_blood_position: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.enemy = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func start_turn():
	if GameManager.player_health > 0 and GameManager.enemy_health > 0:
		if GameManager.loaded_bullets_array.size() > 0:
			await get_tree().create_timer(1, false, true).timeout
			var rand = randi_range(1, 2)
			if rand == 1:
				# Enemy shoots self
				GameManager.shoot(GameManager.enemy, GameManager.enemy)
			elif rand == 2:
				# Enereamy shoots you
				GameManager.shoot(GameManager.enemy, GameManager.player)
		else:
			GameManager.game_state = GameManager.GameState.WAITING
			GameManager.reload()


func blood_particles():
	var blood = GameManager.blood_splatter_particle.instantiate()
	add_child(blood)
	blood.global_position = enemy_blood_position.global_position
	blood.emitting = true
