"""Acrescenta métodos portados à mão aos esqueletos gerados (uso único, na F2). Idempotente: pula o que já tem o marcador."""
from pathlib import Path

CORE = Path(__file__).resolve().parent.parent / "core"
MARK = "## --- métodos portados ---"

APPEND = {
    "hit_result.gd": '''
var total: int:
	get:
		return d20 + bonus

var crit: bool:
	get:
		return d20 == 20

var fumble: bool:
	get:
		return d20 == 1

## 20 natural sempre acerta; 1 natural sempre erra; senão total >= defesa.
var hit: bool:
	get:
		return crit or (not fumble and total >= defense)

func copy() -> HitResult:
	var h := HitResult.new()
	h.d20 = d20
	h.bonus = bonus
	h.defense = defense
	h.defense_name = defense_name
	h.ignored = ignored
	h.sneak = sneak
	h.d20_discarded = d20_discarded
	h.state = state
	return h
''',
    "stun_check.gd": '''
var total: int:
	get:
		return d20 + bonus

var success: bool:
	get:
		return d20 == 20 or (d20 != 1 and total >= dc)
''',
    "attack_result.gd": '''
var total: int:
	get:
		return dano_carta + bonus_passiva + bonus_mistico

var acertou: bool:
	get:
		return hit == null or hit.hit
''',
    "enemy_action_result.gd": '''
var acertou: bool:
	get:
		return hit == null or hit.hit

var total_reduction: int:
	get:
		return reduced_by + reaction_amount
''',
    "pending_enemy_attack.gd": '''
var acertou: bool:
	get:
		return hit == null or hit.hit
''',
    "heal_result.gd": '''
var total: int:
	get:
		var full := dado_base * multiplicador + modificador
		return maxi(1, Py.fdiv(full, 2)) if desonra else full
''',
}

for name, body in APPEND.items():
    p = CORE / name
    s = p.read_text(encoding="utf-8")
    if MARK in s:
        continue
    # propriedades computadas substituem campos gerados de mesmo nome (ex.: HitResult.hit não existe como campo)
    p.write_text(s.rstrip("\n") + "\n\n" + MARK + body, encoding="utf-8")
    print("ok", name)
