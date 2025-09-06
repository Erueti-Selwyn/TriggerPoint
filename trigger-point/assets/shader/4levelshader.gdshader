shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,filter_linear_mipmap;
uniform vec4 level1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 level2 : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 level3 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 level4 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float threshold1 	: hint_range(0.0,1.0) = .0;
uniform float threshold2 	: hint_range(0.0,1.0) = .1;
uniform float threshold3	: hint_range(0.0,1.0) = .2;


void fragment(){
	vec4 c_texture = texture(SCREEN_TEXTURE, SCREEN_UV).rgba;
	ALBEDO = c_texture.rgb;
	ALPHA = c_texture.a;
	
	float rgb_avg = (ALBEDO.r + ALBEDO.g + ALBEDO.b)/3.0;
	if(rgb_avg < threshold1){
		ALBEDO = level1.rgb;
		ALPHA = level1.a;
		
	}else if(rgb_avg < threshold2){
		ALBEDO = level2.rgb;
		ALPHA = level2.a;

	}else if(rgb_avg < threshold3){
		ALBEDO = level3.rgb;
		ALPHA = level3.a;

	}else{
		ALBEDO = level4.rgb;
		ALPHA = level4.a;
	}
}