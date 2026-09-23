class_name QaScenarios
extends RefCounted
## Catálogo derivado de destinos reais: não expõe conteúdo sem rota implementada.

static func all() -> Array:
	var out: Array = [QaScenario.make({"id": "screen-menu", "title": "Menu principal", "group": "Telas", "kind": "menu", "description": "Voltar ao menu normal."})]
	for mission in Missions.all().values():
		out.append(QaScenario.make({"id": "%s-walk" % mission.id, "title": "%s — entrada" % mission.id.to_upper(), "group": mission.id.to_upper(), "kind": "walk", "mission_id": mission.id, "room_id": mission.start, "description": mission.title}))
		for room in mission.rooms:
			if room.kind == Rooms.COMBATE:
				out.append(QaScenario.make({"id": "%s-combat-%d" % [mission.id, room.id], "title": "Combate: %s" % room.name, "group": mission.id.to_upper(), "kind": "combat", "mission_id": mission.id, "room_id": room.id, "description": "Inicia diretamente este combate%s." % (" de chefe" if room.is_boss else "")}))
			elif mission.situations.has(room.id):
				out.append(QaScenario.make({"id": "%s-situation-%d" % [mission.id, room.id], "title": "Situação: %s" % room.name, "group": mission.id.to_upper(), "kind": "situation", "mission_id": mission.id, "room_id": room.id, "description": "Inicia diretamente esta situação."}))
	# Fases que já existem como inimigos independentes também recebem entrada direta.
	out.append(QaScenario.make({"id": "m5-astherion-phase-2", "title": "Chefe: Astherion — fase 2", "group": "M5", "kind": "combat", "mission_id": "m5", "room_id": 3, "description": "Começa diretamente na segunda fase de Astherion.", "enemy_factory": Callable(Enemies, "astherion_fase_2")}))
	out.append(QaScenario.make({"id": "m9-beholder-phase", "title": "Chefe: Beholder — fase 2", "group": "M9", "kind": "combat", "mission_id": "m9", "room_id": 3, "description": "Começa diretamente no Beholder da Raiz.", "enemy_factory": Callable(Enemies, "beholder_do_templo")}))
	out.append(QaScenario.make({"id": "m9-death-tyrant-phase", "title": "Chefe: Death Tyrant — fase 3", "group": "M9", "kind": "combat", "mission_id": "m9", "room_id": 3, "description": "Começa diretamente no Death Tyrant do Véu.", "enemy_factory": Callable(Enemies, "death_tyrant_altar")}))
	for hq_id in HqData.all().keys():
		var hq: Hq = HqData.all()[hq_id]
		out.append(QaScenario.make({"id": "hq-%s" % hq_id, "title": hq.title, "group": "HQ", "kind": "hq", "hq_id": hq_id, "description": "Exibe este interlúdio sem alterar o save normal."}))
	return out
