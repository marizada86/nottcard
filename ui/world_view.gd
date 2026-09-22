class_name WorldView
extends Control
## game/ui/world_view.py — o mundo em primeira pessoa. Piso e teto por shader (projeção), paredes por raycast em GDScript (uma faixa de textura por
## coluna interna de 480), cartazes com oclusão pelo zbuffer e luz de tocha (halo quente + vinheta) por shaders. 1280x720 lógicos.

const INTERNAL_W := 480
const INTERNAL_H := 270
const BILLBOARD_HEIGHT := 0.85
const PROP_BILLBOARD_HEIGHT := 0.62

var walker: Walker
var mission: MissionDef
var pos: Vector2 = Vector2.ZERO
var angle: float = 0.0
var sprites: Array = []      # [{x, y, kind: enemy|prop|marker, slug}]
var time: float = 0.0
var flicker: bool = true

var _floor_rect: ColorRect
var _walls: Control
var _light_add: ColorRect
var _light_mul: ColorRect
var _zbuf: PackedFloat32Array = PackedFloat32Array()

func _init() -> void:
	size = Vector2(Gfx.W, Gfx.H)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_zbuf.resize(INTERNAL_W)
	_floor_rect = ColorRect.new()
	_floor_rect.size = size
	_floor_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fm := ShaderMaterial.new()
	fm.shader = load("res://ui/shaders/floor_ceiling.gdshader")
	_floor_rect.material = fm
	add_child(_floor_rect)
	_walls = Control.new()
	_walls.size = size
	_walls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_walls.draw.connect(_draw_walls_and_sprites)
	add_child(_walls)
	_light_add = _light_rect("res://ui/shaders/light_add.gdshader")
	_light_mul = _light_rect("res://ui/shaders/light_mul.gdshader")

func _light_rect(shader_path: String) -> ColorRect:
	var r := ColorRect.new()
	r.size = size
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := ShaderMaterial.new()
	m.shader = load(shader_path)
	r.material = m
	add_child(r)
	return r

## A intensidade da tremulação em `t` segundos (world_view.flicker_intensity).
static func flicker_intensity(t: float) -> float:
	var wave := 0.6 * sin(TAU * 0.7 * t + 0.4) + 0.4 * sin(TAU * 1.9 * t + 2.1)
	return 1.0 + 0.075 * wave

## Atualiza o quadro: posição/ângulo já animados.
func set_frame(p: Vector2, a: float, sprites_: Array, dt: float) -> void:
	pos = p
	angle = a
	sprites = sprites_
	time += dt
	var room := WorldArt.room_for_cell(walker.grid, int(floor(p.x)), int(floor(p.y)))
	var cam := WorldArt.camera_vectors(a)
	var m: ShaderMaterial = _floor_rect.material
	var ft := WorldArt.texture(mission, room, "floor")
	var ct := WorldArt.texture(mission, room, "ceiling")
	m.set_shader_parameter("floor_tex", ft)
	m.set_shader_parameter("ceil_tex", ct)
	m.set_shader_parameter("has_floor", ft != null)
	m.set_shader_parameter("has_ceiling", ct != null)
	m.set_shader_parameter("cam_pos", p)
	m.set_shader_parameter("cam_dir", Vector2(cam[0], cam[1]))
	m.set_shader_parameter("cam_plane", Vector2(cam[2], cam[3]))
	var k := flicker_intensity(time) if flicker else 1.0
	(_light_add.material as ShaderMaterial).set_shader_parameter("k", k)
	(_light_mul.material as ShaderMaterial).set_shader_parameter("k", k)
	_walls.queue_redraw()

