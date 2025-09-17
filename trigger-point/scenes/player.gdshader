shader_type spatial;
render_mode unshaded;

uniform vec4 level1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 level2 : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec4 level3 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 level4 : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float threshold1 : hint_range(0.0, 1.0) = 0.1;
uniform float threshold2 : hint_range(0.0, 1.0) = 0.4;
uniform float threshold3 : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;

    float rgb_avg = (screen_color.r + screen_color.g + screen_color.b) / 3.0;

    if (rgb_avg < threshold1) {
        ALBEDO = level1.rgb;
    } else if (rgb_avg < threshold2) {
        ALBEDO = level2.rgb;
    } else if (rgb_avg < threshold3) {
        ALBEDO = level3.rgb;
    } else {
        ALBEDO = level4.rgb;
    }
}
