extends VideoTexture

@export var hover_video_file: VideoStreamTheora
var is_hover: bool


func hover():
	if is_hover == false:
		video_stream_player.stream = hover_video_file
		meshs.material_override.albedo_texture = video_stream_player.get_video_texture()
		video_stream_player.play()
		is_hover = true


func unhover():
	if is_hover == true:
		video_stream_player.stream = default_video_file
		meshs.material_override.albedo_texture = video_stream_player.get_video_texture()
		video_stream_player.play()
		is_hover = false


func click():
	get_tree().quit()
