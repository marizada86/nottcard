extends RefCounted
## Paridade: coleção, loja, conquistas, layouts, elenco e grupo.

func _names(cards: Array) -> Array:
	var out: Array = []
	for c in cards: out.append(c.name)
	return out

func _dump(st: SaveState) -> Variant:
	return Golden.plain(st.to_dict())

func _coll() -> Array:
	return Collection.CORE_DECK + ["Golpe", "Aparar", "Aparar", "Aparar", "Aparar", "Chama Menor", "Névoa Fria", "Surto de Ação", "Golpe Furtivo", "Nada", "Golpe Perfurante"]

func test_collection() -> String:
	var g = Golden.load_json("collection")
	var pools := {}
	for r in ["comum", "incomum", "rara"]:
		pools[r] = _names(Collection.pool(r))
	var d := Golden.diff([pools, Collection.card_catalog().keys()], [g.pools, g.catalog], "pools")
	if d != "": return d
	for s in g.starting:
		var sd := int(s.seed)
		var got := {"deck": _names(Collection.starting_deck(PyRandom.new(sd))), "extras": _names(Collection.starting_extras(PyRandom.new(sd))),
			"boss": _names(Collection.boss_offer("guardiao_verdadeiro", PyRandom.new(sd))), "boss2": _names(Collection.boss_offer("sacerdote_mente_derretida", PyRandom.new(sd), 2)),
			"boss3": _names(Collection.boss_offer("nada", PyRandom.new(sd)))}
		d = Golden.diff(got, {"deck": s.deck, "extras": s.extras, "boss": s.boss, "boss2": s.boss2, "boss3": s.boss3}, "sorteio seed %d" % sd)
		if d != "": return d
	var coll := _coll()
	var sig := {}
	for cid in CharacterDefs.all():
		var c: CharacterDef = CharacterDefs.get_def(cid)
		sig[cid] = [_names(Collection.signature_cards(c, 1)), _names(Collection.signature_cards(c, 3)), _names(Collection.signature_cards(c, 5)), _names(Collection.run_deck(c, coll, 4))]
	d = Golden.diff(sig, g.sig, "signature")
	if d != "": return d
	var probs: Array = []
	for dk in [[], Collection.CORE_DECK, coll, ["Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe Furtivo", "Golpe Furtivo"],
			["Poção de Cura", "Poção de Cura", "Poção de Cura", "Chama Menor", "Chama Menor", "Chama Menor", "Chama Menor"]]:
		probs.append(Collection.deck_problems(dk))
	d = Golden.diff(probs, g.problems, "problems")
	if d != "": return d
	var big: Array = coll + coll + coll
	d = Golden.diff([Collection.default_deck(coll), Collection.default_deck(Collection.CORE_DECK), Collection.default_deck(big)], g["default"], "default_deck")
	if d != "": return d
	d = Golden.diff(Collection.sorted_by_rarity(coll), g["sorted"], "sorted")
	if d != "": return d
	var sg: Array = []
	for color in ["Vermelho", "Amarelo", "Azul", "Roxo"]:
		sg.append(Collection.suggest_deck(coll, Collection.CORE_DECK, color))
	d = Golden.diff(sg, g.suggest, "suggest")
	if d != "": return d
	d = Golden.diff(Collection.migrated_collection(), g.migrated, "migrated")
	if d != "": return d
	var dk := Deck.new(Collection.CORE_DECK.duplicate())
	var dl: Array = [dk.full, dk.locked("Golpe"), dk.locked("Aparar"), dk.add("Aparar", coll), dk.add("Aparar", coll), dk.add("Golpe", coll), dk.remove("Golpe"), dk.remove("Aparar"),
		dk.remove("Nada"), dk.swap("Aparar", "Névoa Fria", coll), dk.swap("Golpe", "Aparar", coll), dk.swap("Chama Menor", "Nada", coll), dk.names, dk.size()]
	d = Golden.diff(dl, g.deck_ops, "deck_ops")
	if d != "": return d
	var flows: Array = []
	for sd in [1, 2, 3]:
		var st := SaveState.new()
		var ch1 := Collection.ensure_collection(st, PyRandom.new(sd))
		var d0 = _dump(st)
		var ch2 := Collection.ensure_collection(st, PyRandom.new(sd))
		var cat := Collection.card_catalog()
		Collection.grant_cards(st, [cat["Aparar"], cat["Golpe Perfurante"]])
		var o1 := Collection.offer_boss_reward(st, PyRandom.new(sd))
		var o2 := Collection.offer_boss_reward(st, PyRandom.new(sd))
		var oc := _names(Collection.offered_cards(st))
		var picked: Variant = Collection.pick_offer(st, oc[1]) if not oc.is_empty() else null
		var picked2: Variant = Collection.pick_offer(st, "nada")
		flows.append([ch1, d0, ch2, o1, o2, oc, picked.name if picked != null else null, picked2, _dump(st)])
	var st2 := SaveState.new()
	var p2 := Progress.new()
	p2.level = 2
	p2.xp = 120
	st2.progress["durvall"] = p2
	st2.decks = [Collection.CORE_DECK + ["Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe", "Golpe"]]
	st2.collection = ["Golpe", "Chama Menor", "Poção de Cura", "Poção de Cura"]
	flows.append([Collection.ensure_core(st2), _dump(st2)])
	var st3 := SaveState.new()
	var p3 := Progress.new()
	p3.level = 2
	p3.xp = 120
	st3.progress["durvall"] = p3
	flows.append([Collection.ensure_collection(st3, PyRandom.new(4)), _dump(st3)])
	return Golden.diff(flows, g.flows, "flows")

