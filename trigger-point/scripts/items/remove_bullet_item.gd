extends Item

func _init():
	type = "item"
	item_type = "remove_bullet"
	item_description = "Removes next bullet\n in the chamber"


func _ready():
	get_y_offset()


func use(player):
	if player.loaded_bullets_array.size() > 0:
		var bullet = player.bullet_gravity_scene.instantiate()
		add_child(bullet)
		var mesh = bullet.get_node("MeshInstance3D")
		var base_mat = mesh.get_active_material(0)
		var mat = base_mat.duplicate()
		if player.is_live_bullets:
			mat.albedo_color = Color(1, 0, 0)
		else:
			mat.albedo_color = Color(0, 0, 1)
		mesh.set_surface_override_material(0, mat)
		bullet.global_position = Vector3(player.live_bullet_pos.global_position.x, player.live_bullet_pos.global_position.y + 0.1, player.live_bullet_pos.global_position.z - (float(player.used_shells)/6))
		bullet.rotation = Vector3(0, 0, deg_to_rad(90))
		player.used_shells_array.append(bullet)
		player.used_shells += 1
		await get_tree().create_timer(1).timeout
		bullet.queue_free()
	else:
		return false
