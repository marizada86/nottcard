extends RefCounted
## Fumaça de ponta a ponta do core: um bot joga missões inteiras (RunSession + CombatSession) sem erro e o save sai coerente.

func _bot_fight(cs: CombatSession, guard_limit: int = 400) -> void:
	var steps := 0
	while not cs.finished and steps < guard_limit:
		steps += 1
		if cs.reaction_pending != null:
			var idx := -1
			for i in range(cs.player.hand.size()):
				if cs.turn.can_react(cs.player.hand[i], cs.reaction_pending.kind, cs.reaction_pending.hit != null):
					idx = i
					break
			cs.react(idx)
			continue
		if not cs.picking.is_empty():
			cs.pick_from_top(0)
			continue
		if cs.discarding:
			cs.discard_choice(cs.player.hand.size() - 1)
			continue
		var played := false
		for i in range(cs.player.hand.size()):
			var c: Card = cs.player.hand[i]
			if cs.turn.can_play(c):
				var tgt := -1
				var alive := cs.alive_slots()
				if not alive.is_empty():
					tgt = cs.slots.find(alive[0])
				played = cs.play_card(i, tgt)
				if played:
					break
		if not played:
			if cs.turn.actions_available > 0 and cs.player.hand.size() < 5 and steps % 3 == 0:
				cs.action_draw()
			else:
				cs.end_turn()
		cs.fx.clear()

func test_bots_play_full_missions() -> String:
	var cases := [["durvall", "m1"], ["maelor", "m1"], ["sylas", "m1"], ["kayron", "m1"], ["brook", "m2"], ["durvall", "m2"]]
	var i := 0
	for c in cases:
		PyRandom.shared = PyRandom.new(100 + i)
		var store := SaveStore.new("")
		var st := store.load_state()
		st.roster_rules = false
		var run := RunSession.new(store)
		run.rng = PyRandom.new(200 + i)
		run.start([CharacterDefs.get_def(c[0])], c[1])
		if i % 2 == 0:   # metade das lutas com PV de sobra, para o bot chegar ao chefe e vencer
			run.player.hp = 900
			run.player.max_hp = 900
		var outcome := ProgressRules.DESISTENCIA
		var rooms_done := 0
		var guard := 0
		while guard < 30:
			guard += 1
			var room := run.current_room()
			if room.kind == Rooms.COMBATE:
				var cs := CombatSession.new(run, room.make_enemies(), room.is_boss)
				_bot_fight(cs)
				if not cs.finished:
					return "%s %s: o combate da sala %d não terminou" % [c[0], c[1], room.id]
				var kind := run.combat_finished(cs.victory)
				if kind == "defeat":
					outcome = ProgressRules.DERROTA
					break
			var adv := run.advance_room(room.kind == Rooms.COMBATE)
			rooms_done += 1
			if adv == "victory":
				outcome = ProgressRules.VITORIA
				break
			# anda pelo grafo até a próxima sala não resolvida
			var moved := false
			var nb: Array = run.world.neighbors(run.world.current)
			nb.reverse()
			for n in nb:
				if not run.world.is_cleared(n) and run.world.move_to(n):
					run.room_index = run.mission.index_of(n)
					moved = true
					break
			if not moved:
				break
		var res := run.finish(outcome)
		print("  bot %s %s: %s, salas %d, +%d XP, moedas %d, mortes %d" % [c[0], c[1], outcome, rooms_done, res.gained, res.coins, run.stats.enemies_defeated])
		if res == null or res.outcome != outcome:
			return "%s %s: finish devolveu resultado inconsistente" % [c[0], c[1]]
		if outcome == ProgressRules.VITORIA and not st.missions_completed.has(c[1]):
			return "%s %s: vitória sem missão concluída" % [c[0], c[1]]
		if outcome == ProgressRules.VITORIA and (st.pending_offer == null or st.pending_offer.get("source") != "chefe"):
			return "%s %s: vencer o chefe devia deixar a oferta de cartas raras" % [c[0], c[1]]
		if st.for_character(c[0]).xp <= 0 and res.gained > 0:
			return "%s %s: XP não entrou" % [c[0], c[1]]
		# o save serializa e volta
		var again := SaveState.from_dict(GameData.hydrate(st.to_dict()))
		if again == null or again.coins != st.coins:
			return "%s %s: save não fecha o ciclo (%s)" % [c[0], c[1], SaveState.last_error]
		i += 1
	return ""

func test_party_of_three_fights() -> String:
	PyRandom.shared = PyRandom.new(77)
	var store := SaveStore.new("")
	var st := store.load_state()
	st.roster_rules = false
	var run := RunSession.new(store)
	run.rng = PyRandom.new(78)
	run.start([CharacterDefs.get_def("durvall"), CharacterDefs.get_def("maelor"), CharacterDefs.get_def("sylas")], "m1")
	var cs := CombatSession.new(run, Rooms.grupo_do_corredor(), false)
	# cada personagem age: o bot troca de ativo quando o atual acaba
	var steps := 0
	while not cs.finished and steps < 500:
		steps += 1
		if cs.reaction_pending != null:
			cs.react(-1)
			continue
		if cs.discarding:
			cs.discard_choice(0)
			continue
		if not cs.picking.is_empty():
			cs.pick_from_top(0)
			continue
		var played := false
		for i in range(cs.player.hand.size()):
			if cs.turn.can_play(cs.player.hand[i]):
				var alive := cs.alive_slots()
				played = cs.play_card(i, cs.slots.find(alive[0]) if not alive.is_empty() else -1)
				if played:
					break
		if not played:
			cs.end_turn()
		cs.fx.clear()
	return "" if cs.finished else "combate em grupo não terminou"
