extends Node3D

# Variables
var in_hand : bool = false
var current_target:Node3D

# @onready variables
@onready var animation_player: AnimationPlayer = $Shotgun_Final/AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D 
@onready var gun_shot_audio_stream_player: AudioStreamPlayer3D = $GunShotAudioStreamPlayer3D
@onready var gun_click_audio_stream_player: AudioStreamPlayer3D = $GunClickAudioStreamPlayer3D3
@onready var gun_cock_audio_stream_player: AudioStreamPlayer3D = $GunCockAudioStreamPlayer3D2


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


func player_reload():
	animation_player.play("PLAYER RELOAD")
	gun_cock_audio_stream_player.play()
	await animation_player.animation_finished


func enemy_reload():
	animation_player.play("ENEMY RELOAD")
	gun_cock_audio_stream_player.play()
	await animation_player.animation_finished


func shoot_bullet(next_bullet):
	if next_bullet == GameManager.BulletType.LIVE:
		# Plays gun shot audio and shakes screen
		gun_shot_audio_stream_player.play()
		GameManager.camera.shake_screen()
		# Damages enemy or player and creates blood particles
		if current_target == GameManager.enemy:
			GameManager.enemy.blood_particles()
			GameManager.enemy_health -= GameManager.damage
		elif current_target == GameManager.player:
			GameManager.player.blood_particles()
			GameManager.player_health -= GameManager.damage
	elif next_bullet == GameManager.BulletType.BLANK:
		# Plays gun click audio
		gun_click_audio_stream_player.play()
	return


func shoot(shooter:Node3D, target:Node3D, next_bullet:GameManager.BulletType):
	# Sets the current target
	current_target = target
	if shooter == GameManager.enemy:
		if target == GameManager.enemy:
			# Animations for enemy shooting themselves
			await enemy_hold()
			await enemy_shoot_self()
			await get_tree().create_timer(0.5, false, true).timeout
			shoot_bullet(next_bullet)
			await enemy_shoot_self_return()
			await enemy_reload()
			remove_bullet()
			await enemy_drop_gun()
		elif target == GameManager.player:
			# Animations for enemy shooting player
			await enemy_hold()
			await enemy_shoot_player()
			await get_tree().create_timer(0.5, false, true).timeout
			shoot_bullet(next_bullet)
			await enemy_shoot_player_return()
			await enemy_reload()
			remove_bullet()
			await enemy_drop_gun()
	elif shooter == GameManager.player:
		if target == GameManager.enemy:
			# Animation for player shooting enemy
			await player_shoot_enemy()
			shoot_bullet(next_bullet)
			await player_shoot_enemy_return()
			await player_reload()
			remove_bullet()
			await drop_gun()
		elif target == GameManager.player:
			# Animation for player shooting themselves
			await player_shoot_self()
			await get_tree().create_timer(0.5, false, true).timeout
			shoot_bullet(next_bullet)
			await player_shoot_self_return()
			await player_reload()
			remove_bullet()
			await drop_gun()
	# Removes next bullet and resets gun damage
	GameManager.loaded_bullets_array.remove_at(0)
	GameManager.damage = GameManager.base_damage


# Removes next bullet and leaves it on the table for player to see
func remove_bullet():
	var is_live_bullet: bool
	var bullet_spacing: float = 0.2
	# Gets the bullet status
	if GameManager.loaded_bullets_array[0] == GameManager.BulletType.LIVE:
		is_live_bullet = true
	elif GameManager.loaded_bullets_array[0] == GameManager.BulletType.BLANK:
		is_live_bullet = false
	# Instantiates a bullet object
	var bullet = GameManager.shotgun_shell_scene.instantiate()
	add_child(bullet)
	# Moves it to the table and offset by the amount of used bullets
	bullet.global_position = GameManager.used_bullet_pos.global_position - Vector3(0, 0, bullet_spacing * GameManager.used_shells)
	# Changes bullet colour
	bullet.get_child(0).set_colour(is_live_bullet)
	bullet.rotation = Vector3(0, deg_to_rad(180), deg_to_rad(90))
	# Adds instantiated bullet array to delete when reloading
	GameManager.used_bullets_array.append(bullet)
	GameManager.used_shells += 1
