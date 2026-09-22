extends RefCounted

func test_turn() -> String:
	var g = Golden.load_json("turn_death_saves")
	var seen := {}
	var all_cards: Array = [Cards.c("ESQUIVA"), Cards.c("RAJADA_DE_GOLPES"), Cards.c("GOLPE_RAPIDO"), Cards.c("GOLPE_ESMAGADOR"), Cards.c("LOCALIZAR_CRIATURA")]
	all_cards.append_array(Cards.starting_deck())
	for c in all_cards:
		seen[c.name] = c
	var i := 0
	for row in g.turn:
		var c: Card = seen[row.card]
		var t := TurnState.new()
		t.actions_available = int(row.act); t.bonus_available = row.bonus; t.hit_this_turn = row.hit
		var got := {"card": c.name, "hit": row.hit, "act": row.act, "bonus": row.bonus, "can_play": t.can_play(c)}
		if got.can_play:
			t.spend_for(c)
			got["after"] = [t.actions_available, t.bonus_available]
		var react: Array = []
		for k in ["fisico", "magico", "x"]:
			for r in [true, false]:
				react.append(t.can_react(c, k, r))
		got["react"] = react
		got["end"] = t.should_end
		var d := Golden.diff(got, row, "turn[%d]" % i)
		if d != "": return d
		i += 1
	var t2 := TurnState.new()
	var sp := [t2.spend_action(), t2.spend_action(), t2.spend_bonus(), t2.spend_bonus(), t2.should_end, t2.reaction_available]
	t2.spend_reaction()
	sp.append(t2.reaction_available)
	return Golden.diff(sp, g.spend[0], "spend")

func test_saves() -> String:
	var g = Golden.load_json("turn_death_saves")
	for sc in g.saves:
		var s := DeathSaves.new()
		var seq: Array = []
		for r in sc.rolls:
			var o := s.apply_roll(int(r))
			seq.append([o.roll, o.success, o.natural20, o.natural1, o.revived, o.died, o.successes, o.failures])
		var d := Golden.diff(seq, sc.seq, "saves " + str(sc.rolls))
		if d != "": return d
		d = Golden.diff([s.successes, s.failures], sc["end"], "saves end")
		if d != "": return d
	var rng := PyRandom.new(11)
	return Golden.diff([DeathSaves.roll_d20(rng), DeathSaves.roll_d20(rng)], g.seeded, "seeded")
