class_name NavGrid
extends RefCounted
## game/core/gridmap.py — a grade da caminhada em primeira pessoa (parede, chão, porta) e as regiões das salas.
## Regiões: Array de [sala, x0, y0, x1, y1]. Células são Vector2i.

const N := 0
const L := 1
const S := 2
const O := 3
const DIRS := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
const DIR_NAMES := ["N", "L", "S", "O"]
const WALL := "#"
const FLOOR := "."
const DOOR := "D"

var rows: Array = []
var height: int = 0
var width: int = 0
var regions: Array = []
var door_rooms: Dictionary = {}

func _init(rows_: Array = [], regions_: Array = [], door_rooms_: Dictionary = {}) -> void:
	rows = rows_
	height = rows.size()
	for r in rows:
		width = maxi(width, String(r).length())
	regions = regions_
	door_rooms = door_rooms_.duplicate()

static func from_rows(rows_: Array, regions_: Array = [], door_rooms_: Dictionary = {}) -> NavGrid:
	return NavGrid.new(rows_, regions_, door_rooms_)

func cell(x: int, y: int) -> String:
	if 0 <= y and y < height and 0 <= x and x < String(rows[y]).length():
		return String(rows[y])[x]
	return WALL

func is_wall(x: int, y: int) -> bool:
	return cell(x, y) == WALL

func is_door(x: int, y: int) -> bool:
	return cell(x, y) == DOOR

func passable(x: int, y: int) -> bool:
	return not is_wall(x, y)

## A sala a que a célula pertence, ou 0.
func room_at(x: int, y: int) -> int:
	for r in regions:
		if r[1] <= x and x <= r[3] and r[2] <= y and y <= r[4]:
			return r[0]
	return 0

## Região [sala, x0, y0, x1, y1] ou null.
func region_of(room: int) -> Variant:
	for r in regions:
		if r[0] == room:
			return r
	return null

func floor_cells() -> Array:
	var out: Array = []
	for y in range(height):
		for x in range(width):
			if passable(x, y):
				out.append(Vector2i(x, y))
	return out

func neighbors(x: int, y: int) -> Array:
	var out: Array = []
	for d in DIRS:
		if passable(x + d.x, y + d.y):
			out.append(Vector2i(x + d.x, y + d.y))
	return out
