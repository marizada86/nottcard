extends RefCounted
## Paridade de mapas, missões, caminhada, exploração e eventos com o Python.

func test_maps_and_missions() -> String:
	var g = Golden.load_json("world")
	for mid in ["m1", "m2"]:
		var dg := Dungeon.load_module("dungeon_" + mid)
		var d := Golden.diff(dg.ascii_map(), g.maps[mid], "mapa " + mid)
		if d != "": return d
	var ms: Dictionary = Missions.all()
	for mid in g.missions:
		var m: MissionDef = ms[mid]
		var w: Dictionary = g.missions[mid]
		var rooms: Array = []
		for r in m.rooms:
			var names: Array = []
			var hps: Array = []
			if r.enemy_factory.is_valid() or r.group_factory.is_valid():
				for e in r.make_enemies():
					names.append(e.name)
					hps.append(e.hp)
			rooms.append([r.id, r.name, r.kind, r.asset_id, r.optional, r.is_boss, r.xp, r.reward_tier, r.fog, names, hps])
		var intro: Array = []
		for i in range(1, 8): intro.append(m.room_intro(i))
		var ends: Array = []
		for o in ["vitoria", "derrota", "desistencia"]: ends.append(m.run_end(o))
		var flavor: Array = []
		for n in ["Slime corrosivo", "Zumbi", "Zumbi"]: flavor.append(m.enemy_flavor(n))
		var amb: Array = []
		for i in range(1, 8): amb.append(m.ambiente(i))
		var idx: Array = []
		for r in m.rooms: idx.append(m.index_of(r.id))
		var got := {"title": m.title, "cast": m.cast, "requires": m.requires, "edges": m.edges, "start": m.start, "rooms": rooms,
			"completion_xp": m.completion_xp, "boss": m.boss_id, "event_ids": m.event_ids, "event_rooms": m.event_rooms, "amb": amb,
			"hq": [m.exit_hq, m.briefing_hq], "intro": intro, "end": ends, "flavor": flavor, "index": idx}
		var d2 := Golden.diff(got, w, "missão " + mid)
		if d2 != "": return d2
	var un: Array = []
	# Este golden cobre o contrato histórico de M1/M2; M3 tem contrato próprio em test_m3.gd.
	for mid in ["m1", "m2"]:
		var m: MissionDef = ms[mid]
		for c in [{}, {"m1": true}]:
			un.append([m.id, Missions.is_unlocked(m, c)])
	var d3 := Golden.diff(un, g.unlock, "unlock")
	if d3 != "": return d3
	var fog: Array = []
	for a in ["sala_2_cais", "sala_1_docas", "m2_sala_2_praca", "sala_6_ritual", null]:
		fog.append(Missions.fog_for_backdrop(a))
	return Golden.diff(fog, g.fog, "fog")

func test_walker() -> String:
	var g = Golden.load_json("world")
	var ms: Dictionary = Missions.all()
	for wk in g.walks:
		var mission: MissionDef = ms[wk.mid]
		var dg := mission.dungeon
		var world := mission.make_world()
		var grid := dg.build()
		var w := Walker.new(grid, dg.start[0], dg.start[1], dg.start[2])
		w.gate = WalkRules.make_gate(world, mission.rooms_by_id, dg)
		var i := 0
		for c in wk.cmds:
			var evs: Array = w.call(c)
			var got := [c, WorldSupport.ev_arrays(evs), w.x, w.y, w.facing, w.room, w.block_reason]
			var d := Golden.diff(got, wk.steps[i], "walk %s seed %d passo %d" % [wk.mid, wk.seed, i])
			if d != "": return d
			if i % 25 == 24:
				var lim: int = (i / 25) % 3 + 1
				for rid in [2, 3, 5].slice(0, lim):
					world.clear(rid)
			i += 1
		var opened: Array = []
		for k in w.opened: opened.append([k.x, k.y])
		opened.sort()
		var d2 := Golden.diff([opened, w.visited.size()], [wk.opened, wk.visited], "walk %s fim" % wk.mid)
		if d2 != "": return d2
		var oc: Array = []
		for x in range(0, 12):
			for y in [10, 12]:
				oc.append([x, y, w.is_open(x, y)])
		d2 = Golden.diff(oc, wk.open_checks, "open_checks")
		if d2 != "": return d2
	return ""

