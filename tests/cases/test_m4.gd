extends RefCounted
## Contrato independente da M4: sequência, salas, assets e cadernos persistidos.

func test_bridge_contract() -> String:
	var all: Dictionary = Missions.all()
	if not all.has("m4"):
		return "M4 não entrou no catálogo"
	var mission: MissionDef = all["m4"]
	if mission.requires != ["m3"] or mission.rooms.size() != 3:
		return "pré-requisito ou número de salas da M4 incorreto"
	if Missions.is_unlocked(mission, {"m2": true}) or not Missions.is_unlocked(mission, {"m3": true}):
		return "desbloqueio da M4 não respeita a conclusão da M3"
	for room in mission.rooms:
		for layer in ["bg", "fg"]:
			var path := "res://assets/rooms/%s/%s.png" % [room.asset_id, layer]
			if not ResourceLoader.exists(path):
				return "camada de sala ausente: " + path
	for path in ["res://assets/enemies/rebelde_ponte.png", "res://assets/portraits/kein.png", "res://assets/portraits/bella.png", "res://assets/items/cadernos_magicos.png", "res://assets/world/props/grade_carroca_prisao.png"]:
		if not ResourceLoader.exists(path):
			return "asset da M4 ausente: " + path
	var dungeon := mission.dungeon
	if dungeon.room_rects.size() != 3 or dungeon.enemy_cells.get(2, []).size() != 2 or dungeon.enemy_cells.get(3, []).size() != 3:
		return "mapa ou grupos rebeldes da M4 incorretos"
	if mission.situations.get(1) == null or mission.situations[1].options.size() != 2:
		return "situação de perseguição não está configurada"
	return ""

func test_bridge_victory_persists_notebooks() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m4")
	run.finish(ProgressRules.VITORIA)
	var state := store.load_state()
	if not state.missions_completed.has("m4") or not state.story_items.has("cadernos_magicos"):
		return "vitória da M4 não persistiu missão e cadernos"
	return ""
