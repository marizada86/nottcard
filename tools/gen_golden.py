"""Gera os vetores de paridade (golden) a partir do jogo Python de origem → tests/golden/*.json.

    python tools/gen_golden.py [--src PASTA_DO_NOTTCARD_AI]

Cada seção é uma função registrada em SECTIONS; specs de porte novas (F2+) adicionam a sua.
A origem fica congelada em v0.18.0 (PLAN-001).
"""
from __future__ import annotations

import argparse
import json
import random
import sys
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "tests" / "golden"
SECTIONS = {}


def section(name):
    def deco(fn):
        SECTIONS[name] = fn
        return fn
    return deco


@section("py_random")
def py_random():
    cases = []
    for seed in (0, 1, 42, 12345, 2**32 + 7, 2**40 + 123456789, 99999999999):
        r = random.Random(seed)
        pool = list(range(10))
        pool2 = list(range(30))
        case = {
            "seed": seed,
            "random": [r.random() for _ in range(5)],
            "getrandbits": [str(r.getrandbits(k)) for k in (1, 8, 16, 32, 33, 48, 63)],
            "randint_1_20": [r.randint(1, 20) for _ in range(12)],
            "randint_big": [r.randint(-1000, 100000) for _ in range(4)],
            "randrange_7": [r.randrange(7) for _ in range(6)],
            "randrange_step": [r.randrange(0, 50, 5) for _ in range(6)],
            "choice": [r.choice(list("abcdefg")) for _ in range(6)],
            "uniform": [r.uniform(-2.5, 9.75) for _ in range(4)],
        }
        r.shuffle(pool)
        case["shuffle_10"] = pool
        case["sample_small"] = r.sample(list(range(10)), 3)
        case["sample_k6"] = r.sample(list(range(20)), 8)
        case["sample_large_pop"] = r.sample(pool2 + list(range(30, 200)), 5)
        case["choices_plain"] = r.choices(list("wxyz"), k=8)
        case["choices_weighted"] = r.choices(list("abc"), weights=[1, 3, 6], k=10)
        case["gauss"] = [r.gauss(10, 2) for _ in range(5)]
        cases.append(case)
    return {"cases": cases}


@section("dice_attributes_cards")
def dice_attributes_cards():
    from game.core import attributes, cards, dice
    out = {"modifier": {str(v): attributes.modifier(v) for v in range(-3, 31)}}
    out["combine"] = [[list(c), dice.combine(*c)] for c in (
        (), ("vantagem",), ("desvantagem",), ("vantagem", "desvantagem"), ("vantagem", "vantagem", "desvantagem"),
        ("normal", "desvantagem", "desvantagem"), ("vantagem", "desvantagem", "desvantagem"))]
    out["pick_d20"] = [[st, a, b, list(dice.pick_d20(st, a, b))] for st in ("normal", "vantagem", "desvantagem")
                       for a, b in ((3, 15), (15, 3), (7, 7), (1, None), (20, None))]
    rolls = []
    for seed in (1, 7, 2026):
        random.seed(seed)
        rolls.append({"seed": seed, "roll": [dice.roll(d) for d in ("1d4", "2d6", "3d6", "1d20", "2d8", "1d10", "1d12")],
                      "d20": [list(dice.roll_d20(st)) for st in ("normal", "vantagem", "desvantagem", "vantagem")]})
    out["rolls"] = rolls
    out["sides_of"] = {d: dice.sides_of(d) for d in ("1d4", "2d6", "3D8", "1d20")}
    out["ac"] = [[attributes.armor_class(a), attributes.magic_armor_class(a)] for a in (
        attributes.DURVALL_ATTRIBUTES, attributes.MAELOR_ATTRIBUTES, attributes.SYLAS_ATTRIBUTES,
        attributes.KAYRON_ATTRIBUTES, attributes.BROOK_ATTRIBUTES)]
    allc = {n: c for n, c in vars(cards).items() if isinstance(c, cards.Card)}
    out["cards"] = {n: {"slug": c.slug, "targets_enemy": c.targets_enemy, "targets_ally": c.targets_ally,
                        "ally_hint": c.ally_hint} for n, c in allc.items()}
    out["decks"] = {n: [c.name for c in getattr(cards, "build_" + n + "_deck" if n != "starting" else "build_starting_deck")()]
                    for n in ("starting", "maelor", "sylas", "kayron", "brook")}
    out["slugify"] = {s: cards.slugify(s) for s in ("Golpe", "Chama Menor", "Surto de Ação", "  X--Y  ", "Comunhão com Sendrinah")}
    return out


def _enemy_snapshot(e):
    d = {k: (list(v) if isinstance(v, tuple) else v) for k, v in vars(e).items() if k != "script"}
    d["has_script"] = e.script is not None
    d["slug"] = e.slug
    d["eca"], d["ecam"] = e.effective_ca, e.effective_cam
    return d


ENEMY_FACTORIES = ["mimico", "mimico15", "criatura", "slime", "guardiao_copia", "guardiao_verdadeiro", "cultista_adaga",
                   "cultista_cajado", "cultista_arqueiro", "zumbi", "sacerdote"]


