extends RefCounted
## Contrato da M5: sequência, assets, transição única de fase e recompensas persistidas.

func test_sanctuary_contract() -> String:
	var all: Dictionary = Missions.all()
	if not all.has("m5"):
		return "M5 não entrou no catálogo"
	var mission: MissionDef = all["m5"]
	if mission.requires != ["m4"] or mission.rooms.size() != 3:
		return "pré-requisito ou número de salas da M5 incorreto"
	if Missions.is_unlocked(mission, {"m3": true}) or not Missions.is_unlocked(mission, {"m4": true}):
		return "desbloqueio da M5 não respeita a conclusão da M4"
	for room in mission.rooms:
		for layer in ["bg", "fg"]:
			var path := "res://assets/rooms/%s/%s.png" % [room.asset_id, layer]
			if not ResourceLoader.exists(path):
				return "camada de sala ausente: " + path
	for path in [
		"res://assets/enemies/notivago.png",
		"res://assets/enemies/astherion_fase_1.png",
		"res://assets/enemies/astherion_fase_2.png",
		"res://assets/items/colar_visao_verdadeira.png",
		"res://assets/world/props/lapide_fraturada.png",
		"res://assets/world/props/bacia_nevoa.png",
		"res://assets/world/props/circulo_fogo_azul.png",
	]:
		if not ResourceLoader.exists(path):
			return "asset da M5 ausente: " + path
	var dungeon := mission.dungeon
	if dungeon.room_rects.size() != 3 or dungeon.enemy_cells.get(2, []).size() != 2 or dungeon.enemy_cells.get(3, []).size() != 1:
		return "mapa ou encontros da M5 incorretos"
	if mission.situations.get(1) == null or mission.situations[1].options.size() != 2:
		return "situação do cemitério não está configurada"
	return ""

func test_astherion_replaces_same_slot_once() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m5")
	var phase_one := Enemies.astherion_fase_1()
	var cs := CombatSession.new(run, [phase_one], true)
	phase_one.hp = phase_one.max_hp / 2
	cs._check_scripts()
	if cs.slots.size() != 1:
		return "mudança de fase alterou a quantidade de slots"
	var phase_two: Enemy = cs.slots[0].enemy
	if phase_two.name != "Astherion — névoa absorvida" or phase_two.slug != "astherion_fase_2":
		return "a fase 2 não substituiu Astherion no mesmo slot"
	cs._check_scripts()
	if cs.slots[0].enemy != phase_two:
		return "a transição de fase disparou mais de uma vez"
	return ""

func test_sanctuary_victory_persists_rewards() -> String:
	var store := SaveStore.new("")
	var run := RunSession.new(store)
	run.start([CharacterDefs.get_def("durvall")], "m5")
	run.finish(ProgressRules.VITORIA)
	var state := store.load_state()
	if not state.missions_completed.has("m5") or not state.story_items.has("colar_visao_verdadeira") or not state.story_items.has("tarn_dagruve_selada"):
		return "vitória da M5 não persistiu missão, colar e selo da Tarn"
	return ""
