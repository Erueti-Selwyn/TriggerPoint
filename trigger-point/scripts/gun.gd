extends StaticBody3D
@export var audio_player_empty : AudioStreamPlayer3D
@export var audio_player_shot : AudioStreamPlayer3D
@export var audio_player_shotgun_cocking : AudioStreamPlayer3D
@export var shoot_player_transform : Node3D
@export var shoot_enemy_transform : Node3D
var gun_lerp_speed:float = 0.1

var hover : bool

var in_hand : bool = false
var is_item : bool = false
@onready var original_pos : Vector3 = global_position
@onready var original_rot : Vector3 = rotation
var target_pos : Vector3
var target_rot : Vector3
var target_speed : float
var inventory_slot : int = 0
var type : String = "gun"
var barrel_node: Node3D = null

func _ready() -> void:
	barrel_node = $barrel_end
	GameManager.gun_node = self

func move_to(pos: Vector3, rot: Vector3, speed: float):
	target_pos = pos
	target_rot = rot
	target_speed = speed
func _physics_process(_delta):
	global_position = global_position.lerp(target_pos, target_speed)
	rotation = rotation.lerp(target_rot, target_speed)

func play_sound_click():
	audio_player_empty.play()
func play_sound_shot():
	audio_player_shot.play()
func play_sound_cock():
	audio_player_shotgun_cocking.play()

func shoot(target_name:String):
	if target_name == "enemy":
		move_to(shoot_enemy_transform.global_position, shoot_enemy_transform.rotation, gun_lerp_speed)
	elif target_name =="player":
		move_to(shoot_player_transform.global_position, shoot_player_transform.rotation, gun_lerp_speed)
	# Checks if bullet was live or blank
	await get_tree().create_timer(1.5, false).timeout
	var is_live_bullet
	if GameManager.loaded_bullets_array[0] == GameManager.BulletType.LIVE:
		play_sound_shot()
		var blood = GameManager.blood_splatter_particle.instantiate()
		add_child(blood)
		blood.global_position = Vector3(barrel_node.global_position.x, barrel_node.global_position.y + 0.4, barrel_node.global_position.z)
		blood.emitting = true
		is_live_bullet = true
		if target_name == "player":
			GameManager.player_health -= GameManager.damage
		elif target_name == "enemy":
			GameManager.enemy_health -= GameManager.damage
		GameManager.damage += 1
		GameManager.current_bullet_damage = GameManager.damage
	elif GameManager.loaded_bullets_array[0] == GameManager.BulletType.BLANK:
		play_sound_click()
		is_live_bullet = false
	GameManager.loaded_bullets_array.remove_at(0)
	# Waits for animation to finish
	# Add animation later
	await get_tree().create_timer(1, false).timeout
	play_sound_cock()
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
	move_to(original_pos, original_rot, gun_lerp_speed)


func reset_pos():
	move_to(original_pos, original_rot, gun_lerp_speed)
