extends StaticBody3D
@export var audio_player_empty : AudioStreamPlayer3D
@export var audio_player_shot : AudioStreamPlayer3D
@export var audio_player_shotgun_cocking : AudioStreamPlayer3D

var hover : bool

var in_hand : bool = false
var is_item : bool = false
@onready var original_pos : Vector3 = global_position
@onready var original_rot : Vector3 = rotation
var target_pos : Vector3
var target_rot : Vector3
var target_speed : float
var inventory_slot : int = 0
var type : String = "gun"

func move_to(pos: Vector3, rot: Vector3, speed: float):
	target_pos = pos
	target_rot = rot
	target_speed = speed
func _process(_delta):
	global_position = global_position.lerp(target_pos, target_speed)
	rotation = rotation.lerp(target_rot, target_speed)

func play_sound_click():
	audio_player_empty.play()
func play_sound_shot():
	audio_player_shot.play()
func play_sound_cock():
	audio_player_shotgun_cocking.play()
