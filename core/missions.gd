class_name Missions
extends RefCounted
## game/core/missions.py — o catálogo de missões (M1 e M2) e a missão ativa.

const STARTERS := ["kayron", "durvall", "sylas", "maelor"]
const BROOK := "brook"
const CAST_M1 := STARTERS
const CAST_M2 := ["kayron", "durvall", "sylas", "maelor", "brook"]

static var _all: Dictionary = {}
static var _current: String = "m1"

static func _build() -> void:
	if not _all.is_empty():
		return
	var sit_m1: Dictionary = Exploration.situations()
	var m1 := MissionDef.new()
	m1.id = "m1"
	m1.title = "A Fechadura da Fenda nas Docas"
	m1.briefing = "Uma fenda na Tarn deixa a névoa escapar sob as docas. Desça ao porão e desfaça o ritual antes que ela cresça."
	m1.cast = CAST_M1
	m1.requires = []
	m1.rooms = Rooms.rooms_m1()
	m1.edges = WorldMap.M1_EDGES
	m1.start = WorldMap.M1_START
	m1.dungeon_module = "dungeon_m1"
	m1.situations = sit_m1
	m1.lore_module = "lore_m1"
	m1.completion_xp = Rooms.CONCLUSAO_XP
	m1.boss_id = "guardiao_verdadeiro"
	m1.event_ids = null
	m1.event_rooms = [2, 3, 4, 5, 6]
	m1.ambientes = {1: "docas", 2: "cais", 3: "rachadura", 4: "porao", 5: "biblioteca", 6: "corredor", 7: "ritual"}
	m1.exit_hq = "hq_001"
	var m2d: Dictionary = GameData.module("mission_m2")
	var m2 := MissionDef.new()
	m2.id = "m2"
	m2.title = "A Praça da Loucura"
	m2.briefing = "Em Dagruve, o culto A Mente Derretida prepara um ritual numa igreja abandonada. Siga as pistas, invada a praça e interrompa o rito antes que ele encontre o que procura."
	m2.cast = CAST_M2
	m2.requires = ["m1"]
	m2.rooms = Rooms.rooms_m2()
	m2.edges = m2d["EDGES_M2"]
	m2.start = m2d["START_M2"]
	m2.dungeon_module = "dungeon_m2"
	m2.situations = m2d["SITUATIONS_M2"]
	m2.lore_module = "lore_m2"
	m2.completion_xp = m2d["COMPLETION_XP_M2"]
	m2.boss_id = "sacerdote_mente_derretida"
	m2.event_ids = ["bau", "mercador", "altar", "viajante", "frasco"]
	m2.event_rooms = [2, 3, 4, 5]
	m2.ambientes = {1: "dagruve_entrada", 2: "praca", 3: "beco", 4: "igreja_porta", 5: "nave", 6: "altar"}
	m2.exit_hq = "hq_003"
	m2.briefing_hq = "hq_002"
	m2.unlocks_achievements = ["concluir_m2"]
	_all = {"m1": m1, "m2": m2}

static func all() -> Dictionary:
	_build()
	return _all

static func current() -> MissionDef:
	_build()
	return _all[_current]

## Devolve null se a missão é desconhecida (a origem levanta KeyError).
static func set_current(mission_id: String) -> Variant:
	_build()
	if not _all.has(mission_id):
		return null
	_current = mission_id
	return _all[mission_id]

## A névoa de chão da sala cujo cenário é `asset_id`, em qualquer missão; null se não há.
static func fog_for_backdrop(asset_id: Variant) -> Variant:
	_build()
	for m in _all.values():
		for r in m.rooms:
			if r.asset_id == asset_id:
				return r.fog
	return null

static func is_unlocked(mission: MissionDef, completed: Dictionary) -> bool:
	for m in mission.requires:
		if not completed.has(m):
			return false
	return true
