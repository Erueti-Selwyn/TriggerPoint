extends Control


func _ready():
	visible = false


func open():
	GameManager.pause = true
	visible = true


func close():
	GameManager.pause = false
	visible = false


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, (1 / (101 - value)))


func _on_exit_pressed():
	close()
