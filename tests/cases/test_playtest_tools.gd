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
