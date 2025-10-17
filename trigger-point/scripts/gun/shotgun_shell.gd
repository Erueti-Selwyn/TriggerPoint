extends MeshInstance3D

# Variables
var shader_mat: ShaderMaterial


# Changes colour in shader
func set_colour(is_live):
	# Gets current material
	shader_mat = get_active_material(0)
	if shader_mat:
		# Duplicates material
		shader_mat = shader_mat.duplicate()
		self.set_surface_override_material(0, shader_mat)
		# Changes shader paramater to the bullet state
		shader_mat.set_shader_parameter("is_live", is_live)
