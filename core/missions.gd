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
	var m3 := MissionDef.new()
	m3.id = "m3"
	m3.title = "A Biblioteca Corrompida"
	m3.briefing = "O mapa de Dagruve aponta para uma biblioteca abandonada. Entre os livros sussurrantes, gárgulas acordam e uma voz distante pede ajuda."
	m3.cast = CAST_M2
	m3.requires = ["m2"]
	m3.rooms = Rooms.rooms_m3()
	m3.edges = [[1, 2], [2, 3]]
	m3.start = 1
	m3.dungeon_module = "dungeon_m3"
	m3.situations = MissionM3.situations()
	m3.lore_module = "lore_m3"
	m3.completion_xp = 40
	m3.boss_id = "gargula_corrompida"
	m3.event_ids = []
	m3.event_rooms = []
	m3.ambientes = {1: "biblioteca", 2: "biblioteca", 3: "biblioteca"}
	var m4 := MissionDef.new()
	m4.id = "m4"
	m4.title = "O Resgate em Rodhe's Bridge"
	m4.briefing = "Kein foi levado por rebeldes em carroças. Alcance Rodhe's Bridge sob a chuva, liberte os nobres e descubra por que Bella o chama de irmão."
	m4.cast = CAST_M2
	m4.requires = ["m3"]
	m4.rooms = Rooms.rooms_m4()
	m4.edges = [[1, 2], [2, 3]]
	m4.start = 1
	m4.dungeon_module = "dungeon_m4"
	m4.situations = MissionM4.situations()
	m4.lore_module = "lore_m4"
	m4.completion_xp = 50
	m4.boss_id = "rebelde_ponte"
	m4.event_ids = []
	m4.event_rooms = []
	m4.ambientes = {1: "cais", 2: "cais", 3: "cais"}
	var m5 := MissionDef.new()
	m5.id = "m5"
	m5.title = "O Santuário de Astherion"
	m5.briefing = "No cemitério de Dagruve, a fratura da Tarn leva a um santuário além da realidade. Encontre o rastro de Bromnor, enfrente Astherion e feche a fenda de vez."
	m5.cast = CAST_M2
	m5.requires = ["m4"]
	m5.rooms = Rooms.rooms_m5()
	m5.edges = [[1, 2], [2, 3]]
	m5.start = 1
	m5.dungeon_module = "dungeon_m5"
	m5.situations = MissionM5.situations()
	m5.lore_module = "lore_m5"
	m5.completion_xp = 60
	m5.boss_id = "astherion_fase_2"
	m5.event_ids = []
	m5.event_rooms = []
	m5.ambientes = {1: "rachadura", 2: "rachadura", 3: "ritual"}
	var m6 := MissionDef.new()
	m6.id = "m6"
	m6.title = "Willie, o Amálgama Abissal"
	m6.briefing = "As Docas ficaram vazias. Siga a névoa verde pelos barcos abandonados e descubra o que Willie se tornou antes que a maré o leve de volta."
	m6.cast = CAST_M2
	m6.requires = ["m5"]
	m6.rooms = Rooms.rooms_m6()
	m6.edges = [[1, 2], [2, 3]]
	m6.start = 1
	m6.dungeon_module = "dungeon_m6"
	m6.situations = MissionM6.situations()
	m6.lore_module = "lore_m6"
	m6.completion_xp = 70
	m6.boss_id = "willie_amalgame"
	m6.event_ids = []
	m6.event_rooms = []
	m6.ambientes = {1: "docas", 2: "docas", 3: "cais"}
	var m7 := MissionDef.new()
	m7.id = "m7"
	m7.title = "O Espeto de Pau"
	m7.briefing = "A pista de Bromnor leva a uma ferraria abandonada. Decifre as fornalhas, atravesse os portais gêmeos e descubra o que o Espeto de Pau escondia sob a cidade."
	m7.cast = CAST_M2
	m7.requires = ["m6"]
	m7.rooms = Rooms.rooms_m7()
	m7.edges = [[1, 2], [2, 3], [3, 4]]
	m7.start = 1
	m7.dungeon_module = "dungeon_m7"
	m7.situations = MissionM7.situations()
	m7.lore_module = "lore_m7"
	m7.completion_xp = 80
	m7.boss_id = "mimico"
	m7.event_ids = []
	m7.event_rooms = []
	# O percurso em primeira pessoa reutiliza o kit de corredor; a identidade de
	# ferraria é apresentada pelas artes de sala no encontro e no combate.
	m7.ambientes = {1: "corredor", 2: "corredor", 3: "corredor", 4: "corredor"}
	var m8 := MissionDef.new()
	m8.id = "m8"
	m8.title = "A Vila das Sombras"
	m8.briefing = "A névoa esconde uma vila inteira. Encontre a verdade por trás da pousada vazia, atravesse a Igreja das Sombras e siga a última pista de Bromnor."
	m8.cast = CAST_M2
	m8.requires = ["m7"]
	m8.rooms = Rooms.rooms_m8()
	m8.edges = [[1, 2], [2, 3], [3, 4]]
	m8.start = 1
	m8.dungeon_module = "dungeon_m8"
	m8.situations = MissionM8.situations()
	m8.lore_module = "lore_m8"
	m8.completion_xp = 90
	m8.boss_id = "demonio_sedutor"
	m8.event_ids = []
	m8.event_rooms = []
	m8.ambientes = {1: "corredor", 2: "corredor", 3: "corredor", 4: "igreja_porta"}
	var m9 := MissionDef.new()
	m9.id = "m9"
	m9.title = "O Confronto com Kein"
	m9.briefing = "A trilha dos artefatos leva à raiz do Plano Abissal. Atravesse o templo, alcance o altar e impeça que a última luz de Nottgard seja tomada."
	m9.cast = CAST_M2
	m9.requires = ["m8"]
	m9.rooms = Rooms.rooms_m9()
	m9.edges = [[1, 2], [2, 3]]
	m9.start = 1
	m9.dungeon_module = "dungeon_m9"
	m9.situations = MissionM9.situations()
	m9.lore_module = "lore_m9"
	m9.completion_xp = 100
	m9.boss_id = "death_tyrant"
	m9.event_ids = []
	m9.event_rooms = []
	m9.ambientes = {1: "corredor", 2: "altar", 3: "altar"}
	_all = {"m1": m1, "m2": m2, "m3": m3, "m4": m4, "m5": m5, "m6": m6, "m7": m7, "m8": m8, "m9": m9}

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
