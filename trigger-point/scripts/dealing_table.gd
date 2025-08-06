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

func item_open_left():
	anim_player.play("Item Open Left")
func item_close_left():
	anim_player.play("Item Close Left")
func item_open_right():
	anim_player.play("Item Open Right")
func item_close_right():
	anim_player.play("Item Close Right")
func gun_open():
	anim_player.play("Gun Open")
func gun_close():
	anim_player.play("GunClose")
