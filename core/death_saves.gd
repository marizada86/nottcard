class_name DeathSaves
extends RefCounted
## game/core/death_saves.py — testes de morte (d20 puro, DC 10, 3 sucessos revivem, 3 falhas matam).

const DC := 10
const STABLE_AT := 3
const DEAD_AT := 3

var successes: int = 0
var failures: int = 0

func reset() -> void:
	successes = 0
	failures = 0

static func roll_d20(rng: PyRandom = null) -> int:
	return (rng if rng != null else PyRandom.shared).randint(1, 20)

## Aplica um d20; devolve o SaveOutcome como Dictionary.
func apply_roll(roll: int) -> Dictionary:
	var natural20 := roll == 20
	var natural1 := roll == 1
	var success := natural20 or (not natural1 and roll >= DC)
	var revived: bool
	if natural20:
		revived = true
	else:
		if success:
			successes += 1
		else:
			failures += 2 if natural1 else 1
		revived = successes >= STABLE_AT
	var died := not revived and failures >= DEAD_AT
	var out := {"roll": roll, "success": success, "natural20": natural20, "natural1": natural1, "revived": revived,
		"died": died, "successes": successes, "failures": failures}
	if revived or died:
		reset()
	return out

func roll_save(rng: PyRandom = null, roll: int = -1) -> Dictionary:
	return apply_roll(roll if roll >= 0 else roll_d20(rng))
