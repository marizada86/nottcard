class_name EncounterScript
extends RefCounted
## Invoca reforços ou troca o portador por sua fase seguinte uma vez ao cruzar o limiar de PV.

var trigger_hp_pct: float = 0.0
var summons: Callable
var phase: Callable
var announce: String = "Os mortos se levantam!"
var fired: bool = false

func _init(pct: float = 0.0, summon_fn: Callable = Callable(), phase_fn: Callable = Callable(), announce_: String = "") -> void:
	trigger_hp_pct = pct
	summons = summon_fn
	phase = phase_fn
	if announce_ != "":
		announce = announce_

func _eligible(enemy: Enemy) -> bool:
	# Uma fase não pode ser pulada por dano excedente: se ela tem sucessora,
	# alcançar (ou atravessar) o limiar sempre dispara a transformação local.
	return not fired and enemy.hp <= trigger_hp_pct * enemy.max_hp

## Devolve a fase sucessora somente uma vez. A sessão preserva o slot visual do portador.
func replace(enemy: Enemy) -> Variant:
	if not phase.is_valid() or not _eligible(enemy):
		return null
	fired = true
	return phase.call()

func check(enemy: Enemy) -> Array:
	if phase.is_valid() or not _eligible(enemy):
		return []
	fired = true
	return summons.call()
