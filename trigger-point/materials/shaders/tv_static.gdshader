shader_type spatial;

uniform float pixel_density : hint_range(10.0, 1000.0) = 300.0; // pixels across screen
uniform float brightness : hint_range(0.0, 1.0) = 0.6;
uniform float flicker_speed : hint_range(0.1, 10.0) = 1.0;

// hash function with minimal directional bias
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

void fragment() {
    vec2 uv = UV;

    // lock to square pixel grid
    uv = floor(uv * pixel_density) / pixel_density;

    // flicker step
    float frame = floor(TIME * flicker_speed);

    // random grayscale per block
    float noise = hash(uv + frame);

    ALBEDO = vec3(noise * brightness);
    ALPHA = 1.0;
}
