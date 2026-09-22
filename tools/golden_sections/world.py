"""Vetores de paridade: mapas, missões, caminhada, exploração, eventos, grupo, coleção e elenco."""
import dataclasses


def P(x):
    """Serialização simples de resultados do core (cartas viram o nome; itens, o id; dataclasses, dicts)."""
    from game.core.cards import Card
    from game.core.items import ItemDef
    if isinstance(x, Card):
        return x.name
    if isinstance(x, ItemDef):
        return x.id
    if dataclasses.is_dataclass(x) and not isinstance(x, type):
        d = {f.name: P(getattr(x, f.name)) for f in dataclasses.fields(x)}
        for extra in ("critical", "total_bonus", "needed", "chance_text", "check_label"):
            if extra not in d and hasattr(type(x), extra):
                d[extra] = P(getattr(x, extra))
        return d
    if isinstance(x, (list, tuple)):
        return [P(v) for v in x]
    if isinstance(x, (set, frozenset)):
        return sorted(P(v) for v in x)
    if isinstance(x, dict):
        return {str(k): P(v) for k, v in x.items()}
    if x is None or isinstance(x, (bool, int, float, str)):
        return x
    return str(x)


def _en(r):
    return r.make_enemies() if (r.enemy_factory or r.group_factory) else []