func _new_save(coins: int = 0, achs: Array = [], rules: bool = false, unlocked: Variant = null) -> SaveState:
	var s := SaveState.new()
	s.coins = coins
	s.achievements = Py.set_of(achs)
	s.roster_rules = rules
	if unlocked != null:
		s.unlocked_characters = Py.set_of(unlocked)
	return s

func _prog(level: int, xp: int = 0, kills: int = 0) -> Progress:
	var p := Progress.new()
	p.level = level
	p.xp = xp
	p.kills = kills
	return p

func test_shop() -> String:
	var g = Golden.load_json("shop_meta")
	var rows: Array = []
	for i in Shop.items():
		rows.append([i.id, i.nome, i.preco, i.titulo_requerido, i.tipo, i.unique, i.efeito])
	var d := Golden.diff(rows, g.items, "items")
	if d != "": return d
	var st := _new_save(2000)
	var log: Array = []
	for iid in ["forca_bruta", "forca_bruta", "vitalidade", "mao_maior", "arma_espada", "arma_espada", "armadura_couro", "kayron", "brook", "nada", "mao_cheia", "mao_cheia", "mao_cheia"]:
		var p := Shop.buy(st, iid)
		log.append([iid, p.ok, p.reason, p.item.id if p.item != null else null, p.level, st.coins, Py.set_sorted(st.owned), st.upgrades.duplicate(), st.equipment_units.duplicate(), Py.set_sorted(st.unlocked_characters)])
	d = Golden.diff(log, g.buys, "buys")
	if d != "": return d
	var avail: Array = []
	for coins in [0, 150, 5000]:
		for achs in [[], ["dupla"], ["fechadura", "concluir_m2"], ["dupla", "concluir_m2", "m2_em_dupla", "fechadura"]]:
			var s2 := _new_save(coins, achs, true, ["durvall"])
			var items: Array = []
			for i in Shop.items():
				items.append([i.id, Shop.availability(s2, i), Shop.can_afford(s2, i), Shop.missing_coins(s2, i), Shop.price(s2, i), Shop.owns(s2, i.id)])
			var sa: Array = achs.duplicate()
			sa.sort()
			avail.append([coins, sa, items])
	d = Golden.diff(avail, g.avail, "avail")
	if d != "": return d
	var titles: Array = []
	for t in ["fechadura", "dupla", "nada"]:
		var ids: Array = []
		for i in Shop.items_for_title(t): ids.append(i.id)
		var first = Shop.item_for_title(t)
		titles.append([t, ids, first.id if first != null else null])
	d = Golden.diff(titles, g.titles, "titles")
	if d != "": return d
	var sm := _new_save(10)
	sm.owned = Py.set_of(["neon", "pergaminho", "baralho_2", "arma_adaga"])
	sm.decks = [["a"], ["b"]]
	sm.active_deck = 1
	sm.pending_offer = {"source": "pacote", "cards": ["Golpe"]}
	var m1 := Shop.migrate_removed_items(sm)
	var md = _dump(sm)
	d = Golden.diff([m1, md, Shop.migrate_removed_items(sm)], g.migrate, "migrate")
	if d != "": return d
	var sg := SaveState.new()
	Shop.grant_everything(sg)
	return Golden.diff(_dump(sg), g.grant_all, "grant_all")

