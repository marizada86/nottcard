class_name Dungeon
extends RefCounted
## game/core/dungeon_m1.py e dungeon_m2.py — a masmorra em grade de uma missão (dados exportados + construção da grade).

var module_name: String = ""
var room_rects: Dictionary = {}      # sala → [x0, y0, x1, y1]
var corridors: Array = []            # [[x0, y0, x1, y1], ...]
var doors: Dictionary = {}           # Vector2i → sala a que dá acesso
var start: Array = []                # [x, y, direção]
var anchors: Dictionary = {}         # sala → Vector2i
var enemy_cells: Dictionary = {}     # sala → Array[Vector2i]
var prop_cells: Dictionary = {}      # sala → [[Vector2i, nome], ...]
var marker_rooms: Array = []
var encounter_range: int = 2

static func load_module(mod: String) -> Dungeon:
	var d: Dictionary = GameData.module(mod)
	var g := Dungeon.new()
	g.module_name = mod
	g.room_rects = d["ROOM_RECTS"]
	g.corridors = d["CORRIDORS"]
	for k in d["DOORS"]:
		g.doors[_cell(k)] = d["DOORS"][k]
	g.start = d["START"]
	for room in d["ANCHORS"]:
		g.anchors[room] = Vector2i(d["ANCHORS"][room][0], d["ANCHORS"][room][1])
	for room in d["ENEMY_CELLS"]:
		var cells: Array = []
		for c in d["ENEMY_CELLS"][room]:
			cells.append(Vector2i(c[0], c[1]))
		g.enemy_cells[room] = cells
	for room in d["PROP_CELLS"]:
		var props: Array = []
		for p in d["PROP_CELLS"][room]:
			props.append([Vector2i(p[0][0], p[0][1]), p[1]])
		g.prop_cells[room] = props
	g.marker_rooms = d["MARKER_ROOMS"]
	g.encounter_range = d["ENCOUNTER_RANGE"]
	return g

## Chave "x,y" (tupla exportada) → Vector2i.
static func _cell(k: Variant) -> Vector2i:
	if k is Vector2i:
		return k
	var parts := String(k).split(",")
	return Vector2i(int(parts[0]), int(parts[1]))

## Uma célula livre da sala para o marcador de um evento (fora da âncora, dos inimigos e dos adereços).
func event_cell(room: int, rng: PyRandom) -> Vector2i:
	var r: Array = room_rects[room]
	var taken := {}
	taken[anchors[room]] = true
	for c in enemy_cells.get(room, []):
		taken[c] = true
	for p in prop_cells.get(room, []):
		taken[p[0]] = true
	var free: Array = []
	for y in range(r[1], r[3] + 1):
		for x in range(r[0], r[2] + 1):
			var v := Vector2i(x, y)
			if not taken.has(v) and maxi(absi(x - anchors[room].x), absi(y - anchors[room].y)) > 1:
				free.append(v)
	return rng.choice(free if not free.is_empty() else [Vector2i(r[0], r[1])])

## A grade da missão: retângulos das salas, corredores e portas.
func build() -> NavGrid:
	var w := 0
	var h := 0
	for r in room_rects.values():
		w = maxi(w, r[2])
		h = maxi(h, r[3])
	w += 2
	h += 2
	var cells: Array = []
	for _y in range(h):
		var row: Array = []
		for _x in range(w):
			row.append(NavGrid.WALL)
		cells.append(row)
	for r in room_rects.values():
		_carve(cells, r)
	for r in corridors:
		_carve(cells, r)
	for d in doors:
		cells[d.y][d.x] = NavGrid.DOOR
	var regions: Array = []
	for room in room_rects:
		var r: Array = room_rects[room]
		regions.append([room, r[0], r[1], r[2], r[3]])
	var rows: Array = []
	for row in cells:
		rows.append("".join(row))
	return NavGrid.from_rows(rows, regions, doors)

static func _carve(cells: Array, r: Array) -> void:
	for y in range(r[1], r[3] + 1):
		for x in range(r[0], r[2] + 1):
			cells[y][x] = NavGrid.FLOOR

func ascii_map() -> String:
	return "\n".join(build().rows)