func test_worldmap_and_cells() -> String:
	var g = Golden.load_json("world")
	var wm: WorldMap = Missions.all()["m1"].make_world()
	var log: Array = [wm.neighbors(2), wm.neighbors(1), wm.can_move_to(2), wm.can_move_to(3)]
	wm.move_to(2)
	wm.move_to(4)
	log.append("moved" if wm.move_to(1) else "err")
	wm.clear()
	wm.clear(2)
	var vis: Array = wm.visible().keys()
	vis.sort()
	log.append_array([vis, wm.visible_edges(), wm.is_cleared(4), wm.is_cleared(5), wm.current])
	var d := Golden.diff(log, g.worldmap, "worldmap")
	if d != "": return d
	var ev: Array = []
	for mid in ["m1", "m2"]:
		var dg: Dungeon = Missions.all()[mid].dungeon
		var rng := PyRandom.new(9)
		for room in dg.room_rects:
			var c := dg.event_cell(room, rng)
			ev.append([mid, room, [c.x, c.y]])
	return Golden.diff(ev, g.event_cells, "event_cells")

func test_exploration() -> String:
	var g = Golden.load_json("exploration")
	var armors := {"none": null, "cota": WorldSupport.armor("armadura_cota"), "placa": WorldSupport.armor("armadura_placa")}
	var n := 0
	for rec in g.checks:
		var mission: MissionDef = Missions.all()[rec.mid]
		var sit: Situation = mission.situations[int(rec.room)]
		var opt: Option = sit.options[int(rec.oi)]
		var seed_value := n_seed(g, rec)
		var p := WorldSupport.mk_player(rec.cid, int(rec.level), seed_value, armors[rec.armor], [WorldSupport.item("lupa_de_latao"), WorldSupport.item("faixa_de_couro")])
		if int(rec.oi) % 2 == 1:
			p.backpack.equip(WorldSupport.item("lupa_de_latao"))
		var prev = Exploration.check_preview(p, opt)
		PyRandom.shared = PyRandom.new(seed_value + 1000)
		var chk := Exploration.resolve_check(p, opt)
		var got := {"chk": Golden.plain(chk), "prev": Golden.plain(prev), "can_luck": Exploration.can_use_luck(p, chk)}
		if got.can_luck:
			got["luck"] = Golden.plain(Exploration.reroll_with_luck(p, opt, chk))
			got["luck_left"] = p.luck
		PyRandom.shared = PyRandom.new(seed_value + 2000)
		var app := Exploration.apply_result(p, opt, chk, seed_value % 2 == 0)
		got["applied"] = Golden.plain(app)
		var bag: Array = []
		for i in p.backpack.bag: bag.append(i.id)
		got["snap"] = [p.hp, p.hand.size(), p.draw_pile.size(), p.discard.size(), p.exhausted.size(), bag, p.backpack.accessory.id if p.backpack.accessory != null else null]
		if app.pending != null:
			var budget := TempBudget.new()
			PyRandom.shared = PyRandom.new(seed_value + 3000)
			var settled := Exploration.settle_reward(p, app, seed_value % 3 != 0, budget, PyRandom.new(seed_value))
			got["settled"] = Golden.plain(settled)
			got["budget"] = [budget.cards, budget.items]
		var want: Dictionary = rec.duplicate()
		for k in ["mid", "room", "oi", "cid", "level", "armor"]:
			want.erase(k)
		var d := Golden.diff(got, want, "exploração #%d %s sala %s op %s %s nv%s %s" % [n, rec.mid, rec.room, rec.oi, rec.cid, rec.level, rec.armor])
		if d != "": return d
		n += 1
	return ""

## A semente de cada cenário é o contador global do gerador (1, 2, ...), incluindo as opções sem teste (que pulam o registro).
func n_seed(g: Dictionary, rec: Dictionary) -> int:
	if not g.has("_seeds"):
		var seeds := {}
		var seed_value := 0
		var armors := ["none", "cota", "placa"]
		for mid in ["m1", "m2"]:
			var mission: MissionDef = Missions.all()[mid]
			var rooms := mission.situations.keys()
			for room in rooms:
				var sit: Situation = mission.situations[room]
				for oi in range(sit.options.size()):
					for cl in [["durvall", 1], ["durvall", 5], ["maelor", 3], ["brook", 5], ["kayron", 2]]:
						for a in armors:
							seed_value += 1
							seeds["%s|%d|%d|%s|%d|%s" % [mid, room, oi, cl[0], cl[1], a]] = seed_value
		g["_seeds"] = seeds
	return g["_seeds"]["%s|%d|%d|%s|%d|%s" % [rec.mid, int(rec.room), int(rec.oi), rec.cid, int(rec.level), rec.armor]]

