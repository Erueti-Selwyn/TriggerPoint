extends Node3D
var in_hand : bool = false
var type : String = "gun"
var current_target:Node3D
@onready var animation_player = $Shotgun_Final/AnimationPlayer
@onready var collision_shape = $CollisionShape3D


func _ready():
	GameManager.shotgun_node = self


func hold():
	in_hand = true
	animation_player.play("GUN SELECT")
	collision_shape.disabled = true
	await animation_player.animation_finished

func drop_gun():
	in_hand = false
	animation_player.play("GUN RRETURN")
	await animation_player.animation_finished
	collision_shape.disabled = false


func enemy_hold():
	animation_player.play("ENEMY PICKUP")
	await animation_player.animation_finished


func enemy_drop_gun():
	animation_player.play("ENEMY RETURN GUN")
	await animation_player.animation_finished


func player_shoot_self():
	animation_player.play("AIM  SELF")
	await animation_player.animation_finished


func player_shoot_enemy():
	animation_player.play("AIM ENEMY")
	await animation_player.animation_finished



func enemy_shoot_self():
	animation_player.play("ENEMY KILL SELF")
	await animation_player.animation_finished


func enemy_shoot_player():
	animation_player.play("ENEMY KILL AIM ")
	await animation_player.animation_finished
	await get_tree().create_timer(1.5).timeout


func player_shoot_self_return():
	animation_player.play("SHOOT SELF GUN RETURN")
	await animation_player.animation_finished


func player_shoot_enemy_return():
	animation_player.play("SHOOT ENEMY GUN RETURN")
	await animation_player.animation_finished


func enemy_shoot_self_return():
	animation_player.play("ENEMY KILL SELF UNAIM")
	await animation_player.animation_finished


func enemy_shoot_player_return():
	animation_player.play("ENEMY KILL UNAIM")
	await animation_player.animation_finished


func shoot_bullet(next_bullet):
	print("should have shot")
	if next_bullet == GameManager.BulletType.LIVE:
		print("is live")
		GameManager.camera.shake_screen()
		if current_target == GameManager.enemy:
			GameManager.enemy.blood_particles()
		elif current_target == GameManager.player:
			GameManager.player.blood_particles()
	elif next_bullet == GameManager.BulletType.BLANK:
		print("is blank")
	return


func shoot(shooter:Node3D, target:Node3D, next_bullet:GameManager.BulletType):
	current_target = target
	var is_live_bullet
	if next_bullet == GameManager.BulletType.LIVE:
		is_live_bullet = true
		GameManager.current_bullet_damage = GameManager.damage
	elif next_bullet == GameManager.BulletType.BLANK:
		is_live_bullet = false
	GameManager.loaded_bullets_array.remove_at(0)
	if shooter == GameManager.enemy:
		if target == GameManager.enemy:
			await enemy_hold()
			await enemy_shoot_self()
			shoot_bullet(next_bullet)
			await enemy_shoot_self_return()
			await enemy_drop_gun()
			if is_live_bullet:
				GameManager.enemy_health -= GameManager.damage
		elif target == GameManager.player:
			await enemy_hold()
			await enemy_shoot_player()
			shoot_bullet(next_bullet)
			await enemy_shoot_player_return()
			await enemy_drop_gun()
			if is_live_bullet:
				GameManager.player_health -= GameManager.damage
	elif shooter == GameManager.player:
		if target == GameManager.enemy:
			await player_shoot_enemy()
			shoot_bullet(next_bullet)
			await player_shoot_enemy_return()
			await drop_gun()
			if is_live_bullet:
				GameManager.enemy_health -= GameManager.damage
		elif target == GameManager.player:
			await player_shoot_self()
			shoot_bullet(next_bullet)
			await player_shoot_self_return()
			await drop_gun()
			if is_live_bullet:
				GameManager.player_health -= GameManager.damage
	# Checks if bullet was live or blank
	
	# Waits for animation to finish
	# Add animation later
	await get_tree().create_timer(1, false).timeout
	#play_sound_cock()
	var bullet = GameManager.bullet_gravity_scene.instantiate()
	var level_node = get_tree().root
	level_node.add_child(bullet)
	var mesh = bullet.get_node("MeshInstance3D")
	var base_mat = mesh.get_active_material(0)
	var mat = base_mat.duplicate()
	if is_live_bullet:
		mat.albedo_color = Color(1, 0, 0)
	else:
		mat.albedo_color = Color(0, 0, 1)
	mesh.set_surface_override_material(0, mat)
	bullet.global_position = Vector3(GameManager.live_bullet_pos.global_position.x, GameManager.live_bullet_pos.global_position.y + 0.1, GameManager.live_bullet_pos.global_position.z - (float(GameManager.used_shells)/6))
	bullet.rotation = Vector3(0, 0, deg_to_rad(90))
	GameManager.used_shells_array.append(bullet)
	GameManager.used_shells += 1
	#move_to(original_pos, original_rot, gun_lerp_speed)
