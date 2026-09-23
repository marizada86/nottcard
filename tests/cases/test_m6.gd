extends RefCounted
## Contrato da M6: Docas, seis alvos independentes, névoa autoferente e recompensas persistidas.

func test_docks_contract() -> String:
	var all: Dictionary = Missions.all()
	if not all.has("m6"):
		return "M6 não entrou no catálogo"
	var mission: MissionDef = all["m6"]
	if mission.requires != ["m5"] or mission.rooms.size() != 3:
		return "pré-requisito ou número de salas da M6 incorreto"
	if Missions.is_unlocked(mission, {"m4": true}) or not Missions.is_unlocked(mission, {"m5": true}):
		return "desbloqueio da M6 não respeita a conclusão da M5"
	for room in mission.rooms:
		for layer in ["bg", "fg"]:
			var path := "res://assets/rooms/%s/%s.png" % [room.asset_id, layer]
			if not ResourceLoader.exists(path):
				return "camada de sala ausente: " + path
	for path in [
		"res://assets/enemies/willie_amalgame.png", "res://assets/enemies/tentaculo_willie.png",
		"res://assets/world/props/rede_apodrecida.png", "res://assets/world/props/oleo_willie.png", "res://assets/world/props/pocao_sopro_de_fogo.png",
		"res://assets/items/oleo_willie.png", "res://assets/items/pocao_sopro_de_fogo.png",
	]:
		if not ResourceLoader.exists(path):
			return "asset da M6 ausente: " + path
	var dungeon := mission.dungeon
	if dungeon.room_rects.size() != 3 or dungeon.enemy_cells.get(3, []).size() != 6:
		return "mapa ou encontro do Amálgama incorreto"
	var group: Array = mission.room(3).make_enemies()
	var tentacles := 0
	for enemy: Enemy in group:
		if enemy.slug == "tentaculo_willie": tentacles += 1
	if group.size() != 6 or group[0].slug != "willie_amalgame" or tentacles != Enemies.WILLIE_TENTACLES:
		return "Willie e os cinco tentáculos não ocupam seis slots independentes"
	return ""

func test_willie_aura_hurts_him_once() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m6")
	var willie := Enemies.willie_amalgame()
	willie.turns_taken = 1
	var cs := CombatSession.new(run, [willie], true)
	var before := willie.hp
	if not cs._prepare_enemy_attack(cs.slots[0]):
		return "Willie não preparou a aura especial"
	if willie.hp != before - willie.special_self_damage:
		return "a aura não feriu Willie uma vez ao preparar o especial"
	return ""

func test_docks_victory_persists_rewards() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m6")
	run.finish(ProgressRules.VITORIA)
	var state := store.load_state()
	if not state.missions_completed.has("m6") or not state.story_items.has("oleo_willie") or not state.story_items.has("pocao_sopro_de_fogo"):
		return "vitória da M6 não persistiu missão, óleo e poção"
	return ""
