extends Node

enum GameState {
	WAITING, 
	PLAYERTURN, 
	ENEMYTURN, 
	SHOOTING, 
	ENEMYITEM, 
	RELOADING, 
	USINGITEM, 
	SHOPPING, 
	GAMEOVER
}
const GameStateNames = {
	GameState.WAITING: "WAITING",
	GameState.PLAYERTURN: "PLAYERTURN",
	GameState.ENEMYTURN: "ENEMYTURN",
	GameState.SHOOTING: "SHOOTING",
	GameState.ENEMYITEM: "ENEMYITEM",
	GameState.RELOADING: "RELOADING",
	GameState.USINGITEM: "USINGITEM",
	GameState.SHOPPING: "SHOPPING",
	GameState.GAMEOVER: "GAMEOVER",
}
var game_state : GameState

# Player stats
var round_number: int = 1
var player_health: int = 3
var player_max_health: int = 3
var player_money: int = 0
# var player_inventory: Array = [] Maybe Change to this?

# Enemy stats
var enemy_health: int = 3
var enemy_max_health: int = 3

# Game Rules
var current_bullet_damage: int = 1
var damage: int = 1
# Bullets
var max_bullets_in_chamber: int = 6
var bullets_in_chamber: int = 6
var live_bullets: int = 3
var blank_bullets: int = 3
var loaded_bullets_array: Array = []
var used_shells : int
var used_shells_array : Array

# Temporary states
var round_won: bool = false
var shop_open: bool = false
var using_item: bool = false
