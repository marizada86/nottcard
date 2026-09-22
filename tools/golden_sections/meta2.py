"""Vetores de paridade: coleção, loja, conquistas, layouts, elenco e grupo."""
import dataclasses


def Q(x):
    from game.core.cards import Card
    from game.core.items import ItemDef
    if isinstance(x, Card):
        return x.name
    if isinstance(x, ItemDef):
        return x.id
    if dataclasses.is_dataclass(x) and not isinstance(x, type):
        d = {f.name: Q(getattr(x, f.name)) for f in dataclasses.fields(x)}
        return d
    if isinstance(x, (list, tuple)):
        return [Q(v) for v in x]
    if isinstance(x, (set, frozenset)):
        return sorted(Q(v) for v in x)
    if isinstance(x, dict):
        return {str(k): Q(v) for k, v in x.items()}
    if x is None or isinstance(x, (bool, int, float, str)):
        return x
    return str(x)


def save_dump(st):
    return Q(st.to_dict())


@section("collection")
def collection_section():
    import random
    from game.core import collection as col, characters as ch, progress as pr
    out = {"pools": {r: [c.name for c in col.pool(r)] for r in ("comum", "incomum", "rara")}, "catalog": list(col.card_catalog())}
    out["starting"] = []
    for seed in range(1, 9):
        out["starting"].append({"seed": seed, "deck": [c.name for c in col.starting_deck(random.Random(seed))],
                                "extras": [c.name for c in col.starting_extras(random.Random(seed))],
                                "boss": [c.name for c in col.boss_offer("guardiao_verdadeiro", random.Random(seed))],
                                "boss2": [c.name for c in col.boss_offer("sacerdote_mente_derretida", random.Random(seed), 2)],
                                "boss3": [c.name for c in col.boss_offer("nada", random.Random(seed))]})
    coll = list(col.CORE_DECK) + ["Golpe", "Aparar", "Aparar", "Aparar", "Aparar", "Chama Menor", "Névoa Fria", "Surto de Ação", "Golpe Furtivo", "Nada", "Golpe Perfurante"]
    sig = {}
    for cid, c in ch.CHARACTERS.items():
        sig[cid] = [[x.name for x in col.signature_cards(c, l)] for l in (1, 3, 5)] + [[x.name for x in col.run_deck(c, coll, 4)]]
    out["sig"] = sig
    out["problems"] = [col.deck_problems(d) for d in ([], list(col.CORE_DECK), coll, ["Golpe"] * 5 + ["Golpe Furtivo"] * 2, ["Poção de Cura"] * 3 + ["Chama Menor"] * 4)]
    out["default"] = [col.default_deck(coll), col.default_deck(list(col.CORE_DECK)), col.default_deck(coll * 3)]
    out["sorted"] = col.sorted_by_rarity(coll)
    out["suggest"] = [col.suggest_deck(coll, list(col.CORE_DECK), color) for color in ("Vermelho", "Amarelo", "Azul", "Roxo")]
    out["migrated"] = col.migrated_collection()
    d = col.Deck(list(col.CORE_DECK))
    dl = [d.full, d.locked("Golpe"), d.locked("Aparar"), d.add("Aparar", coll), d.add("Aparar", coll), d.add("Golpe", coll), d.remove("Golpe"), d.remove("Aparar"),
          d.remove("Nada"), d.swap("Aparar", "Névoa Fria", coll), d.swap("Golpe", "Aparar", coll), d.swap("Chama Menor", "Nada", coll), d.names, len(d)]
    out["deck_ops"] = dl
    flows = []
    for seed in (1, 2, 3):
        st = pr.SaveState()
        ch1 = col.ensure_collection(st, random.Random(seed))
        d0 = save_dump(st)
        ch2 = col.ensure_collection(st, random.Random(seed))
        col.grant_cards(st, [col.card_catalog()["Aparar"], col.card_catalog()["Golpe Perfurante"]])
        offer1 = col.offer_boss_reward(st, random.Random(seed))
        offer2 = col.offer_boss_reward(st, random.Random(seed))
        oc = [c.name for c in col.offered_cards(st)]
        picked = col.pick_offer(st, oc[1]) if oc else None
        picked2 = col.pick_offer(st, "nada")
        flows.append([ch1, d0, ch2, offer1, offer2, oc, picked.name if picked else None, picked2, save_dump(st)])
    st = pr.SaveState()
    st.progress["durvall"] = pr.Progress(level=2, xp=120)
    st.decks = [list(col.CORE_DECK) + ["Golpe"] * 14]
    st.collection = ["Golpe", "Chama Menor", "Poção de Cura", "Poção de Cura"]
    flows.append([col.ensure_core(st), save_dump(st)])
    st = pr.SaveState()
    st.progress["durvall"] = pr.Progress(level=2, xp=120)
    flows.append([col.ensure_collection(st, random.Random(4)), save_dump(st)])
    out["flows"] = flows
    return out


