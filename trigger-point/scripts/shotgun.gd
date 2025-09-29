extends Node3D
var in_hand : bool = false
var type : String = "gun"
@onready var animation_player = $SHOTGUNexam/AnimationPlayer
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
	animation_player.play_backwards("GUN SELECT")
	await animation_player.animation_finished
	collision_shape.disabled = false


func player_shoot_self():
	animation_player.play("SHOOT SELF")
	await animation_player.animation_finished
	animation_player.play_backwards("GUN SELECT")
	await animation_player.animation_finished


func player_shoot_enemy():
	animation_player.play("SHOOTING ENEMY")
	await animation_player.animation_finished
	animation_player.play_backwards("GUN SELECT")
	await animation_player.animation_finished


func enemy_shoot_self():
	animation_player.play("ENEMY SELECT_SELF")
	await animation_player.animation_finished


func enemy_shoot_player():
	animation_player.play("ENEMY SELECT_YOU")
	await animation_player.animation_finished


func shoot(shooter:Node3D, target:Node3D):
	if shooter == GameManager.enemy:
		if target == GameManager.enemy:
			await enemy_shoot_self()
			print("enemy shoot enemy")
			GameManager.enemy_health -= GameManager.damage
		elif target == GameManager.player:
			await enemy_shoot_player()
			print("enemy shoot player")
			GameManager.player_health -= GameManager.damage
	elif shooter == GameManager.player:
		if target == GameManager.enemy:
			await player_shoot_enemy()
			print("player shoot enemy")
			GameManager.enemy_health -= GameManager.damage
		elif target == GameManager.player:
			await player_shoot_self()
			print("player shoot player")
			GameManager.player_health -= GameManager.damage
	# Checks if bullet was live or blank
	var is_live_bullet
	if GameManager.loaded_bullets_array[0] == GameManager.BulletType.LIVE:
		#play_sound_shot()
		#var blood = GameManager.blood_splatter_particle.instantiate()
		#add_child(blood)
		#blood.global_position = Vector3(barrel_node.global_position.x, barrel_node.global_position.y + 0.4, barrel_node.global_position.z)
		#blood.emitting = true
		is_live_bullet = true
		
		GameManager.damage += 1
		GameManager.current_bullet_damage = GameManager.damage
	elif GameManager.loaded_bullets_array[0] == GameManager.BulletType.BLANK:
		#play_sound_click()
		is_live_bullet = false
	GameManager.loaded_bullets_array.remove_at(0)
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
