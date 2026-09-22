class_name EncounterScript
extends RefCounted
## game/core/enemies.py::EncounterScript — invoca reforços uma vez quando o portador cai a `trigger_hp_pct` dos PV máximos e ainda vive.

var trigger_hp_pct: float = 0.0
var summons: Callable
var announce: String = "Os mortos se levantam!"
var fired: bool = false

func _init(pct: float = 0.0, summon_fn: Callable = Callable()) -> void:
	trigger_hp_pct = pct
	summons = summon_fn

func check(enemy: Enemy) -> Array:
	if fired or enemy.hp <= 0 or enemy.hp > trigger_hp_pct * enemy.max_hp:
		return []
	fired = true
	return summons.call()
