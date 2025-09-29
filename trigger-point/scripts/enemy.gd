extends Node3D
@export var stupidness : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.enemy = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func start_turn():
	if GameManager.player_health > 0 and GameManager.enemy_health > 0:
		if GameManager.loaded_bullets_array.size() > 0:
			await get_tree().create_timer(1, false).timeout
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
