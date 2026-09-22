"""Vetores de paridade do combate: uma simulação determinística (semente + política fixa) que exercita cartas, Corrente,
acerto, dano, reações, Cópia, Guarda, pergaminhos e o turno inimigo. O driver espelha `tests/support/combat_driver.gd`."""
import dataclasses


def plain(x):
    from game.core.cards import Card
    if isinstance(x, Card):
        return x.name
    if dataclasses.is_dataclass(x) and not isinstance(x, type):
        d = {f.name: plain(getattr(x, f.name)) for f in dataclasses.fields(x)}
        for extra in ("total", "crit", "fumble", "hit", "acertou", "total_reduction", "success"):
            if extra not in d and hasattr(type(x), extra):
                d[extra] = plain(getattr(x, extra))
        return d
    if isinstance(x, (list, tuple)):
        return [plain(v) for v in x]
    if isinstance(x, dict):
        return {str(k): plain(v) for k, v in x.items()}
    if isinstance(x, bool) or x is None or isinstance(x, (int, float, str)):
        return x
    return str(x)


def snap(player, enemies):
    c = player.combo
    return {"hp": player.hp, "max_hp": player.max_hp, "ca": player.ca, "cam": player.cam, "streak": c.streak, "boost": c.boost,
            "mystic": c.mystic_power, "guard": player.guard, "dish": player.dishonored, "clone": player.clone_hp,
            "hand": [x.name for x in player.hand], "draw": len(player.draw_pile), "disc": len(player.discard),
            "exh": len(player.exhausted), "spent": len(player.spent_class), "luck": player.luck,
            "en": [[e.name, e.hp, e.stunned, e.stun_left, e.ca_penalty, e.cam_penalty, e.marked_bonus, e.next_attack_reduction, e.thunder_mark] for e in enemies]}


def run_fight(character_id, level, enemy_names, seed, turns, deck_names=None, extra_cards=(), upgrades=None):
    import random
    from game.core import characters as ch, combat as cb, enemies as en, turn as tn, cards as cd, scrolls as sc
    random.seed(seed)
    facs = {"guardiao": en.guardiao_verdadeiro, "slime": en.slime_corrosivo, "cultista": en.cultista_adaga, "cajado": en.cultista_cajado,
            "zumbi": en.zumbi, "sacerdote": en.sacerdote_mente_derretida, "mimico": lambda: en.mimico(12, 11, 10), "copia": en.guardiao_copia}
    enemies = [facs[n]() for n in enemy_names]
    player = ch.CHARACTERS[character_id] and __import__("game.core.state", fromlist=["Player"]).Player.for_character(
        ch.CHARACTERS[character_id], level=level, deck_names=deck_names, upgrades=upgrades)
    if extra_cards:
        player.add_scrolls(list(extra_cards))
    trace = [["start", snap(player, enemies)]]
    for t in range(turns):
        alive = [e for e in enemies if e.is_alive()]
        if not alive or not player.is_alive():
            break
        turn = tn.TurnState()
        turn.actions_available += player.take_extra_actions()
        guard_loops = 0
        while guard_loops < 12:
            guard_loops += 1
            alive = [e for e in enemies if e.is_alive()]
            if not alive:
                break
            playable = [c for c in player.hand if turn.can_play(c)]
            if not playable:
                break
            card = playable[0]
            player.hand.remove(card)
            target = alive[0]
            entry = {"card": card.name}
            kind = card.kind
            if kind == "ataque":
                if card.area:
                    hits = [cb.player_attack_hit(card, player, e) for e in alive]
                    results = cb.resolve_area_attack(card, player.combo, hits)
                    for e, r in zip(alive, results):
                        if r.acertou:
                            e.hp -= r.total
                    entry["res"] = plain(results)
                    if any(r.acertou for r in results):
                        turn.hit_this_turn = True
                else:
                    hit = cb.player_attack_hit(card, player, target)
                    r = cb.resolve_attack(card, player.combo, hit)
                    eff = cb.apply_card_effects(card, r, player, target)
                    stun = None
                    if r.acertou:
                        target.hp -= r.total
                        turn.hit_this_turn = True
                        stun = cb.roll_stun_check(card, player, target)
                        if stun is not None:
                            if stun.success:
                                target.try_stun()
                            else:
                                player.combo.break_chain()
                        if card.drain_frac:
                            player.heal(int(r.total * card.drain_frac))
                    entry["res"] = plain(r)
                    entry["eff"] = plain(eff)
                    entry["stun"] = plain(stun)
            elif kind == "cura":
                mod = player.modifier_of(card.modifier_attr) if card.modifier_attr else 0
                r = cb.resolve_heal(card, player.combo, mod, player)
                healed = player.heal_clone(r.total, revive=True) if card.heals_clone else player.heal(r.total)
                entry["res"] = plain(r)
                entry["healed"] = healed
            elif kind == "controle":
                r = cb.resolve_control(card, player.combo)
                for e in (alive if card.area else [target]):
                    e.next_attack_reduction += r.reduction
                entry["res"] = plain(r)
            elif kind == "surto":
                entry["res"] = cb.resolve_surge(card, player.combo)
            elif kind == "atordoamento":
                cb.resolve_stun(card, player.combo, target)
            elif kind == "canalizar":
                entry["res"] = cb.resolve_channel(card, player.combo, player)
            elif kind == "protecao":
                entry["res"] = cb.resolve_protect(card, player.combo, player)
            elif kind == "localizar":
                entry["res"] = plain(cb.resolve_locate(card, player.combo, target))
            elif kind == "enfraquecer":
                entry["res"] = cb.resolve_weaken(card, player.combo, target)
            elif kind == "comunhao":
                cb.resolve_communion(card, player.combo)
                top = player.peek_top(card.reveals)
                entry["top"] = [x.name for x in top]
                if top:
                    player.hand.append(top[0])
                    player.draw_pile.remove(top[0])
            elif kind == "magia":
                entry["res"] = plain(cb.resolve_scroll_buff(card, player.combo, player))
            else:
                cb.resolve_equip(card, player.combo)
            turn.spend_for(card)
            if card.single_use:
                player.exhausted.append(card)
            elif card.class_ability:
                player.spent_class.append(card)
            else:
                player.discard.append(card)
            for e in enemies:
                if e.script is not None:
                    spawned = e.script.check(e)
                    if spawned:
                        enemies.extend(spawned)
                        entry["spawn"] = len(spawned)
            entry["snap"] = snap(player, enemies)
            trace.append(["play", entry])
            if turn.should_end:
                break
        # turno inimigo
        for e in [x for x in enemies if x.is_alive()]:
            if not player.is_alive():
                break
            th = cb.resolve_thunder(e)
            if th is not None:
                trace.append(["thunder", plain(th)])
                if th.killed:
                    continue
            if e.stunned:
                e.consume_stun()
                trace.append(["stunned", e.name])
                continue
            e.tick_stun_immunity()
            pending = cb.roll_enemy_attack(player, e, True)
            reaction = None
            rt = tn.TurnState()
            for c in list(player.hand):
                if rt.can_react(c, pending.kind, pending.hit is not None):
                    reaction = c
                    break
            if reaction is not None:
                player.hand.remove(reaction)
                player.discard.append(reaction)
            player.clone_targeted = player.clone_alive and (len(trace) % 2 == 0)
            res = cb.resolve_enemy_attack(player, e, pending, reaction)
            entry = {"pending": plain(pending), "res": plain(res)}
            if e.grapples and res.acertou and res.damage >= 0:
                entry["grapple"] = list(cb.resolve_grapple(player, e))
            entry["snap"] = snap(player, enemies)
            trace.append(["enemy", entry])
            if not player.is_alive():
                break
        player.start_turn()
        if player.is_alive():
            player.draw()
            player.discard_excess()
            player.combo.streak = player.combo.streak
        trace.append(["end", snap(player, enemies)])
    return trace


