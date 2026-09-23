class_name GameApp
extends Control
## O App (game/app.py::App): estado global, troca de telas, opções, save, aviso (toast). A tentativa em andamento é o `run` (RunSession).

const VERSION := "0.18.0"
const VERSION_DATE := "21/09/2026"
const VERSION_LABEL := "v0.18.0 · 21/09/2026"

var save_store: SaveStore
var profile: ProfileStore
var run: RunSession = null
var screen: UiScreen = null
var toast: String = ""
var toast_left: float = 0.0
var lore: String = ""
var lore_left: float = 0.0
var reduce_motion: bool = false
var fps_cap: int = 60
var torch_flicker: bool = true
var walk_bob: bool = true
var playtester_mode: bool = false
var card_layout: String = "classico"
var last_party: Array = []
var last_mission: String = "m1"
var _shot_path: String = ""
var _shot_frames: int = 0
var evidence_store: EvidenceStore = null
var dev_log: DevLog = DevLog.new()
var notepad: EvidenceNotepad = null
var dev_console: DevConsole = null
var qa_navigator: QaNavigator = null
var playtest_guide: PlaytestGuide = null
var qa_active: bool = false
var qa_scenario_id: String = ""
var _normal_save_store: SaveStore = null
var _qa_badge: Control = null
var _combat_log_count: int = 0
var _opening_notepad: bool = false

func _ready() -> void:
	size = Vector2(Gfx.W, Gfx.H)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_ensure_input_actions()
	var args := OS.get_cmdline_user_args()
	var shot := ""
	var test_dir := ""
	for a in args:
		if a.begins_with("--shot="): shot = a.substr(7)
		elif a.begins_with("--out="): _shot_path = a.substr(6)
		elif a.begins_with("--savedir="): test_dir = a.substr(10)
	save_store = SaveStore.new(test_dir if test_dir != "" else SaveStore.DEFAULT_DIR)
	profile = ProfileStore.new(test_dir if test_dir != "" else SaveStore.DEFAULT_DIR)
	reduce_motion = profile.reduce_motion
	fps_cap = profile.fps_cap
	torch_flicker = profile.torch_flicker
	walk_bob = profile.walk_bob
	playtester_mode = profile.playtester
	if BuildConfig.playtest_enabled():
		evidence_store = EvidenceStore.new()
	Engine.max_fps = fps_cap
	var st := save_store.load_state()
	if Shop.migrate_removed_items(st) or Collection.ensure_collection(st):
		save_store.save(st)
	if save_store.warning != "":
		show_toast(save_store.warning, 8.0)
		save_store.warning = ""
	if evidence_store != null:
		if evidence_store.warning != "":
			show_toast(evidence_store.warning, 6.0)
		elif not evidence_store.items.is_empty():
			show_toast("Você tem %d item(ns) guardado(s). F7 gera o ZIP." % evidence_store.items.size(), 6.0)
	if shot != "":
		_setup_shot(shot)
	else:
		open_menu()
		if BuildConfig.playtest_enabled() and profile.name != "" and not profile.welcome_seen:
			call_deferred("show_playtest_guide", true)

func _process(dt: float) -> void:
	toast_left = maxf(0.0, toast_left - dt)
	lore_left = maxf(0.0, lore_left - dt)
	if screen != null and notepad == null:
		screen.update(dt)
	_collect_combat_log()
	queue_redraw()
	if _shot_path != "":
		_shot_frames += 1
		if _shot_frames == 6:
			var img := get_viewport().get_texture().get_image()
			img.save_png(_shot_path)
			get_tree().quit()

