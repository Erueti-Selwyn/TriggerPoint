shader_type spatial;
uniform float time_constant : hint_range(0.0, 10.0, 0.1) = 1;
uniform float amplitude_constant : hint_range(0.0, 10.0, 1) = 1;
uniform sampler2D albedo : source_color;

void vertex() {
	VERTEX.y += ((sin(TIME * time_constant) + 1.0) / amplitude_constant);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 tex = texture(albedo, UV);
	ALBEDO = tex.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