@section("combat_sim")
def combat_sim():
    from game.core import scrolls as sc
    scenarios = []
    plan = [("durvall", 1, ["guardiao"]), ("durvall", 5, ["guardiao"]), ("maelor", 1, ["copia"]), ("maelor", 5, ["slime", "cultista"]),
            ("sylas", 1, ["cajado"]), ("sylas", 5, ["guardiao"]), ("kayron", 1, ["zumbi", "cultista"]), ("kayron", 5, ["guardiao"]),
            ("brook", 1, ["sacerdote"]), ("brook", 5, ["mimico"]), ("durvall", 3, ["sacerdote"]), ("brook", 4, ["slime", "slime", "cultista"])]
    seeds = (1, 2, 3, 4, 5)
    for cid, lvl, ens in plan:
        for seed in seeds:
            scenarios.append({"cid": cid, "level": lvl, "enemies": ens, "seed": seed, "turns": 8,
                              "trace": run_fight(cid, lvl, ens, seed, 8)})
    # com pergaminhos, upgrades e a coleção inicial
    scr = [sc.BY_ID[i].card for i in ("bencao", "escudo_arcano", "maos_flamejantes", "imobilizar_pessoa", "curar_ferimentos", "ajuda", "protecao_contra_a_morte", "aceleracao")]
    for cid in ("durvall", "maelor", "brook"):
        for seed in (11, 12, 13):
            scenarios.append({"cid": cid, "level": 5, "enemies": ["guardiao"], "seed": seed, "turns": 6, "scrolls": True,
                              "upgrades": {"forca_bruta": 3, "vitalidade": 2, "mao_cheia": 1},
                              "trace": run_fight(cid, 5, ["guardiao"], seed, 6, upgrades={"forca_bruta": 3, "vitalidade": 2, "mao_cheia": 1}, extra_cards=scr)})
    return {"scenarios": scenarios}