func test_achievements_layouts_roster() -> String:
	var g = Golden.load_json("shop_meta")
	var rows: Array = []
	for outcome in ["vitoria", "derrota"]:
		for mid in ["m1", "m2"]:
			for party in [1, 2]:
				for cfg in [[0, 0, 0], [3, 3, 30]]:
					var stt := RunStats.new()
					stt.mission_id = mid
					stt.party_size = party
					stt.crits = cfg[0]
					stt.natural_ones = cfg[1]
					stt.max_hit = cfg[2]
					for setup in range(4):
						var s2 := SaveState.new()
						if setup == 1:
							s2.hqs_seen = {"hq_002": true}
							for c in ["durvall", "maelor", "sylas", "kayron", "brook"]:
								s2.progress[c] = _prog(5)
						if setup == 2:
							s2.missions_completed = {"m2": true}
							s2.progress = {"durvall": _prog(4)}
						if setup == 3:
							s2.roster_rules = true
							s2.unlocked_characters = Py.set_of(["durvall", "maelor"])
							s2.progress = {"durvall": _prog(5), "maelor": _prog(5)}
						var ids: Array = []
						for a in Achievements.evaluate(s2, outcome, stt): ids.append(a.id)
						rows.append([outcome, mid, party, cfg[0], cfg[1], cfg[2], setup, ids])
	var d := Golden.diff(rows, g.ach, "ach")
	if d != "": return d
	var s3 := _new_save(0, ["fechadura", "dupla", "nada"])
	var bn: Array = []
	for k in [Achievements.BONUS_HP, Achievements.GROUP_2, Achievements.MULLIGAN, Achievements.DAMAGE_BONUS]:
		bn.append([k, Achievements.has_benefit(s3, k)])
	d = Golden.diff(bn, g.benefit, "benefit")
	if d != "": return d
	var s4 := SaveState.new()
	s4.collection = Collection.CORE_DECK.duplicate()
	s4.decks = [Collection.CORE_DECK.duplicate()]
	var s4b := SaveState.new()
	s4b.progress = {"durvall": _prog(4)}
	var ea := Achievements.evaluate(s4b, "derrota", RunStats.new())
	var eids: Array = []
	for a in ea: eids.append(a.id)
	var gcs := Achievements.grant_cards(s4, ea)
	d = Golden.diff([eids, gcs, _dump(s4)], g.grant_cards, "grant_cards")
	if d != "": return d
	var s5 := SaveState.new()
	Achievements.unlock_all(s5)
	d = Golden.diff(Py.set_sorted(s5.achievements), g.ach_all, "ach_all")
	if d != "": return d
	var adata: Array = []
	for a in Achievements.all():
		adata.append([a.id, a.name, a.description, a.benefit, a.benefit_key, a.grants])
	d = Golden.diff(adata, g.ach_data, "ach_data")
	if d != "": return d
	var lay: Array = []
	for kills in [0, 9, 10, 25, 30, 99]:
		var s6 := SaveState.new()
		s6.progress = {"durvall": _prog(1, 0, kills), "brook": _prog(1, 0, kills / 2)}
		var ev := LayoutUnlocks.evaluate(s6)
		var ev_ids: Array = []
		for u in ev: ev_ids.append(u.layout_id)
		s6.achievements = {}
		for u in ev.slice(0, 2): s6.achievements[u.achievement_id] = true
		var miss: Array = []
		for u in LayoutUnlocks.all().slice(0, 6): miss.append(LayoutUnlocks.missing_kills(s6, u))
		lay.append([kills, ev_ids, LayoutUnlocks.owned_layouts(s6), miss, LayoutUnlocks.kills_of(s6, "durvall"), LayoutUnlocks.kills_of(s6, "x")])
	d = Golden.diff(lay, g.layouts, "layouts")
	if d != "": return d
	var ld: Array = []
	for u in LayoutUnlocks.all():
		ld.append([u.layout_id, u.achievement_id, u.class_id, u.character_id, u.class_label, u.grade, u.kills_needed, u.name, u.available, u.description])
	d = Golden.diff(ld, g.layout_data, "layout_data")
	if d != "": return d
	var s7 := SaveState.new()
	LayoutUnlocks.unlock_all(s7)
	d = Golden.diff(Py.set_sorted(s7.achievements), g.layout_all, "layout_all")
	if d != "": return d
	var m1: MissionDef = Missions.all()["m1"]
	var m2: MissionDef = Missions.all()["m2"]
	var rr: Array = []
	for achs in [[], ["dupla"], ["dupla", "concluir_m2"], ["dupla", "concluir_m2", "m2_em_dupla", "trio"]]:
		for unl in [[], ["durvall"], ["durvall", "maelor", "brook"]]:
			for rules in [true, false]:
				for done in [[], ["m1"]]:
					var s8 := _new_save(0, achs, rules, unl)
					s8.missions_completed = Py.set_of(done)
					var sa: Array = achs.duplicate()
					sa.sort()
					var su: Array = unl.duplicate()
					su.sort()
					var cb: Array = []
					for c in ["kayron", "durvall", "brook", "x"]: cb.append(Roster.can_buy(s8, c))
					var bh: Array = []
					for c in ["kayron", "brook"]: bh.append(Roster.buy_hint(s8, c))
					var hc: Array = []
					for c in ["durvall", "sylas"]: hc.append(Roster.has_character(s8, c))
					var cp: Array = []
					for m in [m1, m2]:
						for c in ["durvall", "brook"]:
							cp.append([Roster.can_play(m, s8, c), Roster.why_not(m, s8, c)])
					var cf: Array = []
					for ids in [[], ["durvall"], ["durvall", "maelor"], ["durvall", "maelor", "sylas", "kayron"], ["brook"]]:
						cf.append(Roster.can_field(m1, s8, ids))
					rr.append([sa, su, rules, done, Roster.needs_starter(s8), Roster.party_limit(s8), Roster.group_hint(s8), Roster.open_slots(s8),
						Roster.bought_starters(s8), cb, bh, hc, cp, cf])
	d = Golden.diff(rr, g.roster, "roster")
	if d != "": return d
	var s9 := _new_save(0, [], true, [])
	var stl: Array = [Roster.needs_starter(s9), Roster.choose_starter(s9, "brook"), Roster.choose_starter(s9, "sylas"), Roster.choose_starter(s9, "kayron"), Py.set_sorted(s9.unlocked_characters)]
	return Golden.diff(stl, g.starter, "starter")

