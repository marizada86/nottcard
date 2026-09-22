class_name MissionDef
extends RefCounted
## game/core/missions.py::MissionDef — só o que varia entre missões (salas, grafo, masmorra, situações, lore, XP, chefe, HQs).

var id: String = ""
var title: String = ""
var briefing: String = ""
var cast: Array = []
var requires: Array = []
var rooms: Array = []
var edges: Array = []
var start: int = 1
var dungeon_module: String = ""    # "dungeon_m1" | "dungeon_m2"
var situations: Dictionary = {}    # sala → Situation
var lore_module: String = ""       # "lore_m1" | "lore_m2"
var completion_xp: int = 0
var boss_id: String = ""
var event_ids: Variant = null      # null = todos os eventos
var event_rooms: Array = [2, 3, 4, 5, 6]
var ambientes: Dictionary = {}
var exit_hq: String = ""
var briefing_hq: String = ""
var unlocks_achievements: Array = []

var _dungeon: Dungeon = null

var dungeon: Dungeon:
	get:
		if _dungeon == null:
			_dungeon = Dungeon.load_module(dungeon_module)
		return _dungeon

func room(room_id: int) -> Variant:
	for r in rooms:
		if r.id == room_id:
			return r
	return null

func index_of(room_id: int) -> int:
	for i in range(rooms.size()):
		if rooms[i].id == room_id:
			return i
	return -1

func make_world() -> WorldMap:
	return WorldMap.new(edges, start)

var rooms_by_id: Dictionary:
	get:
		var d := {}
		for r in rooms:
			d[r.id] = r
		return d

func ambiente(room_id: int) -> String:
	return ambientes.get(room_id, "corredor")

func room_intro(room_id: int) -> String:
	return Lore.room_intro(lore_module, room_id)

func enemy_flavor(enemy_name: String) -> String:
	return Lore.enemy_flavor(lore_module, enemy_name)

func run_end(outcome: String) -> String:
	return Lore.run_end(lore_module, outcome)
