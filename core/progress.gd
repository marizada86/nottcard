class_name Progress
extends RefCounted
## game/core/progress.py::Progress — nível e XP de UM personagem.

var level: int = 1
var xp: int = 0
var kills: int = 0

var max_xp: int:
	get:
		return ProgressRules.xp_for_level(ProgressRules.MAX_LEVEL)

var at_cap: bool:
	get:
		return level >= ProgressRules.MAX_LEVEL

## -1 no teto (a origem devolve None).
func next_threshold() -> int:
	return -1 if at_cap else ProgressRules.xp_for_level(level + 1)

func fraction_to_next() -> float:
	if at_cap:
		return 1.0
	var start := ProgressRules.xp_for_level(level)
	var end := ProgressRules.xp_for_level(level + 1)
	return maxf(0.0, minf(1.0, float(xp - start) / float(end - start)))

## Devolve Array de LevelUp.
func add_xp(amount: int, rewards_for_level: Callable = Callable()) -> Array:
	xp = mini(xp + maxi(0, amount), max_xp)
	var ups: Array = []
	while level < ProgressRules.MAX_LEVEL and xp >= ProgressRules.xp_for_level(level + 1):
		level += 1
		var lu := LevelUp.new()
		lu.level = level
		lu.rewards = rewards_for_level.call(level) if rewards_for_level.is_valid() else []
		ups.append(lu)
	return ups
