class_name Dice
extends RefCounted
## game/core/dice.py

const NORMAL := "normal"
const ADVANTAGE := "vantagem"
const DISADVANTAGE := "desvantagem"

## 'NdM' → soma de N dados de M lados (usa o RNG global, como random.randint).
static func roll(dice: String, rng: PyRandom = null) -> int:
	var r := rng if rng != null else PyRandom.shared
	var parts := dice.to_lower().split("d")
	var total := 0
	for _i in range(int(parts[0])):
		total += r.randint(1, int(parts[1]))
	return total

static func sides_of(dice: String) -> int:
	return int(dice.to_lower().split("d")[1])

## Vantagem e desvantagem juntas se anulam.
static func combine(states: Array) -> String:
	var has_adv := ADVANTAGE in states
	var has_dis := DISADVANTAGE in states
	if has_adv == has_dis:
		return NORMAL
	return ADVANTAGE if has_adv else DISADVANTAGE

## [mantido, descartado|null]
static func pick_d20(state: String, first: int, second: Variant) -> Array:
	if state == NORMAL or second == null:
		return [first, null]
	if state == ADVANTAGE:
		return [maxi(first, second), mini(first, second)]
	return [mini(first, second), maxi(first, second)]

static func roll_d20(state: String = NORMAL, rng: PyRandom = null) -> Array:
	var r := rng if rng != null else PyRandom.shared
	var first := r.randint(1, 20)
	return pick_d20(state, first, null if state == NORMAL else r.randint(1, 20))