def _enemy_factories():
    from game.core import enemies as en
    return {"mimico": lambda: en.mimico(9, 11, 10), "mimico15": lambda: en.mimico(15, 12, 10, 25), "criatura": en.criatura_corrompida,
            "slime": en.slime_corrosivo, "guardiao_copia": en.guardiao_copia, "guardiao_verdadeiro": en.guardiao_verdadeiro,
            "cultista_adaga": en.cultista_adaga, "cultista_cajado": en.cultista_cajado, "cultista_arqueiro": en.cultista_arqueiro,
            "zumbi": en.zumbi, "sacerdote": en.sacerdote_mente_derretida}


@section("enemies")
def enemies_section():
    from game.core import enemies as en
    facs = _enemy_factories()
    out = {"snap": {n: _enemy_snapshot(f()) for n, f in facs.items()}}
    beh = []
    for n in ("guardiao_verdadeiro", "cultista_cajado", "sacerdote"):
        e = facs[n]()
        seq = list(e.peek_action()) + [e.peek_is_special(), e.peek_is_magical(), e.peek_is_area()]
        acts = [list(e.choose_action()) for _ in range(4)]
        stun = [e.try_stun(2), e.can_be_stunned, e.try_stun()]
        e.consume_stun(); s1 = [e.stunned, e.stun_left, e.stun_immune]
        e.consume_stun(); s2 = [e.stunned, e.stun_left, e.stun_immune]
        e.tick_stun_immunity(); s3 = e.stun_immune
        e.stun_immune = 0
        drops = [e.break_armor(3), e.break_armor(3), e.break_ward(2), e.break_ward(9), e.effective_ca, e.effective_cam, e.is_vulnerable]
        e.mark(2); e.mark(1); m = [e.marked_bonus, e.consume_mark(), e.consume_mark()]
        summ = None
        if e.script:
            e.hp = e.max_hp // 2 + 1
            a = e.script.check(e); e.hp = e.max_hp // 2; b = [x.name for x in e.script.check(e)]; c2 = e.script.check(e)
            summ = [len(a), b, len(c2), e.script.fired]
        beh.append({"n": n, "seq": seq, "acts": acts, "stun": stun, "s1": s1, "s2": s2, "s3": s3, "drops": drops, "mark": m, "summ": summ})
    out["beh"] = beh
    random.seed(5)
    e = en.zumbi()
    out["roll"] = {"seed": 5, "dmg": [en.Enemy.roll_damage("2d6"), en.Enemy.roll_damage("1d8", True), list(e.act()), list(e.act())]}
    return out


@section("turn_death_saves")
def turn_death_saves():
    from game.core import cards, death_saves as ds, turn
    out = {}
    cs = [cards.ESQUIVA, cards.RAJADA_DE_GOLPES, cards.GOLPE_RAPIDO, cards.GOLPE_ESMAGADOR, cards.LOCALIZAR_CRIATURA]
    cs += cards.build_starting_deck()
    seen = {}
    for c in cs:
        seen[c.name] = c
    t_rows = []
    for c in seen.values():
        for hit in (False, True):
            for act, bonus in ((1, True), (0, True), (1, False), (0, False)):
                t = turn.TurnState(actions_available=act, bonus_available=bonus, hit_this_turn=hit)
                row = {"card": c.name, "hit": hit, "act": act, "bonus": bonus, "can_play": t.can_play(c)}
                if row["can_play"]:
                    t.spend_for(c)
                    row["after"] = [t.actions_available, t.bonus_available]
                row["react"] = [t.can_react(c, k, r) for k in ("fisico", "magico", "x") for r in (True, False)]
                row["end"] = t.should_end
                t_rows.append(row)
    out["turn"] = t_rows
    out["spend"] = [(lambda t: [t.spend_action(), t.spend_action(), t.spend_bonus(), t.spend_bonus(), t.should_end, t.reaction_available,
                               (t.spend_reaction(), t.reaction_available)[1]])(turn.TurnState())]
    sv = []
    for rolls in ([10, 10, 10], [9, 9, 9], [1, 10, 10], [20], [1, 1], [5, 15, 15, 15], [9, 10, 9, 10, 9], [1, 15, 8]):
        s = ds.DeathSaves(); seq = []
        for r in rolls:
            o = ds.apply_roll(s, r)
            seq.append([o.roll, o.success, o.natural20, o.natural1, o.revived, o.died, o.successes, o.failures])
        sv.append({"rolls": rolls, "seq": seq, "end": [s.successes, s.failures]})
    out["saves"] = sv
    random.seed(11)
    s = ds.DeathSaves()
    out["seeded"] = [ds.roll_d20(), ds.roll_d20()]
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", default=str(Path(__file__).resolve().parent.parent / ".baseline" / "v0.18.0"))
    args = ap.parse_args()
    sys.path.insert(0, args.src)
    OUT.mkdir(parents=True, exist_ok=True)
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    for f in sorted((Path(__file__).resolve().parent / "golden_sections").glob("*.py")):
        exec(compile(f.read_text(encoding="utf-8"), str(f), "exec"), {"section": section, "random": random, "__name__": f.stem})
    for name, fn in SECTIONS.items():
        (OUT / f"{name}.json").write_text(json.dumps(fn(), ensure_ascii=False, indent=1), encoding="utf-8")
        print("golden:", name)


if __name__ == "__main__":
    main()