func _draw() -> void:
	if screen != null:
		screen.draw(self)
	if lore_left > 0.0 and lore != "":
		var lines := Gfx.wrap_lines(lore, 22, 900)
		var h := lines.size() * 28 + 20
		Gfx.scrim(self, Rect2(190, 20, 900, h), 190)
		var y := 30.0
		for ln in lines:
			Gfx.text(self, ln, Vector2(640, y), 22, UiTheme.TEXT_COLOR, "midtop")
			y += 28
	if toast_left > 0.0 and toast != "":
		var lines2 := Gfx.wrap_lines(toast, 22, 960)
		var h2 := lines2.size() * 28 + 20
		var top := Gfx.H - 110.0 - h2
		Gfx.scrim(self, Rect2(160, top, 960, h2), 210)
		var y2 := top + 10
		for ln in lines2:
			Gfx.text(self, ln, Vector2(640, y2), 22, UiTheme.SELECTED_BORDER, "midtop")
			y2 += 28

func _input(event: InputEvent) -> void:
	if playtest_guide != null:
		if playtest_guide.handle_input(event):
			playtest_guide = null
			return
	if notepad != null:
		if event.is_action_pressed("evidence_note"):
			_close_notepad()
		elif event.is_action_pressed("evidence_screenshot"):
			show_toast("Feche o bloco de notas (F5) antes de tirar um print.", 3.0)
		elif event.is_action_pressed("evidence_export"):
			_close_notepad()
			_export_evidence()
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_close_notepad()
		elif notepad.handle_input(event):
			return
		return
	if qa_navigator != null:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			qa_navigator.queue_free()
			qa_navigator = null
			return
		if qa_navigator.handle_input(event):
			return
	if dev_console != null and dev_console.handle_input(event):
		return
	if BuildConfig.playtest_enabled() and event.is_action_pressed("evidence_note"):
		_open_notepad()
		return
	if BuildConfig.playtest_enabled() and event.is_action_pressed("evidence_screenshot"):
		_capture_print()
		return
	if BuildConfig.playtest_enabled() and event.is_action_pressed("evidence_export"):
		_export_evidence()
		return
	if BuildConfig.playtest_enabled() and event.is_action_pressed("dev_console"):
		_toggle_dev_console()
		return
	if BuildConfig.playtest_enabled() and event.is_action_pressed("playtest_guide"):
		show_playtest_guide(false)
		return
	if BuildConfig.qa_tools_enabled() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P and event.ctrl_pressed and Input.is_key_pressed(KEY_O):
		open_qa_navigator()
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var mode := DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if screen != null:
		screen.handle_input(event)

func show_toast(text: String, seconds: float = 4.0) -> void:
	toast = text
	toast_left = seconds

func show_lore(text: String, seconds: float = 9.0) -> void:
	lore = text
	lore_left = seconds if text != "" else 0.0

func set_screen(s: UiScreen) -> void:
	if screen != null:
		screen.exit()
	screen = s
	s.app = self
	s.enter()
	if qa_active:
		_ensure_qa_badge()

var save_state: SaveState:
	get:
		return save_store.load_state()

# -- navegação ----------------------------------------------------------------------------------------------

func open_menu() -> void:
	set_screen(MenuScreen.new())

func open_character_select(mission_id: String = "") -> void:
	_refresh_group_achievements()
	var st := save_state
	if Roster.needs_starter(st):
		set_screen(CharacterSelectScreen.new(null, true))
		return
	var unlocked: Array = []
	for m in Missions.all().values():
		if Missions.is_unlocked(m, st.missions_completed):
			unlocked.append(m)
	if mission_id == "" and unlocked.size() > 1:
		set_screen(MissionSelectScreen.new())
		return
	var mission: MissionDef = Missions.all()[mission_id] if mission_id != "" else unlocked[0]
	set_screen(CharacterSelectScreen.new(mission, false))

func choose_starter(character_id: String) -> void:
	if Roster.choose_starter(save_state, character_id):
		_refresh_group_achievements()
		save_store.save(save_state)
	open_character_select()

func _refresh_group_achievements() -> void:
	var st := save_state
	if not st.roster_rules:
		return
	var earned: Array = []
	for a in Achievements.evaluate(st, "", RunStats.new()):
		if a.id in ["dupla", "trio", "veterano_durvall"]:
			earned.append(a)
	if not earned.is_empty():
		for a in earned:
			st.achievements[a.id] = true
		Achievements.grant_cards(st, earned)
		save_store.save(st)

