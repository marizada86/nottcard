class_name Room
extends RefCounted
## game/core/rooms.py::Room — uma sala do mapa de missão. As fábricas de inimigos são Callables (sem argumentos).

var id: int = 0
var name: String = ""
var kind: String = ""
var asset_id: String = ""
var enemy_factory: Callable = Callable()
var optional: bool = false
var is_boss: bool = false
var group_factory: Callable = Callable()
var xp: int = 0
var reward_tier: int = 0
var fog: Variant = null   # [r, g, b] ou null

static func make(fields: Dictionary) -> Room:
	var r := Room.new()
	for k in fields:
		r.set(k, fields[k])
	return r

func make_enemies() -> Array:
	if group_factory.is_valid():
		return group_factory.call()
	return [enemy_factory.call()]
