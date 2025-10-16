extends Node3D

var in_hand : bool = false
var type : String = "gun"
var current_target:Node3D
@onready var animation_player = $Shotgun_Final/AnimationPlayer
@onready var collision_shape = $CollisionShape3D 
@onready var gun_shot_audio_stream_player = $GunShotAudioStreamPlayer3D
@onready var gun_click_audio_stream_player = $GunClickAudioStreamPlayer3D3
@onready var gun_cock_audio_stream_player = $GunCockAudioStreamPlayer3D2


func _ready():
	GameManager.shotgun_node = self


func hold():
	in_hand = true
	animation_player.play("GUN SELECT")
	collision_shape.disabled = true
	while animation_player.is_playing() and animation_player.current_animation == "GUN SELECT":
		await get_tree().process_frame


func drop_gun():
	in_hand = false
	animation_player.play("GUN RRETURN")
	while animation_player.is_playing() and animation_player.current_animation == "GUN RRETURN":
		await get_tree().process_frame
	collision_shape.disabled = false


func enemy_hold():
	animation_player.play("ENEMY PICKUP")
	while animation_player.is_playing() and animation_player.current_animation == "ENEMY PICKUP":
		await get_tree().process_frame


func enemy_drop_gun():
	animation_player.play("ENEMY RETURN GUN")
	while animation_player.is_playing() and animation_player.current_animation == "ENEMY RETURN GUN":
		await get_tree().process_frame


func player_shoot_self():
	animation_player.play("AIM  SELF")
	while animation_player.is_playing() and animation_player.current_animation == "AIM  SELF":
		await get_tree().process_frame


func player_shoot_enemy():
	animation_player.play("AIM ENEMY")
	while animation_player.is_playing() and animation_player.current_animation == "AIM ENEMY":
		await get_tree().process_frame


func enemy_shoot_self():
	animation_player.play("ENEMY KILL SELF")
	while animation_player.is_playing() and animation_player.current_animation == "ENEMY KILL SELF":
		await get_tree().process_frame


func enemy_shoot_player():
	animation_player.play("ENEMY KILL AIM ")
	while animation_player.is_playing() and animation_player.current_animation == "ENEMY KILL AIM ":
		await get_tree().process_frame
	await get_tree().create_timer(1.5, true).timeout


func player_shoot_self_return():
	animation_player.play("SHOOT SELF GUN RETURN")
	while animation_player.is_playing() and animation_player.current_animation == "SHOOT SELF GUN RETURN":
		await get_tree().process_frame


func player_shoot_enemy_return():
	animation_player.play("SHOOT ENEMY GUN RETURN")
	while animation_player.is_playing() and animation_player.current_animation == "SHOOT ENEMY GUN RETURN":
		await get_tree().process_frame


func enemy_shoot_self_return():
	animation_player.play("ENEMY KILL SELF UNAIM")
	while animation_player.is_playing() and animation_player.current_animation == "ENEMY KILL SELF UNAIM":
		await get_tree().process_frame


func enemy_shoot_player_return():
	animation_player.play("ENEMY KILL UNAIM")
	while animation_player.is_playing() and animation_player.current_animation == "ENEMY KILL UNAIM":
		await get_tree().process_frame


func player_reload():
	animation_player.play("PLAYER RELOAD")
	gun_cock_audio_stream_player.play()
	while animation_player.is_playing() and animation_player.current_animation == "PLAYER RELOAD":
		await get_tree().process_frame


func enemy_reload():
	animation_player.play("ENEMY RELOAD")
	gun_cock_audio_stream_player.play()
	while animation_player.is_playing() and animation_player.current_animation == "ENEMY RELOAD	":
		await get_tree().process_frame


func shoot_bullet(next_bullet):
	if next_bullet == GameManager.BulletType.LIVE:
		gun_shot_audio_stream_player.play()
		GameManager.camera.shake_screen()
		if current_target == GameManager.enemy:
			GameManager.enemy.blood_particles()
			GameManager.enemy_health -= GameManager.damage
		elif current_target == GameManager.player:
			GameManager.player.blood_particles()
			GameManager.player_health -= GameManager.damage
	elif next_bullet == GameManager.BulletType.BLANK:
		gun_click_audio_stream_player.play()
		print("blank")
	return


func shoot(shooter:Node3D, target:Node3D, next_bullet:GameManager.BulletType):
	current_target = target
	GameManager.loaded_bullets_array.remove_at(0)
	if shooter == GameManager.enemy:
		if target == GameManager.enemy:
			await enemy_hold()
			await enemy_shoot_self()
			await get_tree().create_timer(1.5, true).timeout
			shoot_bullet(next_bullet)
			await enemy_shoot_self_return()
			await enemy_reload()
			remove_bullet()
			await enemy_drop_gun()
		elif target == GameManager.player:
			await enemy_hold()
			await enemy_shoot_player()
			shoot_bullet(next_bullet)
			await enemy_shoot_player_return()
			await enemy_reload()
			remove_bullet()
			await enemy_drop_gun()
	elif shooter == GameManager.player:
		if target == GameManager.enemy:
			await player_shoot_enemy()
			shoot_bullet(next_bullet)
			await player_shoot_enemy_return()
			await player_reload()
			remove_bullet()
			await drop_gun()
		elif target == GameManager.player:
			await player_shoot_self()
			await get_tree().create_timer(1, true).timeout
			shoot_bullet(next_bullet)
			await player_shoot_self_return()
			await player_reload()
			remove_bullet()
			await drop_gun()


func remove_bullet():
	var is_live_bullet: bool
	var bullet_spacing: float = 0.2
	if GameManager.loaded_bullets_array[0] == GameManager.BulletType.LIVE:
		is_live_bullet = false
	elif GameManager.loaded_bullets_array[0] == GameManager.BulletType.BLANK:
		is_live_bullet = true
	var bullet = GameManager.shotgun_shell_scene.instantiate()
	add_child(bullet)
	bullet.global_position = Vector3(GameManager.used_bullet_pos.global_position.x, GameManager.used_bullet_pos.global_position.y, GameManager.used_bullet_pos.global_position.z - (bullet_spacing * GameManager.used_shells))
	bullet.get_child(0).set_colour(is_live_bullet)
	bullet.rotation = Vector3(0, deg_to_rad(180), deg_to_rad(90))
	GameManager.used_shells += 1
	pass
