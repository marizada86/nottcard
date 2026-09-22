shader_type canvas_item;
// Piso e teto por projeção (world_view.py::_draw_floor_ceiling): resolução interna 480x270, faixa de 240x68 ampliada 2x, névoa por linha.
uniform sampler2D floor_tex : repeat_enable, filter_nearest;
uniform sampler2D ceil_tex : repeat_enable, filter_nearest;
uniform vec2 cam_pos = vec2(0.0);
uniform vec2 cam_dir = vec2(0.0, -1.0);
uniform vec2 cam_plane = vec2(0.66, 0.0);
uniform vec3 flat_floor = vec3(0.157, 0.149, 0.173);
uniform vec3 flat_ceiling = vec3(0.11, 0.11, 0.141);
uniform bool has_floor = true;
uniform bool has_ceiling = true;

const float FOG_DIST = 9.0;
const float MIN_LIGHT = 0.18;

float smooth01(float t) {
	t = clamp(t, 0.0, 1.0);
	return t * t * (3.0 - 2.0 * t);
}

void fragment() {
	vec2 p = floor(UV * vec2(480.0, 270.0));
	bool is_floor = p.y >= 135.0;
	float y = is_floor ? (p.y - 135.0) : (134.0 - p.y);
	float row = floor(y / 2.0);
	float dist = 68.0 / (row + 0.5);
	float c = floor(p.x / 2.0);
	float cam = 2.0 * c / 240.0 - 1.0;
	vec2 w = cam_pos + dist * (cam_dir + cam_plane * cam);
	float fog = 1.0 - (1.0 - MIN_LIGHT) * smooth01(dist / FOG_DIST);
	vec3 col;
	if (is_floor) {
		col = has_floor ? texture(floor_tex, fract(w)).rgb : flat_floor;
	} else {
		col = has_ceiling ? texture(ceil_tex, fract(w)).rgb : flat_ceiling;
	}
	COLOR = vec4(col * fog, 1.0);
}
