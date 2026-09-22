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

func _ready() -> void:
	size = Vector2(Gfx.W, Gfx.H)
	mouse_filter = Control.MOUSE_FILTER_STOP
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
	Engine.max_fps = fps_cap
	var st := save_store.load_state()
	if Shop.migrate_removed_items(st) or Collection.ensure_collection(st):
		save_store.save(st)
	if save_store.warning != "":
		show_toast(save_store.warning, 8.0)
		save_store.warning = ""
	if shot != "":
		_setup_shot(shot)
	else:
		open_menu()

func _process(dt: float) -> void:
	toast_left = maxf(0.0, toast_left - dt)
	lore_left = maxf(0.0, lore_left - dt)
	if screen != null:
		screen.update(dt)
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
	if screen == null:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var mode := DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
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
	open_menu()

func start_run(characters: Array, mission_id: String) -> void:
	last_party = characters
	last_mission = mission_id
	run = RunSession.new(save_store)
	run.playtester_mode = playtester_mode
	run.start(characters, mission_id)
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
