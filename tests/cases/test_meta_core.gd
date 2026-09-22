extends RefCounted

var g: Dictionary = Golden.load_json("meta_core")

func _d(a: Variant, b: Variant, p: String) -> String:
	return Golden.diff(a, b, p)

func test_characters() -> String:
	var ids: Array = CharacterDefs.all().keys()
	var d := _d(ids, g.char_ids, "ids")
	if d != "": return d
	for cid in g.chars:
		var c: CharacterDef = CharacterDefs.get_def(cid)
		var w: Dictionary = g.chars[cid]
		var hp: Array = []
		var attrs: Array = []
		var hooks: Array = []
		var passives: Array = []
		var rewards: Array = []
		var decks: Array = []
		for l in range(1, 6):
			hp.append(c.hp_at(l))
			attrs.append(c.attributes_at(l))
			hooks.append(Py.set_sorted(c.hooks_at(l)))
			passives.append(c.unlocked_passives(l))
			rewards.append(c.reward_texts(l))
			var names: Array = []
			for x in c.deck_at(l): names.append(x.name)
			decks.append(names)
		var cat: Array = []
		for pair in c.catalog():
			cat.append([pair[0].name, pair[1]])
		var colormod := {}
		for col in ["Vermelho", "Amarelo", "Azul", "Roxo"]:
			colormod[col] = c.color_modifier(col)
		var chain := {}
		for x in c.deck_at(5):
			chain[x.name] = [c.counts_for_chain(x), c.hit_attribute(x)]
		for pair in [["max_hp", c.max_hp], ["hp", hp], ["attrs", attrs], ["hooks", hooks], ["passives", passives], ["rewards", rewards],
				["deck_at", decks], ["catalog", cat], ["colormod", colormod], ["chain", chain]]:
			d = _d(pair[1], w[pair[0]], "%s.%s" % [cid, pair[0]])
			if d != "": return d
	return ""

func test_upgrades_and_economy() -> String:
	var variants: Array = [{}, {"forca_bruta": 3}, {"forca_bruta": 9, "vitalidade": 2, "mao_maior": 2, "ganancia": 1, "sorte": -3, "x": 4}, null]
	var i := 0
	for ups in variants:
		var w: Dictionary = g.upgrades[i]
		var levels := {}
		var maxed := {}
		var cost := {}
		for u in Upgrades.all():
			levels[u.id] = Upgrades.level(ups, u.id)
			maxed[u.id] = Upgrades.is_maxed(ups, u.id)
			cost[u.id] = Upgrades.cost_of_next(ups, u.id)
		var greed: Array = []
		for gain in [-1, 0, 1, 7, 33, 100]:
			greed.append(Upgrades.coins_with_greed(ups, gain))
		var got := {"levels": levels, "maxed": maxed, "cost": cost, "mult": Upgrades.damage_multiplier(ups), "hp": Upgrades.bonus_hp(ups),
			"hand": Upgrades.hand_limit(ups), "extra_hand": Upgrades.extra_hand(ups), "rer": Upgrades.rerolls(ups), "luck": Upgrades.extra_luck(ups),
			"bag": Upgrades.extra_bag_slots(ups), "greed": greed}
		var d := _d(got, w, "upgrades[%d]" % i)
		if d != "": return d
		i += 1
	var rows: Array = []
	for ups in variants:
		for cm in [-2, 0, 1, 3]:
			for outcome in ["vitoria", "derrota", "desistencia"]:
				var st := Economy.settle_coins(37, 25, outcome, ups, cm)
				rows.append([cm, outcome, st.xp_coins, st.bag_coins, st.multiplier, st.charisma_pct, st.greed_pct, st.total])
	var d2 := _d(rows, g.economy, "economy")
	if d2 != "": return d2
	var led := RunLedger.new()
	led.mission_gold = 10
	var save := SaveState.new()
	save.coins = 5
	var sp: Array = [Economy.spend_gold(led, save, 0), Economy.spend_gold(led, save, 12), [led.mission_gold, save.coins],
		Economy.spend_gold(led, save, 4), [led.mission_gold, save.coins], Economy.spendable_gold(led, save)]
	return _d(sp, g.spend, "spend")

