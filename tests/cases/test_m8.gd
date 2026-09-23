extends RefCounted
## Contrato da M8-A: Vila das Sombras, pousada-armadilha, igreja e chegada narrativa de Erik.

func test_shadow_village_contract() -> String:
	var all: Dictionary = Missions.all()
	if not all.has("m8"):
		return "M8 não entrou no catálogo"
	var mission: MissionDef = all["m8"]
	if mission.requires != ["m7"] or mission.rooms.size() != 4:
		return "pré-requisito ou número de salas da M8 incorreto"
	if Missions.is_unlocked(mission, {"m6": true}) or not Missions.is_unlocked(mission, {"m7": true}):
		return "desbloqueio da M8 não respeita a conclusão da M7"
	for room in mission.rooms:
		for layer in ["bg", "fg"]:
			var path := "res://assets/rooms/%s/%s.png" % [room.asset_id, layer]
			if not ResourceLoader.exists(path):
				return "camada de sala ausente: " + path
	for path in [
		"res://assets/enemies/demonio_sedutor.png", "res://assets/portraits/erik.png",
		"res://assets/world/props/lanterna_nevoa.png", "res://assets/world/props/mesa_pousada.png", "res://assets/world/props/altar_sombras.png", "res://assets/world/props/relicario_bromnor.png", "res://assets/items/artefatos_bromnor.png",
	]:
		if not ResourceLoader.exists(path):
			return "asset da M8 ausente: " + path
	if mission.dungeon.room_rects.size() != 4 or mission.dungeon.enemy_cells.get(3, []).size() != 1:
		return "mapa ou encontro da Vila das Sombras incorreto"
	if mission.room(3).make_enemies()[0].name != "Demônio Sedutor da Vila":
		return "demônio de chefe não está configurado"
	return ""

func test_church_situation_and_narrative_rewards() -> String:
	var church: Situation = MissionM8.situations()[4]
	if church.options.size() != 2:
		return "a Igreja das Sombras precisa manter duas abordagens"
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m8")
	run.finish(ProgressRules.VITORIA)
	var state := store.load_state()
	for key in ["artefatos_bromnor", "erik_recrutado"]:
		if not state.story_items.has(key):
			return "vitória da M8 não persistiu " + key
	return ""
