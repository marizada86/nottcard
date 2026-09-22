class_name WorldMap
extends RefCounted
## game/core/worldmap.py — o grafo de nós das salas (point-crawl). `visited`/`cleared` são conjuntos {sala: true}.

const M1_EDGES := [[1, 2], [2, 3], [2, 4], [4, 5], [5, 6], [6, 7]]
const M1_START := 1

var edges: Array = M1_EDGES
var start: int = M1_START
var current: int = M1_START
var visited: Dictionary = {}
var cleared: Dictionary = {}

func _init(edges_: Array = M1_EDGES, start_: int = M1_START) -> void:
	edges = edges_
	start = start_
	current = start_
	visited = {start_: true}

func neighbors(node: int) -> Array:
	var out: Array = []
	for e in edges:
		if e[0] == node:
			out.append(e[1])
	for e in edges:
		if e[1] == node:
			out.append(e[0])
	out.sort()
	return out

func can_move_to(node: int) -> bool:
	return node in neighbors(current)

## false se o nó não é vizinho (a origem levanta ValueError).
func move_to(node: int) -> bool:
	if not can_move_to(node):
		return false
	current = node
	visited[node] = true
	return true

func clear(node: int = -1) -> void:
	cleared[current if node < 0 else node] = true

func is_cleared(node: int) -> bool:
	return cleared.has(node)

func visible() -> Dictionary:
	var out := visited.duplicate()
	for n in neighbors(current):
		out[n] = true
	return out

func visible_edges() -> Array:
	var shown := visible()
	var out: Array = []
	for e in edges:
		if shown.has(e[0]) and shown.has(e[1]):
			out.append(e)
	return out
