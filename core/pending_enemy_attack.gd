class_name PendingEnemyAttack
extends RefCounted
## Porte de game/core/combat.py::PendingEnemyAttack. Gerado por tools/gen_dataclasses.py; métodos à mão.

var name: String = ""
var dice: String = ""
var is_special: bool = false
var kind: String = ""
var hit = null

## --- métodos portados ---
var acertou: bool:
	get:
		return hit == null or hit.hit
