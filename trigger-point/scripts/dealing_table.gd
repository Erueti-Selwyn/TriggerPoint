extends Node3D
@onready var anim_player = $AnimationPlayer
@onready var item_right = $ItemRight
@onready var dealing_box: Node3D = $ItemSlotLeft/Box
var item_right_global_pos : Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.dealing_table = self
	GameManager.dealing_box = dealing_box
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	item_right_global_pos = item_right.position


func box_close_player():
	anim_player.play("Box Close Player")
	await anim_player.animation_finished
	return


func box_open_player():
	anim_player.play("Box Open Player")
	await anim_player.animation_finished
	return


func item_clear_enemy():
	anim_player.play("Item Clear Enemy")
	await anim_player.animation_finished
	return


func item_reclear_enemy():
	anim_player.play("Item Reclear Enemy")
	await anim_player.animation_finished
	return


func item_close_enemy():
	anim_player.play("Item Close Enemy")
	await anim_player.animation_finished
	return


func item_open_enemy():
	anim_player.play("Item Open Enemy")
	await anim_player.animation_finished
	return


func gun_open():
	anim_player.play("Gun Open")
	await anim_player.animation_finished
	return


func gun_close():
	anim_player.play("Gun Close")
	await anim_player.animation_finished
	return
