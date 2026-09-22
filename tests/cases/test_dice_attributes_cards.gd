extends RefCounted

func test_golden() -> String:
	var g = Golden.load_json("dice_attributes_cards")
	for k in g.modifier:
		var d := Golden.diff(Attributes.modifier(int(k)), g.modifier[k], "modifier " + k)
		if d != "": return d
	for row in g.combine:
		var d := Golden.diff(Dice.combine(row[0]), row[1], "combine " + str(row[0]))
		if d != "": return d
	for row in g.pick_d20:
		var d := Golden.diff(Dice.pick_d20(row[0], int(row[1]), row[2] if row[2] == null else int(row[2])), row[3], "pick_d20 " + str(row))
		if d != "": return d
	for r in g.rolls:
		var rng := PyRandom.new(int(r.seed))
		var got: Array = []
		for dsp in ["1d4", "2d6", "3d6", "1d20", "2d8", "1d10", "1d12"]:
			got.append(Dice.roll(dsp, rng))
		var d := Golden.diff(got, r.roll, "roll seed %d" % r.seed)
		if d != "": return d
		var got20: Array = []
		for st in ["normal", "vantagem", "desvantagem", "vantagem"]:
			got20.append(Dice.roll_d20(st, rng))
		d = Golden.diff(got20, r.d20, "d20 seed %d" % r.seed)
		if d != "": return d
	for k in g.sides_of:
		var d := Golden.diff(Dice.sides_of(k), g.sides_of[k], "sides_of " + k)
		if d != "": return d
	var i := 0
	for a in [Attributes.durvall(), Attributes.maelor(), Attributes.sylas(), Attributes.kayron(), Attributes.brook()]:
		var d := Golden.diff([Attributes.armor_class(a), Attributes.magic_armor_class(a)], g.ac[i], "ac %d" % i)
		if d != "": return d
		i += 1
	for n in g.cards:
		var c: Card = Cards.c(n)
		var want = g.cards[n]
		var d := Golden.diff({"slug": c.slug, "targets_enemy": c.targets_enemy, "targets_ally": c.targets_ally, "ally_hint": c.ally_hint}, want, "card " + n)
		if d != "": return d
	var decks := {"starting": Cards.starting_deck(), "maelor": Cards.maelor_deck(), "sylas": Cards.sylas_deck(), "kayron": Cards.kayron_deck(), "brook": Cards.brook_deck()}
	for k in decks:
		var names: Array = []
		for c in decks[k]:
			names.append(c.name)
		var d := Golden.diff(names, g.decks[k], "deck " + k)
		if d != "": return d
	for k in g.slugify:
		var d := Golden.diff(Card.slugify(k), g.slugify[k], "slugify '%s'" % k)
		if d != "": return d
	return ""
