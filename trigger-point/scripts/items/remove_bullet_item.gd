extends Item

func _init():
	type = "item"
	item_type = "remove_bullet"
	item_description = "Removes next bullet\n in the chamber"


func _ready():
	get_y_offset()


func use(player):
	if player.loaded_bullets_array.size() > 0:
		self.visible = false
		var bullet = player.bullet_scene.instantiate()
		var level_node = get_tree().get_current_scene()
		level_node.add_child(bullet)
		var mesh = bullet.get_node("MeshInstance3D")
		var base_mat = mesh.get_active_material(0)
		var mat = base_mat.duplicate()
		if player.loaded_bullets_array[0] == true:
			mat.albedo_color = Color(1, 0, 0)
		else:
			mat.albedo_color = Color(0, 0, 1)
		mesh.set_surface_override_material(0, mat)
		bullet.global_position = player.held_item_pos.global_position
		player.loaded_bullets_array.remove_at(0)
		await get_tree().create_timer(1).timeout
		bullet.queue_free()
	else:
		return false