func test_exploration_misc() -> String:
	var g = Golden.load_json("exploration")
	var rk: Array = []
	for _o in [true, false]:
		for oc in [Outcome.make("x", {"xp": 3, "draw": 2, "item": "lupa_de_latao"}), Outcome.make("y", {"xp": 0})]:
			rk.append(Exploration.reward_kinds(oc))
	var d := Golden.diff(rk, g.reward, "reward_kinds")
	if d != "": return d
	var fights := {}
	var sits: Dictionary = Exploration.situations()
	for room in sits:
		var labels: Array = []
		var has := false
		for o in sits[room].options:
			if o.failure.fight == "sala":
				labels.append(o.label)
				has = true
		if has:
			fights[str(room)] = labels
	return Golden.diff(fights, g.fights, "fights")

func test_events() -> String:
	var g = Golden.load_json("events")
	var d := Golden.diff([[0, EventPlan.chance(0)], [1, EventPlan.chance(1)], [2, EventPlan.chance(2)], [3, EventPlan.chance(3)], [4, EventPlan.chance(4)]], g.chance, "chance")
	if d != "": return d
	d = Golden.diff([EventPlan.next_pity(2, true), EventPlan.next_pity(2, false)], g["next"], "next_pity")
	if d != "": return d
	for pl in g.plans:
		var rng := PyRandom.new(int(pl.seed))
		var m: MissionDef = Missions.all()[pl.mid]
		var evd: Array = []
		for e in Events.all():
			if m.event_ids == null or e.id in m.event_ids:
				evd.append(e)
		var plan := EventPlan.roll_plan(int(pl.pity), evd, rng, m.event_rooms, int(pl.seed) % 5 == 0)
		var arr: Array = []
		for i in plan: arr.append([i.event_id, i.room])
		d = Golden.diff({"plan": arr, "next": rng.random()}, {"plan": pl.plan, "next": pl["next"]}, "plano pity %s seed %s" % [pl.pity, pl.seed])
		if d != "": return d
	var idx := 0
	for seed_value in range(1, 40):
		for eid in ["bau", "mercador", "viajante", "altar", "fenda", "frasco"]:
			var room := 2 + seed_value % 5
			var inst := EventInstance.new(eid, room)
			var rng := PyRandom.new(seed_value)
			inst.state = Events.roll_state(inst, rng)
			d = Golden.diff(Golden.plain(inst.state), g.states[idx][3], "estado %s seed %d" % [eid, seed_value])
			if d != "": return d
			PyRandom.shared = PyRandom.new(seed_value)
			var players: Array = [WorldSupport.mk_player("brook" if seed_value % 3 == 0 else "durvall", 5 if seed_value % 2 == 1 else 1, seed_value)]
			if seed_value % 4 == 0:
				players[0].dishonored = true
			if seed_value % 7 == 0:
				players[0].hand.append(Cards.c("LOCALIZAR_CRIATURA"))
			var s := Events.build_situation(inst, players)
			var opts: Array = []
			for o in s.options:
				opts.append([o.label, o.check_label, o.dc, o.attribute, o.auto, o.cost_gold, Golden.plain(o.success), Golden.plain(o.failure), Golden.plain(o.critical)])
			d = Golden.diff({"title": s.title, "lines": s.lines, "opts": opts, "state": Golden.plain(inst.state)}, g.situations[idx][3], "situação %s seed %d" % [eid, seed_value])
			if d != "": return d
			idx += 1
	return ""

func test_events_misc() -> String:
	var g = Golden.load_json("events")
	var fx: Array = []
	var inst := EventInstance.new("bau", 4)
	inst.state = {"mimic": true, "locked": false, "gold": 20, "reward": "", "revealed": false, "examined": false}
	fx.append([Events.apply_effect(inst, "reveal"), Golden.plain(inst.state)])
	inst = EventInstance.new("mercador", 4)
	inst.state = {"offer": [1], "sold": [], "rerolls": 0}
	PyRandom.shared = PyRandom.new(4)
	fx.append([Events.apply_effect(inst, "sold:2"), Events.apply_effect(inst, "sold:0"), Events.apply_effect(inst, ""), Events.apply_effect(inst, "nada"), Golden.plain(inst.state)])
	var d := Golden.diff(fx, g.effects, "effects")
	if d != "": return d
	var mim: Array = []
	for mid in ["m1", "m2"]:
		Missions.set_current(mid)
		for room in [1, 2, 3, 4, 5]:
			var m := Events.make_mimic(EventInstance.new("bau", room))
			mim.append([mid, room, m.hp, m.ca, m.cam, m.xp])
	Missions.set_current("m1")
	return Golden.diff(mim, g.mimic, "mimic")