func return_to_menu() -> void:
	if qa_active:
		_end_qa_session()
	open_menu()

func start_run(characters: Array, mission_id: String, seed: int = 0) -> void:
	last_party = characters
	last_mission = mission_id
	run = RunSession.new(save_store)
	if seed != 0:
		run.rng = PyRandom.new(seed)
	run.playtester_mode = playtester_mode
	run.start(characters, mission_id)
	dev_log.add("Tentativa iniciada: %s" % mission_id.to_upper())
	enter_room()

## Entra na sala atual: combate abre a luta; senão a caminhada (as salas de situação abrem por proximidade).
func enter_room() -> void:
	var room := run.current_room()
	show_lore(run.mission.room_intro(room.id))
	open_walk()

func open_walk() -> void:
	set_screen(WalkScreen.new())

func start_combat(enemies: Array, is_boss: bool, backdrop: String, on_win: Callable = Callable()) -> void:
	lore_left = 0.0
	set_screen(CombatScreen.new(enemies, is_boss, backdrop, on_win))
	dev_log.add("Combate iniciado%s." % (" (chefe)" if is_boss else ""))

func combat_finished(victory: bool, on_win: Callable) -> void:
	var kind := run.combat_finished(victory, on_win.is_valid())
	if kind == "defeat":
		finish_run(ProgressRules.DERROTA)
	elif kind == "event_win":
		on_win.call()
	else:
		advance_room(true)

func advance_room(after_combat: bool) -> void:
	var r := run.advance_room(after_combat)
	if r == "victory":
		finish_run(ProgressRules.VITORIA)
	elif r.begins_with("scroll:"):
		run.offer_scroll(int(r.split(":")[1]))
		open_offer(open_walk)
	else:
		open_walk()

func finish_run(outcome: String) -> void:
	var res := run.finish(outcome)
	open_offer(func(): open_offer(func(): set_screen(ResultScreen.new(res, outcome == ProgressRules.VITORIA))))
	dev_log.add("Tentativa encerrada: %s." % outcome)

# -- playtest, evidência e QA -------------------------------------------------------------------------------

func _ensure_input_actions() -> void:
	_add_input_action("evidence_note", KEY_F5)
	_add_input_action("evidence_screenshot", KEY_F6)
	_add_input_action("evidence_export", KEY_F7)
	_add_input_action("dev_console", KEY_F12)
	_add_input_action("playtest_guide", KEY_F1)

func _add_input_action(action: String, keycode: int) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action, event)

func _open_notepad() -> void:
	if _opening_notepad:
		return
	_opening_notepad = true
	_capture_clean(func(png: PackedByteArray):
		_opening_notepad = false
		if png.is_empty():
			show_toast("Não foi possível capturar a tela para a nota.", 4.0)
			return
		if screen != null:
			screen.pause()
		notepad = EvidenceNotepad.new()
		add_child(notepad)
		notepad.open_for(self, png)
		dev_log.add("Bloco de notas aberto."))

func _close_notepad() -> void:
	if notepad == null:
		return
	var panel := notepad
	notepad = null
	panel.close_and_store()

func _capture_print() -> void:
	_capture_clean(func(png: PackedByteArray):
		var result := evidence_store.add_print(png, evidence_context())
		if result.ok:
			show_toast("Print %d guardado — F7 gera o ZIP." % evidence_store.prints_count(), 3.0)
			if result.near_limit:
				show_toast("Pacote quase cheio: gere o ZIP com F7.", 4.0)
			dev_log.add("Print de evidência guardado.")
		else:
			show_toast(result.error, 4.0))

func _capture_clean(done: Callable) -> void:
	var console_visible := dev_console != null and dev_console.visible
	var qa_visible := qa_navigator != null and qa_navigator.visible
	var previous_toast_left := toast_left
	toast_left = 0.0
	if console_visible:
		dev_console.hide()
	if qa_visible:
		qa_navigator.hide()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var png := image.save_png_to_buffer()
	if console_visible and dev_console != null:
		dev_console.show()
	if qa_visible and qa_navigator != null:
		qa_navigator.show()
	toast_left = previous_toast_left
	done.call(png)

