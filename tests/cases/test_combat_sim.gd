extends RefCounted
## Paridade do combate: as mesmas lutas (semente + política fixa) do Python, comparadas passo a passo.

func test_traces() -> String:
	var g = Golden.load_json("combat_sim")
	var scr_ids := ["bencao", "escudo_arcano", "maos_flamejantes", "imobilizar_pessoa", "curar_ferimentos", "ajuda", "protecao_contra_a_morte", "aceleracao"]
	var idx := 0
	for sc in g.scenarios:
		var extra: Array = []
		if sc.get("scrolls", false):
			for i in scr_ids:
				extra.append(Scrolls.by_id(i).card)
		var ups: Variant = sc.get("upgrades")
		var trace := CombatDriver.run_fight(sc.cid, int(sc.level), sc.enemies, int(sc.seed), int(sc.turns), ups, extra)
		var want: Array = sc.trace
		if trace.size() != want.size():
			return "cenário %d (%s nv%d %s seed %d): %d passos, esperado %d" % [idx, sc.cid, sc.level, str(sc.enemies), sc.seed, trace.size(), want.size()]
		for i in range(want.size()):
			var d := Golden.diff(Golden.plain(trace[i]), want[i], "cenário %d (%s nv%d %s seed %d) passo %d" % [idx, sc.cid, sc.level, str(sc.enemies), sc.seed, i], 1e-9)
			if d != "":
				return d
		idx += 1
	return ""
