extends VideoTexture

@export var hover_video_file: VideoStreamTheora
var is_hover: bool


# Plays hover video file
func hover():
	if is_hover == false:
		video_stream_player.stream = hover_video_file
		meshs.material_override.albedo_texture = video_stream_player.get_video_texture()
		video_stream_player.play()
		is_hover = true


# Plays unhover video file
func unhover():
	if is_hover == true:
		video_stream_player.stream = default_video_file
		meshs.material_override.albedo_texture = video_stream_player.get_video_texture()
		video_stream_player.play()
		is_hover = false


# Opens options menu
func click():
	return "options"
