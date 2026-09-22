class_name WorldArt
extends RefCounted
## game/ui/world_art.py + scenes_data.py — texturas do mundo em primeira pessoa (parede, piso, teto, porta), névoa e cartazes.

const TEX := 128
const FOG_LEVELS := 16
const MIN_LIGHT := 0.18
const FOG_DIST := 9.0
const FACE_NS := 0.82
const DOOR_BY_ROOM := {"m1": {1: "porta_madeira", 2: "porta_madeira", 3: "porta_pedra", 4: "porta_escada", 5: "porta_escada", 6: "porta_pedra", 7: "porta_ritual"},
	"m2": {1: "porta_madeira", 2: "porta_madeira", 3: "porta_pedra", 4: "porta_pedra", 5: "porta_igreja", 6: "porta_ritual"}}
const DEFAULT_DOOR := "porta_pedra"
const LIGHT_PROPS := {"tocha": 1.0, "braseiro": 1.0, "vela": 0.5}

static var _tex: Dictionary = {}
static var _doors: Dictionary = {}

static func smoothstep01(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

static func fog_level(dist: float) -> float:
	return 1.0 - (1.0 - MIN_LIGHT) * smoothstep01(dist / FOG_DIST)

static func fog_index(dist: float) -> int:
	return int(Py.round_half_even(smoothstep01(dist / FOG_DIST) * (FOG_LEVELS - 1)))

static func level_brightness(index: int) -> float:
	return 1.0 - (1.0 - MIN_LIGHT) * index / (FOG_LEVELS - 1)

## A sala de uma célula; um corredor (sala 0) usa a região mais próxima.
static func room_for_cell(grid: NavGrid, x: int, y: int) -> int:
	var room := grid.room_at(x, y)
	if room != 0:
		return room
	var best := 1
	var best_d := 1000000000
	for r in grid.regions:
		var dx := maxi(maxi(r[1] - x, 0), x - r[3])
		var dy := maxi(maxi(r[2] - y, 0), y - r[4])
		if dx + dy < best_d:
			best = r[0]
			best_d = dx + dy
	return best

## Textura `kind` (wall, floor, ceiling) do ambiente da sala; null se o arquivo não existe (a UI cai numa cor lisa).
static func texture(mission: MissionDef, room: int, kind: String) -> Texture2D:
	var slug := "%s/%s" % [mission.ambiente(room), kind]
	var key := "t|" + slug
	if not _tex.has(key):
		var p := "res://assets/world/%s.png" % slug
		_tex[key] = load(p) if ResourceLoader.exists(p) else null
	return _tex[key]

static func door_slug(mission: MissionDef, room_id: int) -> String:
	return DOOR_BY_ROOM.get(mission.id, {}).get(room_id, DEFAULT_DOOR)

## A parede com a porta no meio (128x128), montada uma vez por (parede, porta).
static func door_texture(mission: MissionDef, room: int, slug: String) -> Texture2D:
	var key := "d|%s|%d|%s" % [mission.id, room, slug]
	if _doors.has(key):
		return _doors[key]
	var wall := texture(mission, room, "wall")
	var img: Image
	if wall != null:
		img = wall.get_image()
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		img.resize(TEX, TEX, Image.INTERPOLATE_NEAREST)
	else:
		img = Image.create(TEX, TEX, false, Image.FORMAT_RGBA8)
		img.fill(Color8(70, 66, 74))
	var art_tex := UiAssets.texture(slug, "doors")
	if art_tex != null:
		var art := art_tex.get_image()
		if art.is_compressed():
			art.decompress()
		art.convert(Image.FORMAT_RGBA8)
		var w := maxi(1, int(round(float(art.get_width()) * TEX / art.get_height())))
		art.resize(w, TEX, Image.INTERPOLATE_NEAREST)
		img.blend_rect(art, Rect2i(0, 0, w, TEX), Vector2i((TEX - w) / 2, 0))
	else:
		img.fill_rect(Rect2i(TEX / 4, TEX / 8, TEX / 2, TEX * 7 / 8), Color8(58, 44, 34))
	var t := ImageTexture.create_from_image(img)
	_doors[key] = t
	return t

static func enemy_billboard(slug: String) -> Texture2D:
	return UiAssets.texture(slug, "enemies")

static func prop_billboard(slug: String) -> Texture2D:
	var key := "p|" + slug
	if not _tex.has(key):
		var p := "res://assets/world/props/%s.png" % slug
		_tex[key] = load(p) if ResourceLoader.exists(p) else null
	return _tex[key]

# -- raycast (ui/raycast.py) ---------------------------------------------------------------------------------

const FOV := 1.1519173063162575   # radians(66)
const MAX_DIST := 48.0

static func facing_angle(facing: int) -> float:
	return deg_to_rad(90.0 * facing)

## [dirx, diry, planex, planey]
static func camera_vectors(angle: float) -> Array:
	angle = fposmod(angle, TAU)
	var dx := sin(angle)
	var dy := -cos(angle)
	var k := tan(FOV / 2.0)
	return [dx, dy, -dy * k, dx * k]

## Anda a grade (DDA); devolve {dist, side, cell, before, u} ou null.
static func cast_ray(walker: Walker, px: float, py: float, rdx: float, rdy: float) -> Variant:
	var mx := int(floor(px))
	var my := int(floor(py))
	var ddx := 1e30 if rdx == 0.0 else absf(1.0 / rdx)
	var ddy := 1e30 if rdy == 0.0 else absf(1.0 / rdy)
	var sx: int
	var sdx: float
	var sy: int
	var sdy: float
	if rdx < 0.0:
		sx = -1
		sdx = (px - mx) * ddx
	else:
		sx = 1
		sdx = (mx + 1.0 - px) * ddx
	if rdy < 0.0:
		sy = -1
		sdy = (py - my) * ddy
	else:
		sy = 1
		sdy = (my + 1.0 - py) * ddy
	var before := Vector2i(mx, my)
	var side := 0
	while true:
		if sdx < sdy:
			sdx += ddx
			before = Vector2i(mx, my)
			mx += sx
			side = 0
		else:
			sdy += ddy
			before = Vector2i(mx, my)
			my += sy
			side = 1
		if not walker.is_open(mx, my):
			break
		if minf(sdx, sdy) > MAX_DIST:
			return null
	var dist := (sdx - ddx) if side == 0 else (sdy - ddy)
	var u: float
	if side == 0:
		u = py + dist * rdy
	else:
		u = px + dist * rdx
	u -= floor(u)
	if (side == 0 and rdx > 0.0) or (side == 1 and rdy < 0.0):
		u = 1.0 - u
	return {"dist": maxf(dist, 1e-3), "side": side, "cell": Vector2i(mx, my), "before": before, "u": u}

## [coluna do centro, profundidade] de um cartaz em (sx, sy), ou null se estiver atrás da câmera.
static func project_sprite(px: float, py: float, cam: Array, sx: float, sy: float, screen_w: int) -> Variant:
	var relx := sx - px
	var rely := sy - py
	var det: float = cam[2] * cam[1] - cam[0] * cam[3]
	if det == 0.0:
		return null
	var inv := 1.0 / det
	var tx: float = inv * (cam[1] * relx - cam[0] * rely)
	var ty: float = inv * (-cam[3] * relx + cam[2] * rely)
	if ty <= 0.05:
		return null
	return [int(screen_w / 2.0 * (1.0 + tx / ty)), ty]