func _draw_walls_and_sprites() -> void:
	var cam := WorldArt.camera_vectors(angle)
	var scale := float(Gfx.W) / INTERNAL_W
	var vscale := float(Gfx.H) / INTERNAL_H
	var half := INTERNAL_H / 2
	for column in range(INTERNAL_W):
		var cam_x := 2.0 * (column + 0.5) / INTERNAL_W - 1.0
		var rdx: float = cam[0] + cam[2] * cam_x
		var rdy: float = cam[1] + cam[3] * cam_x
		var hit: Variant = WorldArt.cast_ray(walker, pos.x, pos.y, rdx, rdy)
		if hit == null:
			_zbuf[column] = WorldArt.MAX_DIST
			continue
		var dist: float = hit["dist"]
		_zbuf[column] = dist
		var before: Vector2i = hit["before"]
		var room := WorldArt.room_for_cell(walker.grid, before.x, before.y)
		var cell: Vector2i = hit["cell"]
		var tex: Texture2D
		if walker.grid.is_door(cell.x, cell.y):
			var door_room: int = walker.grid.door_rooms.get(cell, 0)
			tex = WorldArt.door_texture(mission, room, WorldArt.door_slug(mission, door_room))
		else:
			tex = WorldArt.texture(mission, room, "wall")
		var level := WorldArt.level_brightness(WorldArt.fog_index(dist)) * (WorldArt.FACE_NS if hit["side"] == 1 else 1.0)
		var line_h := int(INTERNAL_H / dist)
		var top := half - line_h / 2
		var dest := Rect2(floor(column * scale), top * vscale, ceil(scale) + 0.0, line_h * vscale)
		if tex == null:
			_walls.draw_rect(dest, Color(0.275 * level, 0.259 * level, 0.29 * level))
			continue
		var tw := tex.get_width()
		var th := tex.get_height()
		var sx := minf(float(tw - 1), floor(hit["u"] * tw))
		_walls.draw_texture_rect_region(tex, dest, Rect2(sx, 0, 1, th), Color(level, level, level))
	_draw_sprites(cam, scale, vscale, half)

func _draw_sprites(cam: Array, scale: float, vscale: float, half: int) -> void:
	var projected: Array = []
	for s in sprites:
		var pr: Variant = WorldArt.project_sprite(pos.x, pos.y, cam, s["x"], s["y"], INTERNAL_W)
		if pr != null:
			projected.append([pr[1], pr[0], s])
	projected.sort_custom(func(a, b): return a[0] > b[0])
	for entry in projected:
		var depth: float = entry[0]
		var screen_x: int = entry[1]
		var s: Dictionary = entry[2]
		var height := PROP_BILLBOARD_HEIGHT if s["kind"] == "prop" else BILLBOARD_HEIGHT
		var size_px := int(height * INTERNAL_H / depth)
		if size_px < 4 or size_px > INTERNAL_H * 4:
			continue
		var bottom := half + int(0.5 * INTERNAL_H / depth)
		var level := WorldArt.level_brightness(WorldArt.fog_index(depth))
		if s["kind"] == "marker":
			_draw_marker(screen_x * scale, (bottom - size_px / 2.0) * vscale, size_px * vscale)
			continue
		var tex: Texture2D = WorldArt.enemy_billboard(s["slug"]) if s["kind"] == "enemy" else WorldArt.prop_billboard(s["slug"])
		if tex == null:
			continue
		var width := maxi(1, int(round(size_px * float(tex.get_width()) / tex.get_height())))
		var left := screen_x - width / 2
		var top := bottom - size_px
		var x0 := maxi(0, left)
		var x1 := mini(INTERNAL_W, left + width)
		var run_start := -1
		for column in range(x0, x1 + 1):
			var visible := column < x1 and _zbuf[column] > depth
			if visible and run_start < 0:
				run_start = column
			elif not visible and run_start >= 0:
				var u0 := float(run_start - left) / width
				var u1 := float(column - left) / width
				var dest := Rect2(run_start * scale, top * vscale, (column - run_start) * scale, size_px * vscale)
				var src := Rect2(u0 * tex.get_width(), 0, (u1 - u0) * tex.get_width(), tex.get_height())
				_walls.draw_texture_rect_region(tex, dest, src, Color(level, level, level))
				run_start = -1

func _draw_marker(cx: float, cy: float, size_px: float) -> void:
	var pulse := 0.5 + 0.5 * sin(time * 3.0)
	var radii := [0.46, 0.34, 0.2]
	for i in range(3):
		var a := (90.0 + 120.0 * pulse) * (1.0 - i * 0.25) / 255.0
		_walls.draw_arc(Vector2(cx, cy), size_px * 0.5 * radii[i] * 2.0 * 0.5, 0.0, TAU, 40, Color(1.0, 0.745, 0.353, a), maxf(2.0, size_px / 22.0), true)
	_walls.draw_circle(Vector2(cx, cy), maxf(2.0, size_px / 14.0 * 0.5), Color(1.0, 0.92, 0.667, 0.78))
