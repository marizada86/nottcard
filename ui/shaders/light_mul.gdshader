shader_type canvas_item;
render_mode blend_mul;
// A vinheta da luz de tocha (multiplica): as bordas do quadro escurecem.
uniform float k = 1.0;

void fragment() {
	vec2 d = (UV - vec2(0.5)) * vec2(1.0, 0.5625);
	float r = clamp(length(d) / 0.62, 0.0, 1.0);
	float edge = 1.0 - (1.0 - 0.7) * k;
	float v = mix(1.0, edge, pow(r, 1.8));
	COLOR = vec4(vec3(v), 1.0);
}
