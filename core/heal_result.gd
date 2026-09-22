class_name HealResult
extends RefCounted
## Porte de game/core/combat.py::HealResult. Gerado por tools/gen_dataclasses.py; métodos à mão.

var dado_base: int = 0
var modificador: int = 0
var multiplicador: int = 1
var dados: Array = []
var desonra: bool = false
var redimiu: bool = false

## --- métodos portados ---
var total: int:
	get:
		var full := dado_base * multiplicador + modificador
		return maxi(1, Py.fdiv(full, 2)) if desonra else full