@section("shop_meta")
def shop_meta():
    import random
    from game.core import shop, achievements as ach, layout_unlocks as lu, roster, progress as pr, equipment as eq, missions
    out = {"items": [[i.id, i.nome, i.preco, i.titulo_requerido, i.tipo, i.unique, i.efeito] for i in shop.SHOP_ITEMS]}
    st = pr.SaveState(coins=2000)
    log = []
    for iid in ("forca_bruta", "forca_bruta", "vitalidade", "mao_maior", "arma_espada", "arma_espada", "armadura_couro", "kayron", "brook", "nada", "mao_cheia", "mao_cheia", "mao_cheia"):
        p = shop.buy(st, iid)
        log.append([iid, p.ok, p.reason, p.item.id if p.item else None, p.level, st.coins, sorted(st.owned), dict(st.upgrades), dict(st.equipment_units),
                    sorted(st.unlocked_characters)])
    out["buys"] = log
    avail = []
    for coins in (0, 150, 5000):
        for ach_set in (set(), {"dupla"}, {"fechadura", "concluir_m2"}, {"dupla", "concluir_m2", "m2_em_dupla", "fechadura"}):
            s2 = pr.SaveState(coins=coins, achievements=set(ach_set), roster_rules=True, unlocked_characters={"durvall"})
            avail.append([coins, sorted(ach_set), [[i.id, shop.availability(s2, i), shop.can_afford(s2, i), shop.missing_coins(s2, i), shop.price(s2, i), shop.owns(s2, i.id)] for i in shop.SHOP_ITEMS]])
    out["avail"] = avail
    out["titles"] = [[t, [i.id for i in shop.items_for_title(t)], shop.item_for_title(t).id if shop.item_for_title(t) else None] for t in ("fechadura", "dupla", "nada")]
    st = pr.SaveState(coins=10)
    st.owned = {"neon", "pergaminho", "baralho_2", "arma_adaga"}
    st.decks = [["a"], ["b"]]
    st.active_deck = 1
    st.pending_offer = {"source": "pacote", "cards": ["Golpe"]}
    out["migrate"] = [shop.migrate_removed_items(st), save_dump(st), shop.migrate_removed_items(st)]
    st = pr.SaveState()
    shop.grant_everything(st)
    out["grant_all"] = save_dump(st)
    # conquistas
    ach_rows = []
    for outcome in ("vitoria", "derrota"):
        for mid in ("m1", "m2"):
            for party in (1, 2):
                for crits, ones, big in ((0, 0, 0), (3, 3, 30)):
                    stt = pr.RunStats(mission_id=mid, party_size=party, crits=crits, natural_ones=ones, max_hit=big)
                    for setup in range(4):
                        s2 = pr.SaveState()
                        if setup == 1:
                            s2.hqs_seen = {"hq_002"}
                            s2.progress = {c: pr.Progress(level=5) for c in ("durvall", "maelor", "sylas", "kayron", "brook")}
                        if setup == 2:
                            s2.missions_completed = {"m2"}
                            s2.progress = {"durvall": pr.Progress(level=4)}
                        if setup == 3:
                            s2.roster_rules = True
                            s2.unlocked_characters = {"durvall", "maelor"}
                            s2.progress = {"durvall": pr.Progress(level=5), "maelor": pr.Progress(level=5)}
                        ev = ach.evaluate(s2, outcome, stt)
                        ach_rows.append([outcome, mid, party, crits, ones, big, setup, [a.id for a in ev]])
    out["ach"] = ach_rows
    s3 = pr.SaveState(achievements={"fechadura", "dupla", "nada"})
    out["benefit"] = [[k, ach.has_benefit(s3, k)] for k in (ach.BONUS_HP, ach.GROUP_2, ach.MULLIGAN, ach.DAMAGE_BONUS)]
    from game.core import collection as _col
    s4 = pr.SaveState()
    s4.collection = list(_col.CORE_DECK)
    s4.decks = [list(_col.CORE_DECK)]
    ea = ach.evaluate(pr.SaveState(progress={"durvall": pr.Progress(level=4)}), "derrota", pr.RunStats())
    out["grant_cards"] = [[a.id for a in ea], ach.grant_cards(s4, ea), save_dump(s4)]
    s5 = pr.SaveState()
    ach.unlock_all(s5)
    out["ach_all"] = sorted(s5.achievements)
    out["ach_data"] = [[a.id, a.name, a.description, a.benefit, a.benefit_key, list(a.grants)] for a in ach.ACHIEVEMENTS]
    # layouts
    lay = []
    for kills in (0, 9, 10, 25, 30, 99):
        s6 = pr.SaveState(progress={"durvall": pr.Progress(kills=kills), "brook": pr.Progress(kills=kills // 2)})
        ev = lu.evaluate(s6)
        s6.achievements = {u.achievement_id for u in ev[:2]}
        lay.append([kills, [u.layout_id for u in ev], lu.owned_layouts(s6), [lu.missing_kills(s6, u) for u in lu.UNLOCKS[:6]], lu.kills_of(s6, "durvall"), lu.kills_of(s6, "x")])
    out["layouts"] = lay
    out["layout_data"] = [[u.layout_id, u.achievement_id, u.class_id, u.character_id, u.class_name, u.grade, u.kills_needed, u.name, u.available, u.description] for u in lu.UNLOCKS]
    s7 = pr.SaveState()
    lu.unlock_all(s7)
    out["layout_all"] = sorted(s7.achievements)
    # elenco
    rr = []
    m1, m2 = missions.MISSIONS["m1"], missions.MISSIONS["m2"]
    for achs in (set(), {"dupla"}, {"dupla", "concluir_m2"}, {"dupla", "concluir_m2", "m2_em_dupla", "trio"}):
        for unl in (set(), {"durvall"}, {"durvall", "maelor", "brook"}):
            for rules in (True, False):
                for done in (set(), {"m1"}):
                    s8 = pr.SaveState(achievements=set(achs), unlocked_characters=set(unl), roster_rules=rules, missions_completed=set(done))
                    rr.append([sorted(achs), sorted(unl), rules, sorted(done), roster.needs_starter(s8), roster.party_limit(s8), roster.group_hint(s8), roster.open_slots(s8),
                               roster.bought_starters(s8), [roster.can_buy(s8, c) for c in ("kayron", "durvall", "brook", "x")], [roster.buy_hint(s8, c) for c in ("kayron", "brook")],
                               [roster.has_character(s8, c) for c in ("durvall", "sylas")], [[roster.can_play(m, s8, c), roster.why_not(m, s8, c)] for m in (m1, m2) for c in ("durvall", "brook")],
                               [list(roster.can_field(m1, s8, ids)) for ids in ([], ["durvall"], ["durvall", "maelor"], ["durvall", "maelor", "sylas", "kayron"], ["brook"])]])
    out["roster"] = rr
    s9 = pr.SaveState(roster_rules=True, unlocked_characters=set())
    out["starter"] = [roster.needs_starter(s9), roster.choose_starter(s9, "brook"), roster.choose_starter(s9, "sylas"), roster.choose_starter(s9, "kayron"), sorted(s9.unlocked_characters)]
    return out


@section("party")
def party_section():
    import random
    from game.core import party as pt, characters as ch, cards as cd, combat as cb, enemies as en
    from game.core.state import Player
    out = []
    for seed in range(1, 25):
        random.seed(seed)
        ids = [("durvall", "sylas", "kayron"), ("maelor", "brook"), ("sylas",)][seed % 3]
        players = [Player.for_character(ch.CHARACTERS[i], level=1 + seed % 5) for i in ids]
        party = pt.Party(players)
        rec = {"seed": seed, "ids": list(ids)}
        players[0].grappled = seed % 4 == 0
        players[-1].extra_actions_next = seed % 3
        party.new_round()
        rec["round"] = [[m.turn.actions_available, m.turn.bonus_available] for m in party.members] + [party.active]
        if seed % 5 == 0:
            players[0].hp = 0
        if seed % 6 == 0 and len(players) > 1:
            players[1].hp = 0
            players[1].dead = True
        rec["query"] = [len(party.alive_members()), len(party.downed_members()), len(party.dead_members()), party.all_down, party.first_alive(),
                        [party.activate(i) for i in range(-1, 4)], party.active, party.round_done(), party.next_with_actions(), party.index_of(players[-1]), party.size]
        enemy = en.guardiao_verdadeiro() if seed % 2 else en.sacerdote_mente_derretida()
        for _ in range(seed % 4):
            enemy.choose_action()
        targets = []
        for _ in range(6):
            t = party.choose_target(enemy)
            targets.append([party.index_of(t.player), [p.clone_targeted for p in players]])
        rec["targets"] = targets
        rec["attack_targets"] = [[party.index_of(m.player) for m in party.attack_targets(enemy)] for _ in range(4)]
        heal = cd.build_maelor_deck()[5]
        caster = party.members[0]
        players[-1].hp = max(1, players[-1].hp - 3)
        res = []
        for tgt in party.members:
            try:
                r, healed, raised = party.heal_ally(caster, tgt, heal)
                res.append([True, r.total, healed, raised, tgt.player.hp])
            except pt.AllyHealRefused:
                res.append([False])
        rec["heal_targets"] = [[party.members.index(m) for m in party.heal_targets(caster, c)] for c in (heal, cd.build_starting_deck()[8])]
        rec["heal_res"] = res
        rec["turn_after"] = [[m.turn.actions_available, m.turn.bonus_available] for m in party.members]
        out.append(rec)
    bad = None
    try:
        pt.Party([])
    except ValueError as e:
        bad = str(e)
    return {"parties": out, "bad": bad}