func _export_evidence() -> void:
	if evidence_store == null:
		return
	var result := evidence_store.export_bundle(profile.name, VERSION, evidence_state(), dev_log.export_text())
	if result.ok:
		show_toast("Evidência salva: %s" % result.path, 7.0)
		dev_log.add("Pacote de evidências exportado: %s" % result.filename)
	else:
		show_toast(result.error, 5.0)

func evidence_context() -> Dictionary:
	var context := {"screen": screen.get_script().resource_path.get_file().get_basename() if screen != null else "inicial", "qa_scenario": qa_scenario_id}
	if run != null and run.mission != null:
		context["mission"] = run.mission.id
		context["room"] = run.current_room().id
		var party: Array = []
		for member in run.party.members:
			party.append(member.character.id)
		context["party"] = party
	if screen is CombatScreen:
		context["turn"] = screen.cs.turn_number
	return context

func evidence_state() -> Dictionary:
	var data := {"save": save_state.to_dict(), "context": evidence_context()}
	if run != null and run.mission != null:
		data["run"] = {"mission": run.mission.id, "room": run.current_room().id, "room_index": run.room_index, "seconds": run.stats.seconds}
	return data

func _toggle_dev_console() -> void:
	if dev_console != null:
		dev_console.queue_free()
		dev_console = null
		dev_log.visible = false
		return
	dev_console = DevConsole.new()
	add_child(dev_console)
	dev_console.open_for(self, dev_log)
	dev_log.visible = true
	dev_log.add("Console de desenvolvimento aberto.")

func show_playtest_guide(mark_seen: bool = false) -> void:
	if not BuildConfig.playtest_enabled() or playtest_guide != null:
		return
	playtest_guide = PlaytestGuide.new()
	add_child(playtest_guide)
	playtest_guide.open_for(self, mark_seen)

func _collect_combat_log() -> void:
	if not (screen is CombatScreen):
		_combat_log_count = 0
		return
	var messages: Array = screen.cs.messages
	if messages.size() < _combat_log_count:
		_combat_log_count = 0
	for i in range(_combat_log_count, messages.size()):
		dev_log.add(messages[i])
	_combat_log_count = messages.size()

func open_qa_navigator() -> void:
	if not BuildConfig.qa_tools_enabled():
		return
	if qa_navigator != null:
		return
	qa_navigator = QaNavigator.new()
	add_child(qa_navigator)
	qa_navigator.open_for(self)
	dev_log.add("Navegador QA aberto.")

func start_qa_scenario(scenario: QaScenario, party_ids: Array, seed: int) -> void:
	if not BuildConfig.qa_tools_enabled():
		return
	if scenario.kind == "menu":
		return_to_menu()
		return
	qa_navigator = null
	_begin_qa_session()
	qa_scenario_id = scenario.id
	dev_log.add("Cenário QA iniciado: %s (seed %d)." % [scenario.id, seed])
	if scenario.kind == "hq":
		open_hq(scenario.hq_id)
		return
	var characters: Array = []
	for party_id in party_ids:
		characters.append(CharacterDefs.get_def(party_id))
	start_run(characters, scenario.mission_id, seed)
	if scenario.kind == "combat" or scenario.kind == "situation":
		run.room_index = run.mission.index_of(scenario.room_id)
		run.world.current = scenario.room_id
		run.world.visited = {scenario.room_id: true}
		var room := run.current_room()
		if scenario.kind == "combat":
			var enemies := [scenario.enemy_factory.call()] if scenario.enemy_factory.is_valid() else room.make_enemies()
			start_combat(enemies, room.is_boss, room.asset_id)
		else:
			set_screen(SituationScreen.new(run.mission.situations[room.id], Callable()))

func open_hq(hq_id: String) -> void:
	var raw: Variant = HqData.all().get(hq_id)
	if raw == null:
		show_toast("HQ indisponível: %s" % hq_id, 4.0)
		return
	set_screen(HqScreen.new(raw))

