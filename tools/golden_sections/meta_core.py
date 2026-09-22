"""Vetores de paridade: personagens, upgrades, economia, progresso, equipamento, pergaminhos, mochila, save."""


@section("meta_core")
def meta_core():
    from game.core import characters as ch, upgrades as up, economy as eco, progress as pr, equipment as eq, scrolls as sc, items as it
    out = {}
    chars = {}
    for cid, c in ch.CHARACTERS.items():
        chars[cid] = {
            "max_hp": c.max_hp, "hp": [c.hp_at(l) for l in range(1, 6)],
            "attrs": [c.attributes_at(l) for l in range(1, 6)],
            "hooks": [sorted(c.hooks_at(l)) for l in range(1, 6)],
            "passives": [[list(p) for p in c.unlocked_passives(l)] for l in range(1, 6)],
            "rewards": [list(c.reward_texts(l)) for l in range(1, 6)],
            "deck_at": [[x.name for x in c.deck_at(l)] for l in range(1, 6)],
            "catalog": [[x.name, lv] for x, lv in c.catalog()],
            "colormod": {col: c.color_modifier(col) for col in ("Vermelho", "Amarelo", "Azul", "Roxo")},
            "chain": {x.name: [c.counts_for_chain(x), c.hit_attribute(x) or ""] for x in c.deck_at(5)},
        }
    out["chars"] = chars
    out["char_ids"] = list(ch.CHARACTERS)
    ups = [{}, {"forca_bruta": 3}, {"forca_bruta": 9, "vitalidade": 2, "mao_maior": 2, "ganancia": 1, "sorte": -3, "x": 4}, None]
    out["upgrades"] = [{
        "levels": {u.id: up.level(d, u.id) for u in up.UPGRADES}, "maxed": {u.id: up.is_maxed(d, u.id) for u in up.UPGRADES},
        "cost": {u.id: (-1 if up.cost_of_next(d, u.id) is None else up.cost_of_next(d, u.id)) for u in up.UPGRADES},
        "mult": up.damage_multiplier(d), "hp": up.bonus_hp(d), "hand": up.hand_limit(d), "extra_hand": up.extra_hand(d),
        "rer": up.rerolls(d), "luck": up.extra_luck(d), "bag": up.extra_bag_slots(d),
        "greed": [up.coins_with_greed(d, g) for g in (-1, 0, 1, 7, 33, 100)]} for d in ups]
    rows = []
    for d in ups:
        for cm in (-2, 0, 1, 3):
            for outcome in ("vitoria", "derrota", "desistencia"):
                st = eco.settle_coins(37, 25, outcome, d, cm)
                rows.append([cm, outcome, st.xp_coins, st.bag_coins, st.multiplier, st.charisma_pct, st.greed_pct, st.total])
    out["economy"] = rows
    led = pr.RunLedger(mission_gold=10)
    save = pr.SaveState(coins=5)
    out["spend"] = [eco.spend_gold(led, save, 0), eco.spend_gold(led, save, 12), [led.mission_gold, save.coins],
                    eco.spend_gold(led, save, 4), [led.mission_gold, save.coins], eco.spendable_gold(led, save)]
    out["xp_levels"] = [[pr.xp_for_level(l) for l in range(0, 8)], [pr.level_for_xp(x) for x in (0, 99, 100, 349, 350, 950, 1949, 1950, 99999)]]
    prog = pr.Progress()
    ups_l = []
    for amt in (50, 60, 300, 700, 5000, 5000):
        row = [[u.level, list(u.rewards)] for u in prog.add_xp(amt, lambda l: (f"r{l}",))]
        nt = prog.next_threshold()
        ups_l.append([row, prog.level, prog.xp, prog.fraction_to_next(), -1 if nt is None else nt, prog.at_cap])
    out["progress"] = ups_l
    led = pr.RunLedger(xp_mult=2)
    led.add("a", 30)
    led.add("b", 0)
    led.add("c", 45)
    led.add_gold(7)
    stats = pr.RunStats()
    p2 = pr.Progress(level=1, xp=90)
    res = pr.settle_run(p2, led, "derrota", stats, "durvall", lambda l: (f"x{l}",))
    out["settle"] = [res.outcome, res.raw_xp, res.adjustment, res.gained, res.level_before, res.level_after, res.xp_before, res.xp_after,
                     [[u.level, list(u.rewards)] for u in res.level_ups], [[l.source, l.amount] for l in res.lines], led.total, led.mission_gold]
    out["apply_outcome"] = [pr.apply_outcome(g, o) for g in (0, 1, 7, 45) for o in ("vitoria", "derrota", "desistencia")]

    st = pr.SaveState()
    log = []
    log.append([eq.equip(st, "durvall", "arma_espada")])
    eq.add_unit(st, "arma_espada")
    eq.add_unit(st, "armadura_placa", 2)
    eq.add_unit(st, "arma_cetro")
    log.append([eq.equip(st, "durvall", "arma_espada"), eq.equip(st, "brook", "arma_espada"), eq.equip(st, "maelor", "arma_cetro"),
                eq.equip(st, "durvall", "arma_cetro"), eq.equip(st, "durvall", "armadura_placa"), eq.equip(st, "brook", "armadura_placa"),
                eq.equip(st, "sylas", "armadura_placa")])
    log.append([eq.units(st, "arma_espada"), eq.free_units(st, "armadura_placa"), eq.in_use_by(st, "armadura_placa"), list(eq.armor_deltas(st, "durvall")),
                {k: (v.id if v else "") for k, v in eq.equipped_of(st, "brook").items()}, eq.block_reason(st, "sylas", "armadura_placa"),
                eq.block_reason(st, "durvall", "arma_maca"), eq.block_reason(st, "maelor", "arma_espada")])
    log.append([eq.transfer(st, "durvall", "brook", "arma"), eq.transfer(st, "durvall", "maelor", "armadura"), eq.unequip(st, "durvall", "arma"),
                eq.unequip(st, "durvall", "arma"), [e.id for e in eq.owned_in_slot(st, "arma")], st.equipped])
    st2 = pr.SaveState(owned={"arma_adaga", "armadura_couro"})
    st2.equipped = {"durvall": {"arma": "arma_adaga"}}
    log.append([eq.migrate_units(st2), st2.equipment_units, eq.migrate_units(st2)])
    log.append([[e.id, e.users_text, e.stealth_text, e.effect_text] for e in eq.EQUIPMENT])
    out["equipment"] = log

    st = pr.SaveState()
    slog = []
    slog.append([sc.add(st, "durvall", "curar_ferimentos"), sc.add(st, "durvall", "nao_existe"), sc.add(st, "durvall", "bencao"),
                 sc.add(st, "durvall", "escudo_arcano"), sc.add(st, "durvall", "ajuda"), sc.is_full(st, "durvall")])
    slog.append([sc.consume(st, "durvall", sc.BY_ID["bencao"].card), sc.consume(st, "durvall", sc.BY_ID["bencao"].card), sc.stock_of(st, "durvall"),
                 [c.name for c in sc.stock_cards(st, "durvall")], sc.total_stock(st), sc.recipient(st, ["maelor", "durvall"]),
                 sc.recipient(st, ["durvall", "maelor"])])
    sc.add(st, "durvall", "bencao")
    o = sc.offer(2, random.Random(3))
    sc.set_offer(st, "durvall", o)
    slog.append([[s.id for s in o], st.pending_offer, [c.name for c in sc.offered_cards(st)]])
    slog.append([sc.pick(st, o[0].card.name), st.pending_offer, sc.swap_pending(st, "nada"), sc.swap_pending(st, st.scrolls["durvall"][0]),
                 st.pending_offer, st.scrolls])
    sc.set_offer(st, "maelor", sc.offer(1, random.Random(9)))
    slog.append([sc.decline_pending(st), st.pending_offer, sc.decline_pending(st), sc.pick(st, "x")])
    slog.append([sc.clear_all(st), st.scrolls, [s.id for s in sc.scrolls_of_tier(3)], sc.card_of("bencao").name, sc.card_of("Pergaminho de Bênção").name,
                 sc.card_of("nada") is None])
    out["scrolls"] = slog

    bp = it.Backpack.for_character(ch.DURVALL, 1)
    ilog = [bp.weapon.id, bp.slots, bp.add(it.LUPA), bp.add(it.FAIXA), bp.add(it.CARTA), bp.add(it.LUPA), bp.add(it.LUPA), bp.is_full,
            bp.equip(it.CARTA), bp.equip(it.LUPA), bp.accessory.id, [i.id for i in bp.bag], bp.equip(it.FAIXA), bp.accessory.id, [i.id for i in bp.bag],
            bp.check_bonus("forca"), bp.check_bonus("inteligencia"), bp.unequip(), bp.has_actions, bp.has_anything,
            [i.effect_text for i in it.ITEMS.values()], bp.take_pending_bonus(), bp.discard(it.CARTA), bp.discard(it.CARTA), bp.use(it.LUPA)]
    bp2 = it.Backpack()
    bp2.add(it.LUPA)
    ilog += [bp.give(it.FAIXA, bp2), bp.give(it.FAIXA, bp2), bp.give(it.LUPA, bp), [i.id for i in bp2.bag]]
    out["backpack"] = ilog

    raw = {"version": 1, "progress": {"durvall": {"level": 3, "xp": 400, "kills": 4}, "maelor": {"level": 9, "xp": 99999}}, "achievements": ["a", "b"],
           "hqs_seen": ["hq_001"], "card_layout": "x", "collection": ["Golpe", "Golpe"], "decks": [["Golpe"], []], "active_deck": 1, "coins": 40,
           "owned": ["arma_adaga"], "pending_offer": {"source": "pacote", "cards": ["A"], "for": "durvall", "lixo": 1}, "scrolls": {"durvall": ["bencao"]},
           "upgrades": {"vitalidade": 2, "sorte": 0}, "equipped": {"durvall": {"arma": "arma_adaga"}}, "event_pity": 3, "story_items": ["mapa"]}
    s1 = pr.SaveState.from_dict(raw)
    bad = []
    for patch in ({"version": 2}, {"progress": []}, {"coins": "x"}, {"decks": [[1]]}, {"pending_offer": {"source": 1, "cards": []}}, {"upgrades": {"a": True}},
                  {"achievements": [1]}, {"event_pity": 1.5}):
        try:
            pr.SaveState.from_dict({**raw, **patch})
            bad.append("ok")
        except ValueError as e:
            bad.append(str(e))
    out["save"] = {"raw": raw, "dict": s1.to_dict(), "again": pr.SaveState.from_dict(s1.to_dict()).to_dict(), "bad": bad,
                   "empty": pr.SaveState.from_dict({}).to_dict(), "has_progress": [s1.has_progress, pr.SaveState().has_progress]}
    return out
