class_name Walker
extends RefCounted
## game/core/walker.py — o caminhante da primeira pessoa: posição e direção numa NavGrid. Cada comando devolve eventos
## (Dictionary com "type": Moved | Turned | Blocked | DoorOpened | EnteredRoom); a animação é só da UI.

var grid: NavGrid
var x: int = 0
var y: int = 0
var facing: int = 0
var opened: Dictionary = {}
var visited: Dictionary = {}
var gate: Callable = Callable()   # (walker, x, y) -> String; motivo não vazio barra o passo
var block_reason: String = ""

func _init(grid_: NavGrid = null, x_: int = 0, y_: int = 0, facing_: int = 0) -> void:
	grid = grid_
	x = x_
	y = y_
	facing = Py.fmod(facing_, 4)
	visited[Vector2i(x_, y_)] = true

var pos: Vector2i:
	get:
		return Vector2i(x, y)

var room: int:
	get:
		return grid.room_at(x, y)

func cell_ahead() -> Vector2i:
	return Vector2i(x, y) + NavGrid.DIRS[facing]

func cell_behind() -> Vector2i:
	return Vector2i(x, y) - NavGrid.DIRS[facing]

func forward() -> Array:
	var c := cell_ahead()
	return _step(c.x, c.y, false)

func backward() -> Array:
	var c := cell_behind()
	return _step(c.x, c.y, true)

func turn_right() -> Array:
	facing = (facing + 1) % 4
	return [{"type": "Turned", "facing": facing, "delta": 1}]

func turn_left() -> Array:
	facing = Py.fmod(facing - 1, 4)
	return [{"type": "Turned", "facing": facing, "delta": -1}]

func strafe_left() -> Array:
	return _side(-1)

func strafe_right() -> Array:
	return _side(1)

func _side(turn: int) -> Array:
	var d: Vector2i = NavGrid.DIRS[Py.fmod(facing + turn, 4)]
	return _step(x + d.x, y + d.y, false)

func about_face() -> Array:
	facing = (facing + 2) % 4
	return [{"type": "Turned", "facing": facing, "delta": 2}]

func _step(nx: int, ny: int, backward_: bool) -> Array:
	block_reason = ""
	if not grid.passable(nx, ny):
		return [{"type": "Blocked", "x": nx, "y": ny}]
	if gate.is_valid():
		block_reason = gate.call(self, nx, ny)
		if block_reason != "":
			return [{"type": "Blocked", "x": nx, "y": ny}]
	var events: Array = []
	var before := room
	x = nx
	y = ny
	visited[Vector2i(nx, ny)] = true
	if grid.is_door(nx, ny) and not opened.has(Vector2i(nx, ny)):
		opened[Vector2i(nx, ny)] = true
		events.append({"type": "DoorOpened", "x": nx, "y": ny})
	events.append({"type": "Moved", "x": nx, "y": ny, "backward": backward_})
	var now := room
	if now != before and now != 0:
		events.append({"type": "EnteredRoom", "room": now})
	return events

## Para o desenho: a célula deixa passar o raio? Chão e porta aberta sim.
func is_open(cx: int, cy: int) -> bool:
	if grid.is_wall(cx, cy):
		return false
	return not grid.is_door(cx, cy) or opened.has(Vector2i(cx, cy))