func test_progress() -> String:
	var lv: Array = []
	for l in range(0, 8): lv.append(ProgressRules.xp_for_level(l))
	var lx: Array = []
	for x in [0, 99, 100, 349, 350, 950, 1949, 1950, 99999]: lx.append(ProgressRules.level_for_xp(x))
	var d := _d([lv, lx], g.xp_levels, "xp_levels")
	if d != "": return d
	var prog := Progress.new()
	var rows: Array = []
	var rf := func(l): return ["r%d" % l]
	for amt in [50, 60, 300, 700, 5000, 5000]:
		var row: Array = []
		for u in prog.add_xp(amt, rf):
			row.append([u.level, u.rewards])
		rows.append([row, prog.level, prog.xp, prog.fraction_to_next(), prog.next_threshold(), prog.at_cap])
	d = _d(rows, g.progress, "progress")
	if d != "": return d
	var led := RunLedger.new()
	led.xp_mult = 2
	led.add("a", 30); led.add("b", 0); led.add("c", 45); led.add_gold(7)
	var p2 := Progress.new()
	p2.xp = 90
	var res := ProgressRules.settle_run(p2, led, "derrota", RunStats.new(), "durvall", func(l): return ["x%d" % l])
	var ups: Array = []
	for u in res.level_ups: ups.append([u.level, u.rewards])
	var lines: Array = []
	for l in res.lines: lines.append([l.source, l.amount])
	var got := [res.outcome, res.raw_xp, res.adjustment, res.gained, res.level_before, res.level_after, res.xp_before, res.xp_after, ups, lines, led.total, led.mission_gold]
	d = _d(got, g.settle, "settle")
	if d != "": return d
	var ao: Array = []
	for gain in [0, 1, 7, 45]:
		for o in ["vitoria", "derrota", "desistencia"]:
			ao.append(ProgressRules.apply_outcome(gain, o))
	return _d(ao, g.apply_outcome, "apply_outcome")

func test_equipment() -> String:
	var w: Array = g.equipment
	var st := SaveState.new()
	var log: Array = []
	log.append([Equipment.equip(st, "durvall", "arma_espada")])
	Equipment.add_unit(st, "arma_espada")
	Equipment.add_unit(st, "armadura_placa", 2)
	Equipment.add_unit(st, "arma_cetro")
	log.append([Equipment.equip(st, "durvall", "arma_espada"), Equipment.equip(st, "brook", "arma_espada"), Equipment.equip(st, "maelor", "arma_cetro"),
		Equipment.equip(st, "durvall", "arma_cetro"), Equipment.equip(st, "durvall", "armadura_placa"), Equipment.equip(st, "brook", "armadura_placa"),
		Equipment.equip(st, "sylas", "armadura_placa")])
	var eqd := {}
	var eo: Dictionary = Equipment.equipped_of(st, "brook")
	for k in eo:
		eqd[k] = eo[k].id if eo[k] != null else ""
	log.append([Equipment.units(st, "arma_espada"), Equipment.free_units(st, "armadura_placa"), Equipment.in_use_by(st, "armadura_placa"),
		Equipment.armor_deltas(st, "durvall"), eqd, Equipment.block_reason(st, "sylas", "armadura_placa"),
		Equipment.block_reason(st, "durvall", "arma_maca"), Equipment.block_reason(st, "maelor", "arma_espada")])
	var ids: Array = []
	var t1 := Equipment.transfer(st, "durvall", "brook", "arma")
	var t2 := Equipment.transfer(st, "durvall", "maelor", "armadura")
	var t3 := Equipment.unequip(st, "durvall", "arma")
	var t4 := Equipment.unequip(st, "durvall", "arma")
	for e in Equipment.owned_in_slot(st, "arma"): ids.append(e.id)
	log.append([t1, t2, t3, t4, ids, st.equipped])
	var st2 := SaveState.new()
	st2.owned = Py.set_of(["arma_adaga", "armadura_couro"])
	st2.equipped = {"durvall": {"arma": "arma_adaga"}}
	var m1 := Equipment.migrate_units(st2)
	var m_units := st2.equipment_units.duplicate()
	log.append([m1, m_units, Equipment.migrate_units(st2)])
	var rows: Array = []
	for e in Equipment.all():
		rows.append([e.id, e.users_text, e.stealth_text, e.effect_text])
	log.append(rows)
	return _d(log, w, "equipment")

