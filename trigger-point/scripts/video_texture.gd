extends Node3D
class_name VideoTexture

@export var video_stream_player: VideoStreamPlayer
@export var default_video_file: VideoStreamTheora
@export var meshs: MeshInstance3D


func _ready():
	video_stream_player.stream = default_video_file
	video_stream_player.visible = false
	video_stream_player.play()
	if meshs:
		meshs.material_override.albedo_texture = video_stream_player.get_video_texture()