func _begin_qa_session() -> void:
	if qa_active:
		return
	_normal_save_store = save_store
	save_store = SaveStore.new("")
	var state := save_store.load_state()
	state.roster_rules = false
	state.unlocked_characters = Py.set_of(ProgressRules.ALL_CHARACTER_IDS)
	state.missions_completed = Py.set_of(Missions.all().keys())
	for cid in ProgressRules.ALL_CHARACTER_IDS:
		var progress := state.for_character(cid)
		progress.level = ProgressRules.MAX_LEVEL
		progress.xp = ProgressRules.xp_for_level(ProgressRules.MAX_LEVEL)
	Collection.ensure_collection(state)
	save_store.save(state)
	qa_active = true

func _end_qa_session() -> void:
	if screen != null:
		screen.exit()
	run = null
	qa_active = false
	qa_scenario_id = ""
	if _normal_save_store != null:
		save_store = _normal_save_store
		_normal_save_store = null
	if _qa_badge != null:
		_qa_badge.queue_free()
		_qa_badge = null
	dev_log.add("Sessão QA encerrada; save normal restaurado.")

func _ensure_qa_badge() -> void:
	if _qa_badge == null:
		_qa_badge = Control.new()
		_qa_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_qa_badge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_qa_badge.draw.connect(func():
			Gfx.scrim(_qa_badge, Rect2(Gfx.W - 260, Gfx.H - 42, 248, 30), 210)
			Gfx.text(_qa_badge, "CENÁRIO DE TESTE · " + qa_scenario_id, Vector2(Gfx.W - 18, Gfx.H - 26), 15, UiTheme.SELECTED_BORDER, "bottomright"))
		add_child(_qa_badge)
	move_child(_qa_badge, -1)
	_qa_badge.queue_redraw()

## A oferta "escolha 1" pendente no save (carta rara do chefe ou pergaminho); segue para `then` quando não há (mais) oferta.
func open_offer(then: Callable) -> void:
	var st := save_state
	var offer: Variant = st.pending_offer
	if offer == null or offer.is_empty():
		then.call()
		return
	set_screen(OfferScreen.new(then))

# -- capturas de tela (verificação visual) -------------------------------------------------------------------

func _setup_shot(name: String) -> void:
	var st := save_state
	match name:
		"menu":
			open_menu()
		"select_starter":
			st.roster_rules = true
			st.unlocked_characters = {}
			open_character_select()
		"select":
			st.roster_rules = true
			st.unlocked_characters = Py.set_of(["durvall"])
			open_character_select("m1")
		"mission":
			st.missions_completed["m1"] = true
			st.roster_rules = true
			st.unlocked_characters = Py.set_of(["durvall", "maelor"])
			open_character_select()
		"walk", "walk2", "combat", "combat_group", "situation", "result", "offer":
			st.roster_rules = false
			Collection.ensure_collection(st)
			var mid := "m2" if name == "walk2" else "m1"
			start_run([CharacterDefs.get_def("durvall")], mid)
			if name == "walk2":
				run.walker.x = 12
				run.walker.y = 12
			if name == "combat":
				var room: Room = run.mission.room(2)
				run.room_index = run.mission.index_of(2)
				start_combat(room.make_enemies(), false, room.asset_id)
			elif name == "combat_group":
				run.room_index = run.mission.index_of(6)
				start_combat(Rooms.grupo_do_corredor(), false, "sala_5b_porao_corredor")
			elif name == "situation":
				run.room_index = run.mission.index_of(3)
				set_screen(SituationScreen.new(run.mission.situations[3], Callable()))
			elif name == "result":
				run.stats.enemies_defeated = 3
				run.ledger.add("Criatura corrompida pela névoa", 10)
				set_screen(ResultScreen.new(run.finish(ProgressRules.VITORIA), true))
			elif name == "offer":
				Collection.offer_boss_reward(st, PyRandom.new(1), "guardiao_verdadeiro")
				open_offer(open_menu)
		_:
			open_menu()
