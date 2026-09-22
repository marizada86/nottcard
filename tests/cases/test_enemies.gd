extends RefCounted

func _factories() -> Dictionary:
	return {"mimico": func(): return Enemies.mimico(9, 11, 10), "mimico15": func(): return Enemies.mimico(15, 12, 10, 25),
		"criatura": Enemies.criatura_corrompida, "slime": Enemies.slime_corrosivo, "guardiao_copia": Enemies.guardiao_copia,
		"guardiao_verdadeiro": Enemies.guardiao_verdadeiro, "cultista_adaga": Enemies.cultista_adaga,
		"cultista_cajado": Enemies.cultista_cajado, "cultista_arqueiro": Enemies.cultista_arqueiro, "zumbi": Enemies.zumbi,
		"sacerdote": Enemies.sacerdote_mente_derretida}

func test_snapshots() -> String:
	var g = Golden.load_json("enemies")
	var f := _factories()
	for n in g.snap:
		var e: Enemy = f[n].call()
		var want: Dictionary = g.snap[n]
		for k in want:
			var got: Variant
			match k:
				"has_script": got = e.enc_script != null
				"slug": got = e.slug
				"eca": got = e.effective_ca
				"ecam": got = e.effective_cam
				"script": continue
				_: got = e.get(k)
			var d := Golden.diff(got, want[k], "%s.%s" % [n, k])
			if d != "": return d
	return ""

func test_behaviour() -> String:
	var g = Golden.load_json("enemies")
	var f := _factories()
	for b in g.beh:
		var e: Enemy = f[b.n].call()
		var n: String = b.n
		var p := e.peek_action()
		var seq := [p[0], p[1], e.peek_is_special(), e.peek_is_magical(), e.peek_is_area()]
		var d := Golden.diff(seq, b.seq, n + " seq")
		if d != "": return d
		var acts: Array = []
		for _i in range(4): acts.append(e.choose_action())
		d = Golden.diff(acts, b.acts, n + " acts")
		if d != "": return d
		var stun := [e.try_stun(2), e.can_be_stunned, e.try_stun()]
		d = Golden.diff(stun, b.stun, n + " stun")
		if d != "": return d
		e.consume_stun()
		d = Golden.diff([e.stunned, e.stun_left, e.stun_immune], b.s1, n + " s1")
		if d != "": return d
		e.consume_stun()
		d = Golden.diff([e.stunned, e.stun_left, e.stun_immune], b.s2, n + " s2")
		if d != "": return d
		e.tick_stun_immunity()
		d = Golden.diff(e.stun_immune, b.s3, n + " s3")
		if d != "": return d
		e.stun_immune = 0
		var drops := [e.break_armor(3), e.break_armor(3), e.break_ward(2), e.break_ward(9), e.effective_ca, e.effective_cam, e.is_vulnerable]
		d = Golden.diff(drops, b.drops, n + " drops")
		if d != "": return d
		e.mark(2); e.mark(1)
		var m := [e.marked_bonus, e.consume_mark(), e.consume_mark()]
		d = Golden.diff(m, b.mark, n + " mark")
		if d != "": return d
		if b.summ != null:
			e.hp = e.max_hp / 2 + 1
			var a := e.enc_script.check(e)
			e.hp = e.max_hp / 2
			var names: Array = []
			for x in e.enc_script.check(e): names.append(x.name)
			var c2 := e.enc_script.check(e)
			d = Golden.diff([a.size(), names, c2.size(), e.enc_script.fired], b.summ, n + " summ")
			if d != "": return d
	return ""

func test_roll() -> String:
	var g = Golden.load_json("enemies")
	PyRandom.shared = PyRandom.new(int(g.roll.seed))
	var e := Enemies.zumbi()
	var got := [Enemy.roll_damage("2d6"), Enemy.roll_damage("1d8", true), e.act(), e.act()]
	return Golden.diff(got, g.roll.dmg, "roll")
