shader_type spatial;
uniform float time_mult: hint_range(0.0, 10.0, 0.1) = 5;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float color = (sin(TIME * time_mult) + 1.0) / 4.0 + 0.5;
	ALBEDO = vec3(color, color, color);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
