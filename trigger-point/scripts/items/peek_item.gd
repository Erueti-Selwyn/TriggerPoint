extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_type = "peek"
	shop_description = "Reveals the next two bullets\ninstead of just one"
	item_description = "Reveals the next\nbullet in the chamber"


func _ready():
	base_model = preload("res://models/items/base_item/base_peek_model.tscn")
	upgraded_model = preload("res://models/items/upgraded_item/upgraded_peek_model.tscn")
	get_y_offset()


func use():
	if GameManager.loaded_bullets_array.size() > 0:
		self.visible = false
		var bullet = GameManager.bullet_scene.instantiate()
		var level_node = get_tree().get_current_scene()
		level_node.add_child(bullet)
		var mesh = bullet.get_node("MeshInstance3D")
		var base_mat = mesh.get_active_material(0)
		var mat = base_mat.duplicate()
		if GameManager.loaded_bullets_array[0] == true:
			mat.albedo_color = Color(1, 0, 0)
		else:
			mat.albedo_color = Color(0, 0, 1)
		mesh.set_surface_override_material(0, mat)
		bullet.global_position = GameManager.held_item_pos.global_position
		await get_tree().create_timer(1).timeout
		bullet.queue_free()
	else:
		return false
