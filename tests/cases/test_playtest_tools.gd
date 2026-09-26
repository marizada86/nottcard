func test_dev_log_keeps_the_latest_300_lines() -> String:
	var log := DevLog.new()
	for i in range(305):
		log.add("linha %d" % i)
	if log.lines.size() != 300:
		return "buffer do log deveria ter 300 linhas"
	if not String(log.lines[0]).contains("linha 5"):
		return "buffer do log não descartou as linhas antigas"
	return ""

func test_evidence_scrub_hides_windows_user_path() -> String:
	var text := EvidenceStore.scrub("C:\\Users\\ana\\Desktop\\save.json")
	return "caminho pessoal não foi limpo" if text.contains("ana") or text.contains("C:\\Users") else ""

func test_qa_catalog_has_m4_and_existing_hqs() -> String:
	var ids: Dictionary = {}
	for scenario in QaScenarios.all():
		ids[scenario.id] = true
	for expected in ["m4-walk", "m4-combat-2", "m5-astherion-phase-2", "m9-beholder-phase", "m9-death-tyrant-phase", "hq-hq_001", "hq-hq_002", "hq-hq_003"]:
		if not ids.has(expected):
			return "cenário QA ausente: %s" % expected
	return ""

func test_build_config_never_enables_qa_without_playtest() -> String:
	if BuildConfig.qa_tools_enabled() and not BuildConfig.playtest_enabled():
		return "QA não pode existir fora de uma build de playtest"
	return ""

func test_evidence_note_caps_text_at_1000_characters() -> String:
	var source := "x".repeat(EvidenceNotepad.MAX_NOTE_LENGTH + 1)
	var capped := EvidenceNotepad.capped_text(source)
	if capped.length() != EvidenceNotepad.MAX_NOTE_LENGTH:
		return "nota deveria ser limitada a 1.000 caracteres"
	if EvidenceNotepad.capped_text("nota curta") != "nota curta":
		return "nota curta não deveria ser alterada"
	return ""

func test_qa_cheat_unlocks_persistent_progress() -> String:
	var app := GameApp.new()
	var dir := "user://test_nottcard_cheat_%d" % Time.get_ticks_usec()
	app.save_store = SaveStore.new(dir)
	app.dev_log = DevLog.new()
	var state := app.save_store.load_state()
	if not app.save_store.save(state):
		return "não foi possível preparar o save do teste: " + app.save_store.warning
	app._apply_qa_cheat()
	for character_id in ProgressRules.ALL_CHARACTER_IDS:
		var progress := state.for_character(character_id)
		if progress.level != ProgressRules.MAX_LEVEL or progress.xp != ProgressRules.xp_for_level(ProgressRules.MAX_LEVEL):
			return "cheat não elevou %s ao nível máximo" % character_id
		if not state.unlocked_characters.has(character_id):
			return "cheat não liberou %s" % character_id
	for achievement in Achievements.all():
		if not state.achievements.has(achievement.id):
			return "cheat não liberou a conquista %s" % achievement.id
	if state.collection.is_empty():
		return "cheat não atualizou a coleção"
	var reopened := SaveStore.new(dir).load_state()
	if not app.qa_cheat_complete(reopened):
		return "cheat não persistiu completo após reabrir o save"
	if not app.toast.contains("Cheat de playtest aplicado") or app.dev_log.lines.is_empty():
		return "cheat não registrou o resultado para o playtester"
	DirAccess.remove_absolute(dir + "/save.json")
	DirAccess.remove_absolute(dir)
	return ""

func test_fresh_save_never_blocks_the_first_run_with_an_invalid_deck() -> String:
	for seed in range(1, 101):
		var state := SaveStore.fresh()
		Collection.ensure_collection(state, PyRandom.new(seed))
		var deck: Array = state.decks[state.active_deck]
		var problems := Collection.deck_problems(deck)
		if not problems.is_empty():
			return "save novo seed %d criou baralho inválido: %s" % [seed, "; ".join(problems)]
	return ""

func test_durvall_and_kayron_prepare_a_m1_run() -> String:
	var store := SaveStore.new("")
	var state := SaveStore.fresh()
	state.unlocked_characters = Py.set_of(ProgressRules.ALL_CHARACTER_IDS)
	state.missions_completed = {"m1": true}
	store.save(state)
	Collection.ensure_collection(state, PyRandom.new(9))
	for character_id in ["durvall", "kayron"]:
		var allowed := Roster.can_field(Missions.all()["m1"], state, [character_id])
		if not allowed[0]:
			return "%s não passou pela validação da M1: %s" % [character_id, allowed[1]]
		var run := RunSession.new(store)
		run.start([CharacterDefs.get_def(character_id)], "m1")
		if run.mission == null or run.party == null or run.current_room() == null:
			return "%s não preparou a primeira sala da M1" % character_id
	return ""
