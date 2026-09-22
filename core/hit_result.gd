class_name HitResult
extends RefCounted
## Porte de game/core/combat.py::HitResult. Gerado por tools/gen_dataclasses.py; métodos à mão.

var d20: int = 0
var bonus: int = 0
var defense: int = 0
var defense_name: String = ""
var ignored: int = 0
var sneak: bool = false
var d20_discarded = null
var state: String = "normal"

## --- métodos portados ---
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
