extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var item_right = $ItemRight
@onready var dealing_box: Node3D = $ItemSlotLeft/Box


func _ready() -> void:
	GameManager.dealing_table = self
	GameManager.dealing_box = dealing_box


func box_close_player():
	anim_player.play("Box Close Player")
	await anim_player.animation_finished
	return


func box_open_player():
	anim_player.play("Box Open Player")
	await anim_player.animation_finished
	return
