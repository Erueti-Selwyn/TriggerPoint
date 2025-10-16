extends Item
@export var mesh_node: Node3D


func _init():
	type = "item"
	item_type = "peek"
	item_description = "Reveals the next\nbullet in the chamber"


func use():
	if GameManager.loaded_bullets_array.size() > 0:
		var is_live_bullet: bool
		if GameManager.loaded_bullets_array[0] == GameManager.BulletType.LIVE:
			is_live_bullet = true
		elif GameManager.loaded_bullets_array[0] == GameManager.BulletType.BLANK:
			is_live_bullet = false
		var bullet = GameManager.shotgun_shell_scene.instantiate()
		GameManager.player.add_child(bullet)
		bullet.global_position = GameManager.center_bullet_pos.global_position
		bullet.get_child(0).set_colour(is_live_bullet)
		bullet.rotation = Vector3(0, deg_to_rad(180), deg_to_rad(90))
		await get_tree().create_timer(2).timeout
		bullet.queue_free()
