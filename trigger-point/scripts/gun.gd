extends StaticBody3D
@export var audio_player_empty : AudioStreamPlayer3D
@export var audio_player_shot : AudioStreamPlayer3D
@export var audio_player_shotgun_cocking : AudioStreamPlayer3D
var hover : bool
func can_hover():
	hover = true
func cant_hover():
	hover = false
func get_hover_status():
	return(hover)
func play_sound_click():
	audio_player_empty.play()
func play_sound_shot():
	audio_player_shot.play()
func play_sound_cock():
	audio_player_shotgun_cocking.play()
