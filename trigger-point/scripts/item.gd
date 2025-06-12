extends Node3D
var hover : bool
func _ready():
	print("item")
func can_hover():
	hover = true
func cant_hover():
	hover = false
func get_hover_status():
	return(hover)
func clickable():
	pass
