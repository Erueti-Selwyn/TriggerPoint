extends Node3D
@onready var anim_player = $AnimationPlayer

@onready var item_right = $ItemRight
var item_right_global_pos : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	item_right_global_pos = item_right.position

func item_clear_player():
	anim_player.play("Item Clear Player")
func item_reclear_player():
	anim_player.play("Item Reclear Player")
func item_close_player():
	anim_player.play("Item Close Player")
func item_open_player():
	anim_player.play("Item Open Player")
func item_clear_enemy():
	anim_player.play("Item Clear Enemy")
func item_reclear_enemy():
	anim_player.play("Item Reclear Enemy")
func item_close_enemy():
	anim_player.play("Item Close Enemy")
func item_open_enemy():
	anim_player.play("Item Open Enemy")
func gun_open():
	anim_player.play("Gun Open")
func gun_close():
	anim_player.play("Gun Close")
