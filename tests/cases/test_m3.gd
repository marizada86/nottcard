extends RefCounted
## Contrato independente da M3: catálogo, mapa, assets e recompensa persistida.

func test_library_contract() -> String:
	var all: Dictionary = Missions.all()
	if not all.has("m3"):
		return "M3 não entrou no catálogo"
	var mission: MissionDef = all["m3"]
	if mission.requires != ["m2"] or mission.rooms.size() != 3:
		return "pré-requisito ou número de salas da M3 incorreto"
	if Missions.is_unlocked(mission, {}) or not Missions.is_unlocked(mission, {"m2": true}):
		return "desbloqueio da M3 não respeita a conclusão da M2"
	for room in mission.rooms:
		for layer in ["bg", "fg"]:
			var path := "res://assets/rooms/%s/%s.png" % [room.asset_id, layer]
			if not ResourceLoader.exists(path):
				return "camada de sala ausente: " + path
	for path in [
		"res://assets/world/props/diario_gargulas.png",
		"res://assets/world/props/recorte_aluris.png",
		"res://assets/world/props/livrinho.png",
		"res://assets/items/ampulheta_silencio_eterno.png",
		"res://assets/enemies/gargula_corrompida.png",
		"res://assets/portraits/aila.png",
	]:
		if not ResourceLoader.exists(path):
			return "asset da M3 ausente: " + path
	var dungeon := mission.dungeon
	if dungeon.room_rects.size() != 3 or dungeon.enemy_cells.get(2, []).size() != 3 or dungeon.enemy_cells.get(3, []).size() != 3:
		return "mapa ou grupos de gárgulas da M3 incorretos"
	if mission.situations.get(1) == null or mission.situations[1].options.size() != 2:
		return "enigma do silêncio não está configurado"
	return ""

func test_library_victory_persists_hourglass() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m3")
	run.finish(ProgressRules.VITORIA)
	var state := store.load_state()
	if not state.missions_completed.has("m3"):
		return "vitória na M3 não foi registrada"
	if not state.story_items.has("ampulheta_silencio_eterno"):
		return "Ampulheta do Silêncio Eterno não foi persistida"
	return ""