func test_scrolls() -> String:
	var st := SaveState.new()
	var log: Array = []
	log.append([Scrolls.add(st, "durvall", "curar_ferimentos"), Scrolls.add(st, "durvall", "nao_existe"), Scrolls.add(st, "durvall", "bencao"),
		Scrolls.add(st, "durvall", "escudo_arcano"), Scrolls.add(st, "durvall", "ajuda"), Scrolls.is_full(st, "durvall")])
	var bencao: ScrollDef = Scrolls.by_id("bencao")
	var c1 := Scrolls.consume(st, "durvall", bencao.card)
	var c2 := Scrolls.consume(st, "durvall", bencao.card)
	var names: Array = []
	for c in Scrolls.stock_cards(st, "durvall"): names.append(c.name)
	log.append([c1, c2, Scrolls.stock_of(st, "durvall"), names, Scrolls.total_stock(st), Scrolls.recipient(st, ["maelor", "durvall"]),
		Scrolls.recipient(st, ["durvall", "maelor"])])
	Scrolls.add(st, "durvall", "bencao")
	var o := Scrolls.offer(2, PyRandom.new(3))
	Scrolls.set_offer(st, "durvall", o)
	var oids: Array = []
	for s in o: oids.append(s.id)
	var offered: Array = []
	for c in Scrolls.offered_cards(st): offered.append(c.name)
	log.append([oids, st.pending_offer, offered])
	var p1 := Scrolls.pick(st, o[0].card.name)
	var po1 = st.pending_offer
	var s1 := Scrolls.swap_pending(st, "nada")
	var s2 := Scrolls.swap_pending(st, st.scrolls["durvall"][0])
	log.append([p1, po1, s1, s2, st.pending_offer, st.scrolls])
	Scrolls.set_offer(st, "maelor", Scrolls.offer(1, PyRandom.new(9)))
	var dc1 := Scrolls.decline_pending(st)
	var dpo = st.pending_offer
	log.append([dc1, dpo, Scrolls.decline_pending(st), Scrolls.pick(st, "x")])
	var lost := Scrolls.clear_all(st)
	var t3: Array = []
	for s in Scrolls.scrolls_of_tier(3): t3.append(s.id)
	log.append([lost, st.scrolls, t3, Scrolls.card_of("bencao").name, Scrolls.card_of("Pergaminho de Bênção").name, Scrolls.card_of("nada") == null])
	return _d(log, g.scrolls, "scrolls")

func test_backpack() -> String:
	var items: Dictionary = GameData.module("items")
	var LUPA: ItemDef = items["LUPA"]
	var FAIXA: ItemDef = items["FAIXA"]
	var CARTA: ItemDef = items["CARTA"]
	var bp := Backpack.for_character(CharacterDefs.durvall(), 1)
	var ilog: Array = [bp.weapon.id, bp.slots, bp.add(LUPA), bp.add(FAIXA), bp.add(CARTA), bp.add(LUPA), bp.add(LUPA), bp.is_full,
		bp.equip(CARTA), bp.equip(LUPA), bp.accessory.id]
	var bag: Array = []
	for i in bp.bag: bag.append(i.id)
	ilog.append(bag)
	ilog.append(bp.equip(FAIXA))
	ilog.append(bp.accessory.id)
	bag = []
	for i in bp.bag: bag.append(i.id)
	ilog.append(bag)
	ilog.append_array([bp.check_bonus("forca"), bp.check_bonus("inteligencia"), bp.unequip(), bp.has_actions, bp.has_anything])
	var texts: Array = []
	for i in items["ITEMS"].values(): texts.append(i.effect_text)
	ilog.append(texts)
	ilog.append_array([bp.take_pending_bonus(), bp.discard(CARTA), bp.discard(CARTA), bp.use(LUPA)])
	var bp2 := Backpack.new()
	bp2.add(LUPA)
	ilog.append_array([bp.give(FAIXA, bp2), bp.give(FAIXA, bp2), bp.give(LUPA, bp)])
	var b2: Array = []
	for i in bp2.bag: b2.append(i.id)
	ilog.append(b2)
	return _d(ilog, g.backpack, "backpack")

func test_save_roundtrip() -> String:
	var w: Dictionary = g.save
	var s1 := SaveState.from_dict(GameData.hydrate(w.raw))
	if s1 == null:
		return "from_dict falhou: " + SaveState.last_error
	var d := _d(s1.to_dict(), w["dict"], "dict")
	if d != "": return d
	d = _d(SaveState.from_dict(GameData.hydrate(s1.to_dict())).to_dict(), w["again"], "again")
	if d != "": return d
	var bad: Array = []
	var raw: Dictionary = GameData.hydrate(w.raw)
	var patches: Array = [{"version": 2}, {"progress": []}, {"coins": "x"}, {"decks": [[1]]}, {"pending_offer": {"source": 1, "cards": []}},
		{"upgrades": {"a": true}}, {"achievements": [1]}, {"event_pity": 1.5}]
	for patch in patches:
		var data := raw.duplicate(true)
		for k in patch: data[k] = patch[k]
		var r := SaveState.from_dict(data)
		bad.append("ok" if r != null else SaveState.last_error)
	d = _d(bad, w.bad, "bad")
	if d != "": return d
	d = _d(SaveState.from_dict({}).to_dict(), w.empty, "empty")
	if d != "": return d
	return _d([s1.has_progress, SaveState.new().has_progress], w.has_progress, "has_progress")
