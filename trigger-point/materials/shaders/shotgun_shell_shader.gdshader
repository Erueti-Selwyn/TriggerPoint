shader_type spatial;
uniform bool is_live = true;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (is_live == true) {
		ALBEDO = vec3(0.4, 0, 0);
		}
	else {
		ALBEDO = vec3(0, 0, 0.4);
		}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
