extends AudioStreamPlayer3D


func _ready() -> void:
	self.stream.loop = true
	play()
