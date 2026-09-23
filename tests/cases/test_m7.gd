extends RefCounted
## Contrato da M7-A: ferraria, puzzle estreito, mímico e recrutamento narrativo.

func test_forge_contract() -> String:
	var all: Dictionary = Missions.all()
	if not all.has("m7"):
		return "M7 não entrou no catálogo"
	var mission: MissionDef = all["m7"]
	if mission.requires != ["m6"] or mission.rooms.size() != 4:
		return "pré-requisito ou número de salas da M7 incorreto"
	if Missions.is_unlocked(mission, {"m5": true}) or not Missions.is_unlocked(mission, {"m6": true}):
		return "desbloqueio da M7 não respeita a conclusão da M6"
	for room in mission.rooms:
		for layer in ["bg", "fg"]:
			var path := "res://assets/rooms/%s/%s.png" % [room.asset_id, layer]
			if not ResourceLoader.exists(path):
				return "camada de sala ausente: " + path
	for path in [
		"res://assets/enemies/mimico.png", "res://assets/portraits/korrak.png", "res://assets/portraits/leoric.png",
		"res://assets/world/props/bigorna_ferraria.png", "res://assets/world/props/braseiro_apagado.png", "res://assets/world/props/portal_gemeo.png", "res://assets/world/props/diario_bromnor.png", "res://assets/items/diario_bromnor.png",
	]:
		if not ResourceLoader.exists(path):
			return "asset da M7 ausente: " + path
	var dungeon := mission.dungeon
	if dungeon.room_rects.size() != 4 or dungeon.enemy_cells.get(4, []).size() != 1:
		return "mapa ou encontro do Espeto incorreto"
	if mission.room(4).make_enemies()[0].name != "Mímico do Espeto":
		return "mímico de chefe não está configurado"
	return ""

func test_portal_failure_remains_in_same_situation() -> String:
	var portal: Situation = MissionM7.situations()[3]
	if portal.options.size() != 2 or not portal.options[1].success.remain:
		return "portal âmbar não mantém o grupo na situação para nova tentativa"
	if portal.options[0].success.remain:
		return "portal azul não deveria repetir a sala"
	return ""

func test_forge_victory_persists_narrative_rewards() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m7")
	run.finish(ProgressRules.VITORIA)
	var state := store.load_state()
	for key in ["diario_bromnor", "korrak_recrutado", "leoric_recrutado"]:
		if not state.story_items.has(key):
			return "vitória da M7 não persistiu " + key
	return ""
