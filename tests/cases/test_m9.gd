extends RefCounted
## Contrato da M9-A: raiz, templo, três fases e fim do Ato 1.

func test_confrontation_contract() -> String:
	var all: Dictionary = Missions.all()
	if not all.has("m9"):
		return "M9 não entrou no catálogo"
	var mission: MissionDef = all["m9"]
	if mission.requires != ["m8"] or mission.rooms.size() != 3:
		return "pré-requisito ou número de salas da M9 incorreto"
	if Missions.is_unlocked(mission, {"m7": true}) or not Missions.is_unlocked(mission, {"m8": true}):
		return "desbloqueio da M9 não respeita a conclusão da M8"
	for room in mission.rooms:
		for layer in ["bg", "fg"]:
			var path := "res://assets/rooms/%s/%s.png" % [room.asset_id, layer]
			if not ResourceLoader.exists(path):
				return "camada de sala ausente: " + path
	for path in [
		"res://assets/enemies/kein_fase_1.png", "res://assets/enemies/beholder.png", "res://assets/enemies/death_tyrant.png", "res://assets/items/martelo_da_gloria.png",
		"res://assets/world/props/raiz_abissal.png", "res://assets/world/props/pedestal_veu.png", "res://assets/world/props/fenda_veu.png",
	]:
		if not ResourceLoader.exists(path):
			return "asset da M9 ausente: " + path
	if mission.dungeon.room_rects.size() != 3 or mission.dungeon.enemy_cells.get(3, []).size() != 1:
		return "mapa ou encontro do Confronto com Kein incorreto"
	return ""

func test_three_boss_phases_survive_overkill() -> String:
	var kein := Enemies.kein_altar()
	kein.hp = 0
	var beholder: Enemy = kein.enc_script.replace(kein)
	if beholder == null or beholder.name != "Beholder da Raiz":
		return "Kein não alcançou a fase Beholder após dano excedente"
	beholder.hp = 0
	var tyrant: Enemy = beholder.enc_script.replace(beholder)
	if tyrant == null or tyrant.name != "Death Tyrant do Véu":
		return "Beholder não alcançou a fase Death Tyrant após dano excedente"
	if tyrant.enc_script != null:
		return "Death Tyrant não deve ter quarta fase"
	return ""

func test_final_victory_persists_act_one_outcome() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m9")
	run.finish(ProgressRules.VITORIA)
	var state := store.load_state()
	for key in ["martelo_da_gloria", "tarn_caida", "sacrificio_helion", "veu_nascido"]:
		if not state.story_items.has(key):
			return "vitória da M9 não persistiu " + key
	return ""