func test_party() -> String:
	var g = Golden.load_json("party")
	var heal_a: Card = Cards.maelor_deck()[5]
	var heal_b: Card = Cards.starting_deck()[8]
	for rec in g.parties:
		var seed_value := int(rec.seed)
		PyRandom.shared = PyRandom.new(seed_value)
		var ids: Array = [["durvall", "sylas", "kayron"], ["maelor", "brook"], ["sylas"]][seed_value % 3]
		var players: Array = []
		for i in ids:
			players.append(Player.for_character(CharacterDefs.get_def(i), 1 + seed_value % 5))
		var party := Party.create(players)
		players[0].grappled = seed_value % 4 == 0
		players[players.size() - 1].extra_actions_next = seed_value % 3
		party.new_round()
		var rnd: Array = []
		for m in party.members: rnd.append([m.turn.actions_available, m.turn.bonus_available])
		rnd.append(party.active)
		var d := Golden.diff(rnd, rec["round"], "seed %d round" % seed_value)
		if d != "": return d
		if seed_value % 5 == 0:
			players[0].hp = 0
		if seed_value % 6 == 0 and players.size() > 1:
			players[1].hp = 0
			players[1].dead = true
		var acts: Array = []
		for i in range(-1, 4): acts.append(party.activate(i))
		var q: Array = [party.alive_members().size(), party.downed_members().size(), party.dead_members().size(), party.all_down, party.first_alive(), acts,
			party.active, party.round_done(), party.next_with_actions(), party.index_of(players[players.size() - 1]), party.size]
		var want_q: Array = rec.query.duplicate()
		want_q[8] = -1 if want_q[8] == null else want_q[8]
		d = Golden.diff(q, want_q, "seed %d query" % seed_value)
		if d != "": return d
		var enemy: Enemy = Enemies.guardiao_verdadeiro() if seed_value % 2 == 1 else Enemies.sacerdote_mente_derretida()
		for _i in range(seed_value % 4): enemy.choose_action()
		var targets: Array = []
		for _i in range(6):
			var t := party.choose_target(enemy)
			var flags: Array = []
			for p in players: flags.append(p.clone_targeted)
			targets.append([party.index_of(t.player), flags])
		d = Golden.diff(targets, rec.targets, "seed %d targets" % seed_value)
		if d != "": return d
		var at: Array = []
		for _i in range(4):
			var l: Array = []
			for m in party.attack_targets(enemy): l.append(party.index_of(m.player))
			at.append(l)
		d = Golden.diff(at, rec.attack_targets, "seed %d attack_targets" % seed_value)
		if d != "": return d
		var caster: Member = party.members[0]
		players[players.size() - 1].hp = maxi(1, players[players.size() - 1].hp - 3)
		var res: Array = []
		for tgt in party.members:
			var r: Variant = party.heal_ally(caster, tgt, heal_a)
			if r == null:
				res.append([false])
			else:
				res.append([true, r[0].total, r[1], r[2], tgt.player.hp])
		var htg: Array = []
		for c in [heal_a, heal_b]:
			var l2: Array = []
			for m in party.heal_targets(caster, c): l2.append(party.members.find(m))
			htg.append(l2)
		d = Golden.diff([htg, res], [rec.heal_targets, rec.heal_res], "seed %d heal" % seed_value)
		if d != "": return d
		var ta: Array = []
		for m in party.members: ta.append([m.turn.actions_available, m.turn.bonus_available])
		d = Golden.diff(ta, rec.turn_after, "seed %d turn_after" % seed_value)
		if d != "": return d
	Party.create([])
	return Golden.diff(Party.last_error, g.bad, "bad")
