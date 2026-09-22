class_name StunCheck
extends RefCounted
## Porte de game/core/combat.py::StunCheck. Gerado por tools/gen_dataclasses.py; métodos à mão.

var d20: int = 0
var bonus: int = 0
var dc: int = 0
var d20_discarded = null
var state: String = "normal"

## --- métodos portados ---
var total: int:
	get:
		return d20 + bonus

var success: bool:
	get:
		return d20 == 20 or (d20 != 1 and total >= dc)
