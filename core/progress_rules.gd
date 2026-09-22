class_name ProgressRules
extends RefCounted
## game/core/progress.py — constantes e funções livres da progressão.

const MAX_LEVEL := 5
const ALL_CHARACTER_IDS := ["durvall", "maelor", "sylas", "kayron", "brook"]
const SAVE_VERSION := 1
const LEVEL_XP := [100, 350, 950, 1950]
const XP_SCALE := 1.0
const VITORIA := "vitoria"
const DESISTENCIA := "desistencia"
const DERROTA := "derrota"
const DEFEAT_XP_KEPT := 0.5

## XP acumulado necessário para ESTAR no `level` (nível 1 = 0).
static func xp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	return Py.round_half_even(LEVEL_XP[mini(level, MAX_LEVEL) - 2] * XP_SCALE)

static func level_for_xp(xp: int) -> int:
	var level := 1
	while level < MAX_LEVEL and xp >= xp_for_level(level + 1):
		level += 1
	return level

static func apply_outcome(gained: int, outcome: String) -> int:
	if outcome == DERROTA:
		return int(gained * DEFEAT_XP_KEPT)
	return gained

## rewards_for_level: Callable(level) -> Array de textos (pode ser inválido).
static func settle_run(progress: Progress, ledger: RunLedger, outcome: String, stats: RunStats, character_id: String = "",
		rewards_for_level: Callable = Callable()) -> RunResult:
	var raw := ledger.total
	var gained := apply_outcome(raw, outcome)
	var level_before := progress.level
	var xp_before := progress.xp
	var ups := progress.add_xp(gained, rewards_for_level)
	var r := RunResult.new()
	r.outcome = outcome
	r.character_id = character_id
	r.lines = ledger.lines.duplicate()
	r.raw_xp = raw
	r.adjustment = gained - raw
	r.gained = gained
	r.level_before = level_before
	r.level_after = progress.level
	r.xp_before = xp_before
	r.xp_after = progress.xp
	r.level_ups = ups
	r.stats = stats
	return r
