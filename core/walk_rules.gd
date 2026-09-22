class_name WalkRules
extends RefCounted
## game/core/walk_rules.py — o portão do Walker (colisão com inimigo, porta travada).

const ENEMY := "enemy"
const ENEMY_SIDE := "enemy_side"
const LOCKED := "locked"
const LOCKED_TEXT := "Elimine o inimigo primeiro."

## A sala é um combate obrigatório ainda não resolvido?
static func blocks_exit(room: Room, world: WorldMap) -> bool:
	return room.kind == Rooms.COMBATE and not room.optional and not world.is_cleared(room.id)

## O portão do Walker: devolve "" (livre), ENEMY, ENEMY_SIDE ou LOCKED. `rooms_by_id`: sala → Room.
static func make_gate(world: WorldMap, rooms_by_id: Dictionary, dungeon: Dungeon) -> Callable:
	return func(walker: Walker, nx: int, ny: int) -> String:
		var cell := Vector2i(nx, ny)
		for room in dungeon.enemy_cells:
			if cell in dungeon.enemy_cells[room] and not world.is_cleared(room):
				return ENEMY if cell == walker.cell_ahead() else ENEMY_SIDE
		var destination: Variant = dungeon.doors.get(cell)
		if destination != null and walker.room != destination:
			for e in world.edges:
				if e[1] == destination and rooms_by_id.has(e[0]) and blocks_exit(rooms_by_id[e[0]], world):
					return LOCKED
		return ""