@section("world")
def world():
    import random
    from game.core import missions, gridmap, walker, walk_rules, dungeon_m1, dungeon_m2
    out = {"maps": {"m1": dungeon_m1.ascii_map(), "m2": dungeon_m2.ascii_map()}}
    out["missions"] = {mid: {"title": m.title, "cast": list(m.cast), "requires": list(m.requires), "edges": [list(e) for e in m.edges], "start": m.start,
                              "rooms": [[r.id, r.name, r.kind, r.asset_id, r.optional, r.is_boss, r.xp, r.reward_tier, list(r.fog) if r.fog else None,
                                         [e.name for e in _en(r)], [e.hp for e in _en(r)]] for r in m.rooms],
                              "completion_xp": m.completion_xp, "boss": m.boss_id, "event_ids": list(m.event_ids) if m.event_ids else None,
                              "event_rooms": list(m.event_rooms), "amb": [m.ambiente(i) for i in range(1, 8)], "hq": [m.exit_hq, m.briefing_hq],
                              "intro": [m.lore.room_intro(i) for i in range(1, 8)], "end": [m.lore.run_end(o) for o in ("vitoria", "derrota", "desistencia")],
                              "flavor": [m.lore.enemy_flavor(n) for n in ("Slime corrosivo", "Zumbi", "Zumbi")],
                              "index": [m.index_of(r.id) for r in m.rooms]} for mid, m in missions.MISSIONS.items()}
    out["unlock"] = [[m.id, missions.is_unlocked(m, c)] for m in missions.MISSIONS.values() for c in (set(), {"m1"})]
    out["fog"] = [missions.fog_for_backdrop(a) and list(missions.fog_for_backdrop(a)) for a in ("sala_2_cais", "sala_1_docas", "m2_sala_2_praca", "sala_6_ritual", None)]
    walks = []
    for mid, seed in (("m1", 1), ("m1", 2), ("m1", 3), ("m2", 4), ("m2", 5)):
        random.seed(seed)
        mission = missions.MISSIONS[mid]
        dg = mission.dungeon
        world_map = mission.make_world()
        grid = dg.build()
        w = walker.Walker(grid, dg.START[0], dg.START[1], dg.START[2])
        w.gate = walk_rules.make_gate(world_map, mission.rooms_by_id, dg)
        cmds = ["forward"] * 6 + ["turn_left", "forward", "backward", "strafe_left", "strafe_right", "turn_right", "about_face"]
        seq = [random.choice(["forward", "forward", "forward", "backward", "turn_left", "turn_right", "strafe_left", "strafe_right", "about_face"]) for _ in range(140)]
        steps = []
        for i, c in enumerate(seq):
            evs = getattr(w, c)()
            steps.append([c, [[type(e).__name__, *dataclasses.astuple(e)] for e in evs], w.x, w.y, w.facing, w.room, w.block_reason])
            if i % 25 == 24:
                for rid in (2, 3, 5)[: (i // 25) % 3 + 1]:
                    world_map.clear(rid)
        walks.append({"mid": mid, "seed": seed, "cmds": seq, "steps": steps, "opened": sorted(list(w.opened)), "visited": len(w.visited),
                      "open_checks": [[x, y, w.is_open(x, y)] for x in range(0, 12) for y in (10, 12)]})
    out["walks"] = walks
    wm = missions.MISSIONS["m1"].make_world()
    log = [wm.neighbors(2), wm.neighbors(1), wm.can_move_to(2), wm.can_move_to(3)]
    wm.move_to(2)
    wm.move_to(4)
    try:
        wm.move_to(1)
        log.append("moved")
    except ValueError:
        log.append("err")
    wm.clear()
    wm.clear(2)
    log += [sorted(wm.visible()), wm.visible_edges(), wm.is_cleared(4), wm.is_cleared(5), wm.current]
    out["worldmap"] = log
    ev = []
    for mid in ("m1", "m2"):
        dg = missions.MISSIONS[mid].dungeon
        random.seed(9)
        for room in dg.ROOM_RECTS:
            ev.append([mid, room, list(dg.event_cell(room, random))])
    out["event_cells"] = ev
    return out


def _mk_player(cid, level, seed, armor=None, items=(), upgrades=None):
    import random
    from game.core import characters as ch
    from game.core.state import Player
    random.seed(seed)
    p = Player.for_character(ch.CHARACTERS[cid], level=level, upgrades=upgrades, armor=armor)
    for it in items:
        p.backpack.add(it)
    return p


@section("exploration")
def exploration_section():
    import random
    from game.core import exploration as ex, missions, equipment as eq, items as it, temporaries as tmp
    out = {"checks": [], "prev": [], "reroll": [], "reward": []}
    armors = {"none": None, "cota": eq.COTA, "placa": eq.PLACA}
    seed = 0
    for mid, mission in missions.MISSIONS.items():
        for room, sit in mission.situations.items():
            for oi, opt in enumerate(sit.options):
                for cid, level in (("durvall", 1), ("durvall", 5), ("maelor", 3), ("brook", 5), ("kayron", 2)):
                    for aname, armor in armors.items():
                        seed += 1
                        p = _mk_player(cid, level, seed, armor, [it.LUPA, it.FAIXA])
                        if oi % 2:
                            p.backpack.equip(it.LUPA)
                        if opt.attribute is None:
                            out["prev"].append([mid, room, oi, cid, level, aname, None])
                            continue
                        prev = ex.check_preview(p, opt)
                        random.seed(seed + 1000)
                        chk = ex.resolve_check(p, opt)
                        rec = {"mid": mid, "room": room, "oi": oi, "cid": cid, "level": level, "armor": aname, "chk": P(chk), "prev": P(prev),
                               "can_luck": ex.can_use_luck(p, chk)}
                        if rec["can_luck"]:
                            rec["luck"] = P(ex.reroll_with_luck(p, opt, chk))
                            rec["luck_left"] = p.luck
                        random.seed(seed + 2000)
                        app = ex.apply_result(p, opt, chk, offer=(seed % 2 == 0))
                        rec["applied"] = P(app)
                        rec["snap"] = [p.hp, len(p.hand), len(p.draw_pile), len(p.discard), len(p.exhausted), [i.id for i in p.backpack.bag],
                                       p.backpack.accessory.id if p.backpack.accessory else None]
                        if app.pending is not None:
                            budget = tmp.TempBudget()
                            random.seed(seed + 3000)
                            settled = ex.settle_reward(p, app, accept=(seed % 3 != 0), budget=budget, rng=random.Random(seed))
                            rec["settled"] = P(settled)
                            rec["budget"] = [budget.cards, budget.items]
                        out["checks"].append(rec)
    for o in (True, False):
        for oc in (ex.Outcome("x", xp=3, draw=2, item="lupa_de_latao"), ex.Outcome("y", xp=0)):
            out["reward"].append(ex.reward_kinds(oc))
    out["fights"] = {str(k): list(v) for k, v in ex.EXPLORATION_FIGHTS.items()}
    return out


@section("events")
def events_section():
    import random
    from game.core import events as evs, event_plan as plan, missions, event_data
    from game.core.event_plan import EventInstance
    out = {"chance": [[p, plan.chance(p)] for p in range(0, 5)], "next": [plan.next_pity(2, True), plan.next_pity(2, False)]}
    plans = []
    for pity in (0, 1, 2, 3):
        for seed in range(1, 13):
            rng = random.Random(seed)
            m = missions.MISSIONS["m1" if seed % 2 else "m2"]
            evd = [e for e in evs.EVENTS if not m.event_ids or e.id in m.event_ids]
            pl = plan.roll_plan(pity, evd, rng, tuple(m.event_rooms), always=(seed % 5 == 0))
            plans.append({"pity": pity, "seed": seed, "mid": m.id, "plan": [[i.event_id, i.room] for i in pl], "next": rng.random()})
    out["plans"] = plans
    states = []
    situ = []
    for seed in range(1, 40):
        for eid in ("bau", "mercador", "viajante", "altar", "fenda", "frasco"):
            room = 2 + seed % 5
            inst = EventInstance(eid, room)
            rng = random.Random(seed)
            inst.state = evs.roll_state(inst, rng)
            states.append([eid, room, seed, P(inst.state)])
            random.seed(seed)
            players = [_mk_player("brook" if seed % 3 == 0 else "durvall", 5 if seed % 2 else 1, seed)]
            if seed % 4 == 0:
                players[0].dishonored = True
            if seed % 7 == 0:
                players[0].hand.append(missions and __import__("game.core.cards", fromlist=["x"]).LOCALIZAR_CRIATURA)
            s = evs.build_situation(inst, players)
            situ.append([eid, room, seed, {"title": s.title, "lines": list(s.lines), "opts": [[o.label, o.check_label, o.dc, o.attribute, o.auto, o.cost_gold, P(o.success), P(o.failure), P(o.critical)] for o in s.options],
                                           "state": P(inst.state)}])
    out["states"] = states
    out["situations"] = situ
    fx = []
    inst = EventInstance("bau", 4)
    inst.state = {"mimic": True, "locked": False, "gold": 20, "reward": "", "revealed": False, "examined": False}
    fx.append([evs.apply_effect(inst, "reveal"), P(inst.state)])
    inst = EventInstance("mercador", 4)
    inst.state = {"offer": [1], "sold": [], "rerolls": 0}
    random.seed(4)
    fx.append([evs.apply_effect(inst, "sold:2"), evs.apply_effect(inst, "sold:0"), evs.apply_effect(inst, ""), evs.apply_effect(inst, "nada"), P(inst.state)])
    out["effects"] = fx
    mim = []
    for mid in ("m1", "m2"):
        missions.set_current(mid)
        for room in (1, 2, 3, 4, 5):
            m = evs.make_mimic(EventInstance("bau", room))
            mim.append([mid, room, m.hp, m.ca, m.cam, m.xp])
    missions.set_current("m1")
    out["mimic"] = mim
    out["mimic_gold"] = evs.mimic_gold(EventInstance("bau", 2)), evs.mimic_gold(inst)
    return out
