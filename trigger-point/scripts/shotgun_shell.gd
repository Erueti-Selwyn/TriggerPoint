extends MeshInstance3D

var shader_mat: ShaderMaterial

func set_colour(is_live):
	shader_mat = get_active_material(0)
	if shader_mat:
		shader_mat = shader_mat.duplicate()
		self.surface_set_override_material(0, shader_mat)
		shader_mat.set_shader_parameter("is_live", is_live)
