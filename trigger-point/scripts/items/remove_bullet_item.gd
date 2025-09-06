extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_type = "remove_bullet"
	shop_description = "Removes the next two bullets\ninstead of just one"
	item_description = "Removes next bullet\n in the chamber"
	upgraded_description = "Removes the next two bullets\n in the chamber"


func _ready():
	base_model = preload("res://models/items/base_item/base_remove_bullet_model.tscn")
	upgraded_model = preload("res://models/items/upgraded_item/upgraded_remove_bullet_model.tscn")
	super()


func use():
	if GameManager.loaded_bullets_array.size() > 0:
		var bullet = GameManager.bullet_gravity_scene.instantiate()
		var level_node = get_tree().root
		level_node.add_child(bullet)
		var mesh = bullet.get_node("MeshInstance3D")
		var base_mat = mesh.get_active_material(0)
		var mat = base_mat.duplicate()
		if GameManager.loaded_bullets_array[0] == GameManager.BulletType.LIVE:
			mat.albedo_color = Color(1, 0, 0)
		else:
			mat.albedo_color = Color(0, 0, 1)
		mesh.set_surface_override_material(0, mat)
		bullet.global_position = Vector3(GameManager.live_bullet_pos.global_position.x, GameManager.live_bullet_pos.global_position.y + 0.1, GameManager.live_bullet_pos.global_position.z - (float(GameManager.used_shells)/6))
		bullet.rotation = Vector3(0, 0, deg_to_rad(90))
		GameManager.loaded_bullets_array.remove_at(0)
		GameManager.used_shells_array.append(bullet)
		GameManager.used_shells += 1
	else:
		return false
