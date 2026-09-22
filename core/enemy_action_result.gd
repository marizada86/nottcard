class_name EnemyActionResult
extends RefCounted
## Porte de game/core/combat.py::EnemyActionResult. Gerado por tools/gen_dataclasses.py; métodos à mão.

var name: String = ""
var raw_damage: int = 0
var damage: int = 0
var reduced_by: int = 0
var is_special: bool = false
var hit = null
var dados: Array = []
var reaction: String = ""
var reaction_amount: int = 0
var reaction_dice: Array = []
var reaction_bonus: int = 0
var negated: bool = false
var counter_dice: Array = []
var counter_damage: int = 0
var last_stand: bool = false
var last_stand_source: String = "Proteção de Sendrinah"
var corroded: int = 0
var clone_damage: int = 0
var clone_fell: bool = false
var mystic_gain: int = 0
var guard_damage: int = 0
var guard_gain: int = 0

## --- métodos portados ---
var acertou: bool:
	get:
		return hit == null or hit.hit

var total_reduction: int:
	get:
		return reduced_by + reaction_amount
