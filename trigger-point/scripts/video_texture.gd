extends MeshInstance3D

@export var video_stream_player:VideoStreamPlayer

func _ready():
	video_stream_player.visible = false
	video_stream_player.play()
	material_override.albedo_texture = video_stream_player.get_video_texture()
