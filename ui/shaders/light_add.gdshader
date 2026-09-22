shader_type canvas_item;
render_mode blend_add;
// O halo quente da luz de tocha (soma). `k` é a tremulação (0,9..1,1).
uniform float k = 1.0;
const vec3 WARM = vec3(38.0, 24.0, 10.0) / 255.0;

void fragment() {
	vec2 c = vec2(0.5, 0.52);
	vec2 d = (UV - c) * vec2(1.0, 0.5625);
	float r = clamp(length(d) / 0.46, 0.0, 1.0);
	float f = 1.0 - pow(r, 1.6);
	COLOR = vec4(WARM * k * f, 1.0);
}
