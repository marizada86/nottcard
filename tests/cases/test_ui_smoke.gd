extends RefCounted
## Fumaça da interface: um bot dirige as telas reais (GameApp) por uma missão inteira, com eventos de entrada sintéticos, e chega ao resultado.

func _click(screen: UiScreen, pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = pos
	screen.handle_input(ev)

func _drive_combat(cs_screen: CombatScreen) -> void:
	var cs := cs_screen.cs
	var guard := 0
	while not cs.finished and guard < 600:
		guard += 1
		if cs.reaction_pending != null:
			cs_screen._click_card(-1)
			cs.react(-1)
		elif cs.discarding:
			cs_screen._click_card(cs.player.hand.size() - 1)
		elif cs.picking.size() > 0:
			cs.pick_from_top(0)
		else:
			var played := false
			for i in range(cs.player.hand.size()):
				if cs.turn.can_play(cs.player.hand[i]):
					cs_screen._click_card(i)
					if cs_screen.selected >= 0:
						cs_screen._click_card(i)
						cs_screen._click_card(i)
					played = true
					break
			if not played:
				cs.end_turn()
		cs_screen._consume_fx()
		cs_screen.update(0.05)

func _drive_mission(mission_id: String) -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var app := GameApp.new()
	app.size = Vector2(Gfx.W, Gfx.H)
	# sem _ready (que lê argumentos e disco): monta o estado à mão, com save só em memória
	app.save_store = SaveStore.new("")
	app.profile = ProfileStore.new("")
	var st := app.save_store.load_state()
	st.roster_rules = false
	Collection.ensure_collection(st, PyRandom.new(5))
	tree.root.add_child(app)
	PyRandom.shared = PyRandom.new(31)
	app.start_run([CharacterDefs.get_def("durvall")], mission_id)
	app.run.player.hp = 900
	app.run.player.max_hp = 900
	var seen := {}
	var steps := 0
	while steps < 4000 and not (app.screen is ResultScreen):
		steps += 1
		var s: UiScreen = app.screen
		seen[s.get_class() if false else s.get_script().get_global_name()] = true
		if s is WalkScreen:
			var ws := s as WalkScreen
			# passa sempre para o combate/situação da sala: teleporta para perto da âncora da sala atual não resolvida
			var run := app.run
			var target_room := run.world.current
			if run.world.is_cleared(target_room):
				var nb: Array = run.world.neighbors(target_room)
				nb.reverse()
				for n in nb:
					if not run.world.is_cleared(n):
						run.world.move_to(n)
						run.room_index = run.mission.index_of(n)
						target_room = n
						break
			var a: Vector2i = run.mission.dungeon.anchors[target_room]
			ws.walker.x = a.x
			ws.walker.y = a.y
			ws.command("turn_left")
			ws.command("turn_right")
			for _i in range(30):
				ws.update(0.05)
				if app.screen != s:
					break
			if app.screen == s:
				ws._open_room_encounter()
		elif s is SituationScreen:
			var ss := s as SituationScreen
			if ss.chosen == null:
				ss.choose(ss.option_buttons[0]["option"])
			ss.update(2.0)
			if ss.luck_pending:
				ss.accept_result()
			if ss.reward_pending:
				ss.take_reward(true)
			if ss.applied != null and ss.resolved and not ss.reward_pending and not ss.luck_pending:
				ss._continue()
		elif s is CombatScreen:
			_drive_combat(s as CombatScreen)
			s.update(2.0)
			s.update(2.0)
		elif s is OfferScreen:
			var os := s as OfferScreen
			if os.cards.size() > 0:
				os._pick(0)
			else:
				return "oferta sem cartas"
		else:
			return "tela inesperada: %s" % s.get_script().get_global_name()
	app.queue_free()
	if not (app.screen is ResultScreen):
		return "%s: o bot não chegou ao resultado em %d passos (telas: %s)" % [mission_id, steps, str(seen.keys())]
	var need := ["WalkScreen", "CombatScreen"]
	for n in need:
		if not seen.has(n):
			return "%s: tela não visitada: %s" % [mission_id, n]
	return ""

func test_bot_drives_the_real_screens() -> String:
	return _drive_mission("m1")

func test_bot_drives_m3_screens() -> String:
	return _drive_mission("m3")

func test_bot_drives_m4_screens() -> String:
	return _drive_mission("m4")

func test_bot_drives_m5_screens() -> String:
	return _drive_mission("m5")

func test_bot_drives_m6_screens() -> String:
	return _drive_mission("m6")

func test_bot_drives_m7_screens() -> String:
	return _drive_mission("m7")

func test_bot_drives_m8_screens() -> String:
	return _drive_mission("m8")

func test_bot_drives_m9_screens() -> String:
	return _drive_mission("m9")
