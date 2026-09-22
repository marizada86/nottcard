class_name AttackResult
extends RefCounted
## Porte de game/core/combat.py::AttackResult. Gerado por tools/gen_dataclasses.py; métodos à mão.

var dado_base: int = 0
var dano_carta: int = 0
var bonus_passiva: int = 0
var multiplicador: int = 0
var compat: float = 1.0
var dados: Array = []
var dados_passiva: Array = []
var hit = null
var attr_flat: int = 0
var dmg_mult: float = 1.0
var em_corrente: bool = true
var hit_attr: String = ""
var bonus_mistico: int = 0
var dados_extra: Array = []

## --- métodos portados ---
var total: int:
	get:
		return dano_carta + bonus_passiva + bonus_mistico

var acertou: bool:
	get:
		return hit == null or hit.hit
